// Channel.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/18.

import CSSH
import Darwin
import Extension
import Foundation

public extension SSH {
    /// Opens an SSH channel asynchronously.
    ///
    /// This function attempts to open an SSH channel with the specified language setting.
    /// It first frees any existing channel, then opens a new channel with the given parameters.
    /// If a language is provided, it sets the environment variable `LANG` for the channel.
    ///
    /// - Parameter lang: The language setting for the channel. Defaults to an empty string.
    /// - Returns: A boolean value indicating whether the channel was successfully opened.
    /// - Note: The function uses `libssh2_channel_open_ex` to open the channel and `libssh2_channel_setenv_ex` to set the environment variable.
    func openChannel(lang: String = "") async -> Bool {
        await call { [self] in
            guard let rawSession else {
                return false
            }
            freeChannel()
            let rawChannel = callSSH2 { libssh2_channel_open_ex(rawSession, "session", 7, 2 * 1024 * 1024, 32768, nil, 0) }
            if !lang.isEmpty {
                callSSH2 {
                    libssh2_channel_setenv_ex(rawChannel, "LANG", 4, lang, lang.count.load())
                }
            }
            self.rawChannel = rawChannel
            return true
        }
    }

    /// Checks if the SSH channel echoes a test string.
    ///
    /// This function attempts to open an SSH channel and execute the command `echo ">TEST<"`.
    /// It then reads the output from the channel and checks if the output starts with the string `">TEST<"`.
    ///
    /// - Returns: A boolean value indicating whether the SSH channel echoes the test string.
    /// - Note: This function uses asynchronous operations to open the channel, execute the command, and read the output.
    /// - Important: The channel is freed after the operation is completed, regardless of the result.
    func isEcho() async -> Bool {
        guard await openChannel() else {
            return false
        }
        defer {
            freeChannel()
        }
        guard await exec("echo \">TEST<\"") else {
            return false
        }
        guard let data = await read() else {
            return false
        }
        guard data.string?.trim.hasPrefix(">TEST<") ?? false else {
            return false
        }
        return true
    }

    /// Executes a command on the remote SSH server.
    ///
    /// - Parameter command: The command to be executed as a `String`.
    /// - Returns: A `Bool` indicating whether the command was successfully executed.
    /// - Note: This function is asynchronous and uses `await` to handle asynchronous operations.
    /// - Important: Ensure that `rawChannel` is properly initialized before calling this function.
    func exec(_ command: String) async -> Bool {
        guard let rawChannel else {
            return false
        }
        return await call { [self] in
            let code = callSSH2 {
                libssh2_channel_process_startup(rawChannel, "exec", 4, command, command.count.load())
            }
            guard code == LIBSSH2_ERROR_NONE else {
                return false
            }
            return true
        }
    }

    /// Sets an environment variable for the SSH channel.
    ///
    /// - Parameters:
    ///   - name: The name of the environment variable to set.
    ///   - value: The value of the environment variable to set.
    /// - Returns: A boolean value indicating whether the environment variable was successfully set.
    /// - Note: This function is asynchronous and uses the `await` keyword to perform the operation.
    func setenv(name: String, value: String) async -> Bool {
        guard let rawChannel else {
            return false
        }
        return await call { [self] in
            let code = callSSH2 {
                libssh2_channel_setenv_ex(rawChannel, name, name.count.load(), value, value.count.load())
            }
            guard code == LIBSSH2_ERROR_NONE else {
                return false
            }
            return true
        }
    }

    /// Writes data to the SSH channel.
    ///
    /// - Parameters:
    ///   - data: The data to be written to the channel.
    ///   - stderr: A Boolean value indicating whether the data should be written to the standard error stream. Defaults to `false`.
    /// - Returns: A Boolean value indicating whether the write operation was successful.
    /// - Note: This function is asynchronous and uses the `await` keyword to perform the write operation.
    func write(data: Data, stderr: Bool = false) async -> Bool {
        guard let rawChannel else {
            return false
        }
        return await call { [self] in
            let code = callSSH2 {
                libssh2_channel_write_ex(rawChannel, stderr ? SSH_EXTENDED_DATA_STDERR : 0, data.bytes, data.count)
            }
            guard code > 0 else {
                return false
            }
            return true
        }
    }

    /// Reads data from the SSH channel.
    ///
    /// - Parameters:
    ///   - stderr: A Boolean value indicating whether to read from the standard error stream.
    ///             If `true`, reads from the standard error stream; otherwise, reads from the standard output stream.
    ///             The default value is `false`.
    ///   - wait: A Boolean value indicating whether to wait for data to be available.
    ///           If `true`, waits for data to be available; otherwise, returns immediately if no data is available.
    ///           The default value is `true`.
    ///
    /// - Returns: An optional `Data` object containing the read data, or `nil` if an error occurs or no data is available.
    func read(stderr: Bool = false, wait: Bool = true) async -> Data? {
        guard let rawChannel else {
            return nil
        }
        return await call { [self] in
            let buf: Buffer<UInt8> = .init(bufferSize)
            let count = callSSH2(wait) {
                libssh2_channel_read_ex(rawChannel, stderr ? SSH_EXTENDED_DATA_STDERR : 0, buf.buffer, buf.capacity)
            }
            guard count >= 0 else {
                return nil
            }
            return buf.data(count.load())
        }
    }

    /// Reads data from the SSH channel and writes it to the provided output stream.
    ///
    /// - Parameters:
    ///   - output: The `OutputStream` to which the data will be written.
    ///   - err: A Boolean value indicating whether to read from the error stream. Defaults to `false`.
    ///   - wait: A Boolean value indicating whether to wait for the read operation to complete. Defaults to `true`.
    /// - Returns: The number of bytes read, or `-1` if the channel is not available.
    func read(_ output: OutputStream, err: Bool = false, wait: Bool = true) -> Int {
        guard let rawChannel else {
            return -1
        }
        let rc = callSSH2(wait) { [self] in
            return io.Copy(output, ChannelInputStream(handle: rawChannel, err: err), bufferSize)
        }
        return rc
    }

    /// Reads data from the provided output streams.
    ///
    /// - Parameters:
    ///   - stdout: The output stream for standard output.
    ///   - stderr: The output stream for standard error.
    /// - Returns: A tuple containing the number of bytes read from the standard output and standard error streams.
    func read(_ stdout: OutputStream, _ stderr: OutputStream) -> (Int, Int) {
        var rc, erc: Int
        rc = read(stdout, wait: false)
        erc = read(stderr, err: true, wait: false)
        return (rc, erc)
    }

    /// Initiates a subsystem request on the SSH channel.
    ///
    /// This function sends a request to start a subsystem on the SSH channel using the provided subsystem name.
    ///
    /// - Parameter name: The name of the subsystem to start.
    /// - Returns: A boolean value indicating whether the subsystem request was successful.
    /// - Note: This function is asynchronous and uses Swift's concurrency model.
    /// - Important: Ensure that `rawChannel` is properly initialized before calling this function.
    func subsystem(name: String) async -> Bool {
        guard let rawChannel else {
            return false
        }
        return await call { [self] in
            let code = callSSH2 {
                libssh2_channel_process_startup(rawChannel, "subsystem", 9, name, name.count.load())
            }
            guard code == LIBSSH2_ERROR_NONE else {
                return false
            }
            return true
        }
    }

    /// A computed property that indicates whether the channel is still readable.
    ///
    /// This property returns `true` if the channel has not received an EOF (End Of File) signal
    /// or an exit signal, and is still connected. Otherwise, it returns `false`.
    ///
    /// - Returns: A Boolean value indicating whether the channel is readable.
    var isRead: Bool {
        !(receivedEOF || receivedExit) && isConnected
    }

    /// A computed property that checks if the SSH channel has data available to read.
    ///
    /// This property uses the `libssh2_poll_channel_read` function to determine if there is data
    /// available to read on the SSH channel. If the `rawChannel` is `nil`, it returns `false`.
    /// Otherwise, it returns `true` if there is data available to read, and `false` if there is not.
    ///
    /// - Returns: A Boolean value indicating whether the SSH channel has data available to read.
    var isPol: Bool {
        guard let rawChannel = rawChannel else {
            return false
        }
        return libssh2_poll_channel_read(rawChannel, 0) != 0
    }

    /// A computed property that checks if there is an error on the SSH channel.
    ///
    /// This property returns `true` if there is an error on the SSH channel's standard error stream,
    /// and `false` otherwise. It uses the `libssh2_poll_channel_read` function to check for errors.
    ///
    /// - Returns: A Boolean value indicating whether there is an error on the SSH channel.
    var isPolError: Bool {
        guard let rawChannel = rawChannel else {
            return false
        }
        return libssh2_poll_channel_read(rawChannel, SSH_EXTENDED_DATA_STDERR) != 0
    }

    /// A computed property that checks if the SSH channel has received an exit status.
    ///
    /// This property returns `true` if the channel has received an exit status, indicating that the remote process has terminated.
    /// If the channel is not initialized (`rawChannel` is `nil`), it returns `false`.
    ///
    /// - Returns: A Boolean value indicating whether the SSH channel has received an exit status.
    var receivedExit: Bool {
        guard let rawChannel else {
            return false
        }
        return libssh2_channel_get_exit_status(rawChannel) != 0
    }

    /// A computed property that checks if the end-of-file (EOF) has been received on the SSH channel.
    ///
    /// This property returns `true` if the EOF has been received, otherwise it returns `false`.
    /// It uses the `libssh2_channel_eof` function to determine the EOF status of the `rawChannel`.
    ///
    /// - Returns: A Boolean value indicating whether the EOF has been received.
    var receivedEOF: Bool {
        guard let rawChannel else {
            return false
        }
        return libssh2_channel_eof(rawChannel) != 0
    }

    /// Sends an EOF (End Of File) signal to the SSH channel.
    ///
    /// This function attempts to send an EOF signal to the SSH channel. It first checks if an EOF
    /// has already been received. If so, it returns `true`. If the raw channel is not available,
    /// it returns `false`. Otherwise, it calls the `libssh2_channel_send_eof` function to send
    /// the EOF signal and checks the return code. If the code indicates success, it returns `true`,
    /// otherwise it returns `false`.
    ///
    /// - Returns: A Boolean value indicating whether the EOF signal was successfully sent.
    func sendEOF() -> Bool {
        guard !receivedEOF else {
            return true
        }
        guard let rawChannel else {
            return false
        }
        let code = callSSH2 {
            libssh2_channel_send_eof(rawChannel)
        }
        guard code == LIBSSH2_ERROR_NONE else {
            return false
        }
        return true
    }

    /// Sets the blocking mode for the SSH channel.
    ///
    /// - Parameter blocking: A Boolean value that determines whether the channel should be in blocking mode.
    ///   Pass `true` to set the channel to blocking mode, or `false` to set it to non-blocking mode.
    func channelBlocking(_ blocking: Bool) {
        if let rawChannel {
            libssh2_channel_set_blocking(rawChannel, blocking ? 1 : 0)
        }
    }

    /// Frees the SSH channel if it exists.
    ///
    /// This function sets the channel to non-blocking mode, frees the channel,
    /// and then adds an operation to notify the delegate about the disconnection.
    /// Finally, it sets the `rawChannel` property to `nil`.
    ///
    /// - Note: This function should be called when the channel is no longer needed
    ///         to ensure proper cleanup and resource management.
    func freeChannel() {
        if let rawChannel {
            if isRead {
                sendEOF()
            }
            libssh2_channel_set_blocking(rawChannel, 0)
            lockSSH2.lock()
            defer {
                lockSSH2.unlock()
            }
            closeShell()
            libssh2_channel_free(rawChannel)
            addOperation {
                self.channelDelegate?.disconnect(ssh: self)
            }
            self.rawChannel = nil
        }
    }
}
