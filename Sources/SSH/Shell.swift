// Shell.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import CSSH
import Foundation

public extension SSH {
    /// Initiates an asynchronous shell session.
    ///
    /// This function attempts to start a shell session on the SSH channel. It first checks if the raw channel is available,
    /// then processes the startup of the shell. If successful, it notifies the channel delegate that the connection is online.
    ///
    /// - Returns: A boolean value indicating whether the shell session was successfully started.
    func shell() async -> Bool {
        await call { [self] in
            guard let rawChannel else {
                return false
            }
            poll()
            let code = callSSH2 {
                libssh2_channel_process_startup(rawChannel, "shell", 5, nil, 0)
            }
            guard code == LIBSSH2_ERROR_NONE else {
                return false
            }
            addOperation {
                channelDelegate?.connect(ssh: self, online: true)
            }
            resumePoll()
            return true
        }
    }

    /// Requests to change the size of the pseudo-terminal (PTY) for the SSH channel.
    ///
    /// - Parameters:
    ///   - width: The desired width of the PTY in characters.
    ///   - height: The desired height of the PTY in characters.
    /// - Returns: A boolean value indicating whether the request was successful.
    /// - Note: This function is asynchronous and uses the `await` keyword to perform the request.
    ///         It returns `false` if the `rawChannel` is `nil` or if the request fails.
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

    /**
     Requests a pseudo-terminal (PTY) for the SSH channel.

     - Parameters:
       - type: The type of PTY to request. Defaults to `.xterm`.
       - width: The width of the terminal in characters. Defaults to `LIBSSH2_TERM_WIDTH`.
       - height: The height of the terminal in characters. Defaults to `LIBSSH2_TERM_HEIGHT`.

     - Returns: A boolean value indicating whether the PTY request was successful.

     This function asynchronously requests a PTY for the SSH channel using the specified type, width, and height. It returns `true` if the request was successful, and `false` otherwise.
     */
    func requestPty(type: PtyType = .xterm, width: Int32 = LIBSSH2_TERM_WIDTH, height: Int32 = LIBSSH2_TERM_HEIGHT) async -> Bool {
        await call { [self] in
            guard let rawChannel else {
                return false
            }
            let code = callSSH2 {
                libssh2_channel_request_pty_ex(rawChannel, type.name, type.name.count.load(), nil, 0, width, height, LIBSSH2_TERM_WIDTH_PX, LIBSSH2_TERM_HEIGHT_PX)
            }
            guard code == LIBSSH2_ERROR_NONE else {
                return false
            }
            return true
        }
    }

    /// Suspends the polling of the socket source.
    ///
    /// This method suspends the dispatch source associated with the socket,
    /// effectively pausing any polling or event handling that was being performed.
    /// Use this method when you need to temporarily stop processing events from the socket.
    func suspendPoll() {
        socketShell?.suspend()
    }

    /// Resumes the polling of the socket source if it is currently suspended.
    /// This function checks if the `socketShell` is not nil and calls the `resume()`
    /// method on it to continue the polling process.
    func resumePoll() {
        socketShell?.resume()
    }

    /// Polls the SSH channel for incoming data and handles it accordingly.
    ///
    /// This function sets up a non-blocking read source on the socket file descriptor
    /// and assigns event and cancel handlers to it. The event handler reads data from
    /// the SSH channel and processes it using the provided callbacks. If an error occurs
    /// or the read operation is complete, the shell is canceled. The cancel handler
    /// notifies the delegate that the connection is offline and sends an EOF signal.
    ///
    /// - Note: This function assumes that `sockfd`, `queue`, `onData`, `isPol`, `isPolError`,
    ///   `isRead`, `cancelShell`, `channelDelegate`, and `sendEOF` are defined elsewhere in the class.
    private func poll() {
        channelBlocking(false)
        cancelShell()
        socketShell = DispatchSource.makeReadSource(fileDescriptor: sockfd, queue: queue)
        socketShell?.setEventHandler { [self] in
            let (rc, erc) = read(PipeOutputStream(callback: { data in
                onData(data, true)
                return isPol
            }), PipeOutputStream(callback: { data in
                onData(data, false)
                return isPolError
            }))
            guard rc > 0 || erc > 0 else {
                guard rc != LIBSSH2_ERROR_SOCKET_RECV || erc != LIBSSH2_ERROR_SOCKET_RECV else {
                    cancelShell()
                    return
                }
                return
            }
            if !isRead {
                cancelShell()
                return
            }
        }
        socketShell?.setCancelHandler { [self] in
            if isRead {
                sendEOF()
            }
            channelDelegate?.connect(ssh: self, online: false)
        }
    }

    /// Handles incoming data from the SSH channel.
    /// - Parameters:
    ///   - data: The data received from the SSH channel.
    ///   - stdout: A boolean indicating whether the data is from the standard output (true) or standard error (false).
    /// - Note: If the data is not empty, it adds an operation to handle the data by calling the appropriate delegate method (`stdout` or `dtderr`).
    private func onData(_ data: Data, _ stdout: Bool) {
        guard data.count > 0 else {
            return
        }
        addOperation {
            await stdout ? self.channelDelegate?.stdout(ssh: self, data: data) : self.channelDelegate?.dtderr(ssh: self, data: data)
        }
    }

    /// Cancels the current shell session by canceling the associated socket source and setting it to nil.
    func cancelShell() {
        socketShell?.cancel()
        socketShell = nil
    }

    /// Closes the shell by canceling any active sources.
    ///
    /// This function is responsible for terminating the shell session
    /// by invoking the `cancelShell` method, which cancels any
    /// active sources associated with the shell.
    func closeShell() {
        cancelShell()
    }
}
