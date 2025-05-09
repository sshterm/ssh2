// Channel.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import CSSH
import Darwin
import Extension
import Foundation

public extension SSH {
    /// Creates a new SSH session channel.
    ///
    /// This function opens a new session channel using the `libssh2_channel_open_ex` function.
    /// The channel is configured with specific parameters for the session type, window size, and packet size.
    ///
    /// - Returns: An optional `OpaquePointer` representing the newly created session channel,
    ///            or `nil` if the operation fails.
    func newSession() -> OpaquePointer? {
        callSSH2 { [self] in
            libssh2_channel_open_ex(rawSession, "session", 7, 0x200000, 0x8000, nil, 0)
        }
    }

    /// Closes the specified SSH channel if it is not `nil`.
    ///
    /// This method ensures that the channel is properly closed and freed,
    /// following the necessary steps to handle the end-of-file (EOF) and
    /// channel closure if the connection is still active.
    ///
    /// - Parameter channel: An optional `OpaquePointer` representing the SSH channel to be closed.
    ///                      If `nil`, the method does nothing.
    ///
    /// The method performs the following steps:
    /// 1. Checks if the channel is not `nil`.
    /// 2. If the channel is valid and the connection is active (`isConnected`):
    ///    - Sends an EOF signal to the channel.
    ///    - Waits for the EOF to be acknowledged.
    ///    - Waits for the channel to be fully closed.
    /// 3. Frees the channel resources using `libssh2_channel_free`.
    ///
    /// This method is executed within a `call` block to ensure proper handling of the closure logic.
    func closed(channel: OpaquePointer?) {
        call { [self] in
            if channel != nil {
                if isConnected {
                    if libssh2_channel_eof(channel) != 0 {
                        libssh2_channel_send_eof(channel)
                        libssh2_channel_wait_eof(channel)
                        libssh2_channel_wait_closed(channel)
                    }
                }
                libssh2_channel_free(channel)
            }
        }
    }

    /// Checks if the remote system supports echo functionality by executing a test command.
    ///
    /// This function asynchronously sends the command `echo ">TEST<"` to the remote system
    /// and verifies if the response matches the expected output. It ensures that the response
    /// starts with the string `>TEST<` after trimming any whitespace.
    ///
    /// - Returns: A Boolean value indicating whether the remote system supports echo functionality.
    func isEcho() async -> Bool {
        guard let data = await exec("echo \">TEST<\"", count: 6) else {
            return false
        }
        guard data.string?.trim.hasPrefix(">TEST<") ?? false else {
            return false
        }
        return true
    }

    /// Executes a command on the remote SSH server and streams the output and error streams.
    ///
    /// - Parameters:
    ///   - command: The command to execute on the remote server.
    ///   - output: The `OutputStream` to which the standard output of the command will be written.
    ///   - stderr: An optional `OutputStream` to which the standard error of the command will be written. Defaults to `nil`.
    ///
    /// - Returns: An `Int` representing the result of the operation. Returns `-1` if an error occurs.
    ///
    /// - Note:
    ///   - This function uses `libssh2` to execute the command on the remote server.
    ///   - The function is asynchronous and must be awaited.
    ///   - The `rawChannel` is closed after the operation is completed.
    ///   - The function handles both standard output and standard error streams if provided.
    func exec(_ command: String, _ output: OutputStream, _ stderr: OutputStream? = nil) async -> Int {
        await call { [self] in
            guard let rawChannel = newSession() else {
                return -1
            }
            libssh2_channel_set_blocking(rawChannel, 1)

            let code = callSSH2 {
                libssh2_channel_process_startup(rawChannel, "exec", 4, command, command.count.load())
            }
            guard code == LIBSSH2_ERROR_NONE else {
                closed(channel: rawChannel)
                return -1
            }
            let rc = io.Copy(output, ChannelInputStream(rawChannel: rawChannel, ssh: self, wait: true), bufferSize)
            if let stderr {
                io.Copy(stderr, ChannelInputStream(rawChannel: rawChannel, ssh: self, err: true, wait: true), bufferSize)
            }
            closed(channel: rawChannel)
            return rc
        }
    }

    /// Executes a command on the remote SSH channel asynchronously and processes the output.
    ///
    /// - Parameters:
    ///   - command: The command to be executed on the remote SSH channel.
    ///   - stdout: A closure that processes the standard output data.
    ///             The closure should return `true` to continue receiving data or `false` to stop.
    ///   - stderr: A closure that processes the standard error data.
    ///             The closure should return `true` to continue receiving data or `false` to stop.
    /// - Returns: A Boolean value indicating whether the command execution was successful (`true`) or not (`false`).
    func exec(_ command: String, _ stdout: @escaping (Data) -> Bool, _ stderr: @escaping (Data) -> Bool) async -> Bool {
        await exec(command, PipeOutputStream(callback: stdout), PipeOutputStream(callback: stderr)) >= 0
    }

    /// Executes a command on the SSH channel asynchronously and captures the output and error streams.
    ///
    /// - Parameters:
    ///   - command: The command to execute on the remote server.
    ///   - count: An optional limit on the number of bytes to read from the output stream. Defaults to 0, which means no limit.
    /// - Returns: A `Data` object containing the output of the command if successful, or `nil` if the execution fails.
    /// - Note: In debug mode (`DEBUG` flag enabled), the command will be printed to the console.
    /// - Important: The `self.error` property is updated with the error stream as a string if the command execution fails.
    func exec(_ command: String, count: Int = 0) async -> Data? {
        #if DEBUG
            print(command)
        #endif
        var data = Data()
        var error = Data()
        let rc = await exec(command, PipeOutputStream { d in
            data.append(d)
            if count > 0 {
                return data.count < count
            }
            return true
        }, PipeOutputStream { d in
            error.append(d)
            return true
        })
        self.error = error.string
        guard rc >= 0 else {
            return nil
        }
        return data
    }

    /// Executes a shell command on the remote SSH server.
    ///
    /// - Parameter command: An array of strings representing the command and its arguments.
    ///   The array elements are joined with a space to form the full command.
    /// - Returns: A `Data?` object containing the result of the command execution, or `nil` if the execution fails.
    /// - Note: This function is asynchronous and must be called with `await`.
    func exec(_ command: [String]) async -> Data? {
        return await exec(command.joined(separator: " "))
    }
}
