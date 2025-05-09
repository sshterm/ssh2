// Shell.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import CSSH
import Extension
import Foundation

public extension SSH {
    /// Opens a shell session on the SSH server with the specified terminal type and dimensions.
    ///
    /// - Parameters:
    ///   - type: The type of pseudo-terminal to request. Defaults to `.xterm`.
    ///   - width: The width of the terminal in characters. Defaults to `LIBSSH2_TERM_WIDTH`.
    ///   - height: The height of the terminal in characters. Defaults to `LIBSSH2_TERM_HEIGHT`.
    ///
    /// - Returns: A `Bool` indicating whether the shell session was successfully opened.
    ///
    /// This function performs the following steps:
    /// 1. Creates a new SSH session and assigns it to `rawChannel`.
    /// 2. Requests a pseudo-terminal with the specified type and dimensions.
    /// 3. Starts a shell process on the server.
    /// 4. Notifies the `channelDelegate` that the connection is online if successful.
    ///
    /// If any step fails, the shell session is closed and the function returns `false`.
    ///
    /// This function is asynchronous and must be called from an asynchronous context.
    func shell(type: PtyType = .xterm, width: Int32 = LIBSSH2_TERM_WIDTH, height: Int32 = LIBSSH2_TERM_HEIGHT) async -> Bool {
        await call { [self] in
            rawChannel = newSession()
            guard rawChannel != nil else {
                return false
            }
            pollShell()
            var code = callSSH2 {
                libssh2_channel_request_pty_ex(rawChannel, type.name, type.name.count.load(), nil, 0, width, height, LIBSSH2_TERM_WIDTH_PX, LIBSSH2_TERM_HEIGHT_PX)
            }
            guard code == LIBSSH2_ERROR_NONE else {
                closeShell()
                return false
            }
            code = callSSH2 {
                libssh2_channel_process_startup(rawChannel, "shell", 5, nil, 0)
            }
            guard code == LIBSSH2_ERROR_NONE else {
                closeShell()
                return false
            }
            addOperation {
                channelDelegate?.connect(ssh: self, online: true)
            }
            return true
        }
    }

    /// Requests a change in the size of the pseudo-terminal (PTY) associated with the SSH channel.
    ///
    /// This function sends a request to the remote server to resize the PTY to the specified width and height.
    /// The request is performed asynchronously and returns a boolean indicating whether the operation was successful.
    ///
    /// - Parameters:
    ///   - width: The desired width of the PTY in characters.
    ///   - height: The desired height of the PTY in characters.
    /// - Returns: A boolean value indicating whether the PTY resize request was successful (`true`) or not (`false`).
    /// - Note: This function requires an active SSH channel (`rawChannel`) to be available. If the channel is not available,
    ///         the function will return `false`.
    func requestPtySize(width: Int32, height: Int32) async -> Bool {
        await call { [self] in
            guard let rawChannel else {
                return false
            }
            let code = callSSH2 {
                libssh2_channel_request_pty_size_ex(rawChannel, width, height, LIBSSH2_TERM_WIDTH_PX, LIBSSH2_TERM_HEIGHT_PX)
            }
            guard code == LIBSSH2_ERROR_NONE else {
                return false
            }
            return true
        }
    }

    /// Suspends the polling operation of the shell's socket.
    ///
    /// This method calls the `suspend` function on the `socketShell`
    /// instance, if it exists, to pause any ongoing polling activities.
    func suspendPoll() {
        socketShell?.suspend()
    }

    /// Resumes the polling operation for the shell's socket connection.
    ///
    /// This method calls the `resume` function on the `socketShell` object,
    /// if it is not `nil`, to continue processing data or events.
    func resumePoll() {
        socketShell?.resume()
    }

    /// Sets an environment variable for the SSH channel.
    ///
    /// This function asynchronously sets an environment variable with the specified
    /// name and value for the current SSH channel. If the channel is not available,
    /// the function returns `false`.
    ///
    /// - Parameters:
    ///   - name: The name of the environment variable to set.
    ///   - value: The value of the environment variable to set.
    /// - Returns: A `Bool` indicating whether the environment variable was successfully set.
    ///            Returns `false` if the channel is unavailable or if an error occurs during the operation.
    func setEnv(name: String, value: String) async -> Bool {
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

    /// Writes the provided data to the SSH channel.
    ///
    /// - Parameters:
    ///   - data: The `Data` object containing the bytes to be written to the channel.
    ///   - stderr: A Boolean value indicating whether the data should be written to the standard error stream (`true`)
    ///             or the standard output stream (`false`). Defaults to `false`.
    /// - Returns: A Boolean value indicating whether the write operation was successful (`true`) or not (`false`).
    ///
    /// This method uses the `libssh2_channel_write_ex` function to write the data to the specified channel.
    /// If the channel is not available (`rawChannel` is `nil`), the method immediately returns `false`.
    /// The write operation is performed asynchronously.
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

    /// Reads data from the channel and writes it to the specified output stream.
    ///
    /// - Parameters:
    ///   - output: The `OutputStream` where the data will be written.
    ///   - err: A Boolean value indicating whether to read from the error stream. Defaults to `false`.
    ///   - wait: A Boolean value indicating whether to wait for data to be available before reading.
    /// - Returns: The number of bytes successfully copied to the output stream.
    func read(_ output: OutputStream, err: Bool = false, wait: Bool) -> Int {
        let rc = io.Copy(output, ChannelInputStream(rawChannel: rawChannel, ssh: self, err: err, wait: wait), bufferSize)
        return rc
    }

    /// Reads data from the provided output streams for standard output and standard error.
    ///
    /// - Parameters:
    ///   - stdout: The output stream for standard output.
    ///   - stderr: The output stream for standard error.
    /// - Returns: A tuple containing two integers:
    ///   - The number of bytes read from the standard output stream.
    ///   - The number of bytes read from the standard error stream.
    func read(_ stdout: OutputStream, _ stderr: OutputStream) -> (Int, Int) {
        var rc, erc: Int
        rc = read(stdout, wait: false)
        erc = read(stderr, err: true, wait: false)
        return (rc, erc)
    }

    /// Polls the shell for incoming data and handles events such as reading data,
    /// detecting errors, and closing the shell when necessary.
    ///
    /// This method sets up a non-blocking `DispatchSource` to monitor the socket
    /// for read events. When data is available, it reads from the socket and
    /// processes the data using the provided `onData` closures for standard output
    /// and error streams. If specific conditions are met (e.g., socket receive
    /// errors, EOF, or exit signals), the shell is closed.
    ///
    /// - Important: This method ensures that the `socketShell` is properly
    ///   canceled and deallocated before creating a new read source.
    ///
    /// - Event Handlers:
    ///   - `setEventHandler`: Reads data from the socket and processes it. Closes
    ///     the shell if certain conditions are met.
    ///   - `setCancelHandler`: Notifies the `channelDelegate` that the connection
    ///     is offline and cleans up the `socketShell`.
    ///
    /// - Note: The `isBlocking` property is set to `false` to ensure non-blocking
    ///   behavior.
    func pollShell() {
        isBlocking = false
        socketShell?.cancel()
        socketShell = nil
        socketShell = DispatchSource.makeReadSource(fileDescriptor: socket.fd, queue: queueSocket)
        socketShell?.setEventHandler { [self] in
            let (rc, erc) = read(PipeOutputStream { data in
                onData(data, true)
                return isPoll
            }, PipeOutputStream { data in
                onData(data, false)
                return isPollError
            })
            if rc == LIBSSH2_ERROR_SOCKET_RECV || erc == LIBSSH2_ERROR_SOCKET_RECV || receivedEOF || receivedExit {
                closeShell()
            }
        }
        socketShell?.setCancelHandler {
            self.channelDelegate?.connect(ssh: self, online: false)
            self.socketShell = nil
        }
        socketShell?.resume()
    }

    /// A computed property that determines whether the shell is in a readable state.
    ///
    /// The shell is considered readable if:
    /// - It has not received an EOF (End of File) signal.
    /// - It has not received an exit signal.
    /// - It is still connected.
    ///
    /// - Returns: `true` if the shell is readable; otherwise, `false`.
    var isRead: Bool {
        !(receivedEOF || receivedExit) && isConnected
    }

    /// A computed property that checks if the SSH channel has received an exit status.
    ///
    /// - Returns: `true` if the channel is `nil` or if the exit status of the channel is non-zero,
    ///   indicating that the channel has received an exit status. Otherwise, returns `false`.
    var receivedExit: Bool {
        guard let rawChannel else {
            return true
        }
        return libssh2_channel_get_exit_status(rawChannel) != 0
    }

    /// A computed property that determines whether the SSH channel is in a polling state.
    ///
    /// - Returns: `true` if the channel is `nil` or if there is data available to read on the channel;
    ///   otherwise, `false`.
    ///
    /// This property uses the `libssh2_poll_channel_read` function to check if there is data available
    /// to read on the SSH channel. If the channel is `nil`, it defaults to `true`.
    var isPoll: Bool {
        guard let rawChannel else {
            return true
        }
        return libssh2_poll_channel_read(rawChannel, 0) != 0
    }

    /// A computed property that checks if there is an error on the poll channel.
    ///
    /// This property evaluates whether the `rawChannel` is in an error state by
    /// polling the channel for extended data on the standard error stream.
    ///
    /// - Returns: `true` if `rawChannel` is `nil` or if the poll indicates an error
    ///   on the standard error stream; otherwise, `false`.
    var isPollError: Bool {
        guard let rawChannel else {
            return true
        }
        return libssh2_poll_channel_read(rawChannel, SSH_EXTENDED_DATA_STDERR) != 0
    }

    /// A computed property that checks if the channel has received an EOF (End-of-File) signal.
    ///
    /// - Returns: `true` if the channel is `nil` or if the underlying `libssh2_channel_eof`
    ///   function indicates that an EOF has been received; otherwise, `false`.
    var receivedEOF: Bool {
        guard let rawChannel else {
            return true
        }
        return libssh2_channel_eof(rawChannel) != 0
    }

    /// Sends an EOF (End of File) signal to the remote channel.
    ///
    /// This function checks if an EOF has already been received or if the raw channel
    /// is unavailable. If neither condition is met, it attempts to send an EOF signal
    /// using the `libssh2_channel_send_eof` function.
    ///
    /// - Returns:
    ///   - `true` if the EOF signal was successfully sent or if an EOF was already received.
    ///   - `false` if the raw channel is unavailable or if there was an error sending the EOF signal.
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

    /// Closes the shell by canceling any active sources.
    ///
    /// This function is responsible for terminating the shell session
    /// by invoking the `cancelShell` method, which cancels any
    /// active sources associated with the shell.
    func closeShell() {
        lock.withLock {
            socketShell?.cancel()
            closed(channel: rawChannel)
            rawChannel = nil
        }
    }
}
