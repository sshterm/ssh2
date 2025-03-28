// Socket.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import CSSH
import Darwin
import Extension
import Foundation
import Proxy
import Socket

public extension SSH {
    /// A computed property that indicates whether the socket is connected.
    ///
    /// This property checks if the socket file descriptor (`sockfd`) is valid and
    /// then verifies the connection status of the socket.
    ///
    /// - Returns: `true` if the socket is connected, `false` otherwise.
    var isConnected: Bool {
        return socket.isConnected
    }

    /// Asynchronously connects to a socket.
    ///
    /// This function attempts to connect to a socket using the provided socket file descriptor.
    /// If the socket file descriptor is invalid, the function returns `false`.
    /// Otherwise, it sets the internal socket file descriptor and returns the connection status.
    ///
    /// - Parameter socket: The socket file descriptor to connect to.
    /// - Returns: A boolean value indicating whether the connection was successful.
    func connect(socket: Socket) async -> Bool {
        await call { [self] in
            guard socket.fd != -1 else {
                return false
            }
            self.socket = socket
            return isConnected
        }
    }

    /// Establishes a connection asynchronously.
    ///
    /// This function attempts to create a socket and establish a connection.
    /// If the socket creation fails, it returns `false`. Otherwise, it sets
    /// the socket file descriptor and returns the connection status.
    ///
    /// - Returns: A `Bool` indicating whether the connection was successfully established.
    func connect() async -> Bool {
        await call { [self] in
            let socket = (proxy != nil) ? Proxy(proxy!).connect(host, port, timeout) : Socket.create(host, port, timeout)
            guard socket.fd != -1 else {
                return false
            }
            self.socket = socket
            return isConnected
        }
    }

    /// Sends data through the specified socket.
    ///
    /// - Parameters:
    ///   - fd: The socket through which data will be sent.
    ///   - buffer: A pointer to the data to be sent.
    ///   - length: The length of the data to be sent.
    ///   - flags: Flags that influence the behavior of the send operation.
    /// - Returns: The number of bytes sent, or a negative error code if the send operation fails.
    func send(fd _: Int32, buffer: UnsafeRawPointer, length: size_t, flags: CInt) -> Int {
        let size = socket.send(buffer, length, flags)
        if size > 0 {
            send += Int64(size)
        }
        return size
    }

    /// Receives data from a socket.
    ///
    /// - Parameters:
    ///   - fd: The socket from which to receive data.
    ///   - buffer: A pointer to the buffer where the received data will be stored.
    ///   - length: The maximum number of bytes to receive.
    ///   - flags: Flags that influence the behavior of the receive operation.
    /// - Returns: The number of bytes received, or a negative error code if the operation fails.
    func recv(fd _: Int32, buffer: UnsafeMutableRawPointer, length: size_t, flags: CInt) -> Int {
        let size = socket.recv(buffer, length, flags)
        if size > 0 {
            recv += Int64(size)
        }
        return size
    }

    /// Shuts down the socket connection.
    ///
    /// - Parameter how: Specifies how the socket should be shut down.
    ///   The default value is `.rw`, which shuts down both reading and writing.
    ///   If `.rw` is specified, the socket will also be closed.
    func shutdown(_ how: Shout = .rw) {
        socket.shutdown(how)
        if how == .rw {
            socket = .init()
        }
    }

    /// Waits for the socket to be ready for reading or writing based on the session's block directions.
    ///
    /// This function uses the `poll` system call to wait for the socket to be ready for reading or writing.
    /// It checks the session's block directions to determine the events to wait for.
    ///
    /// - Returns: An `Int32` value indicating the result of the `poll` call:
    ///   - `-1` if the session or socket file descriptor is invalid.
    ///   - The result of the `poll` call otherwise.
    func waitsocket() -> Int32 {
        call { [self] in
            guard socket.fd != -1, rawSession != nil else {
                return -1
            }
            var timeout = Darwin.timeval(tv_sec: self.timeout, tv_usec: 0)
            var fdSet, readFd, writeFd: Darwin.fd_set
            fdSet = Darwin.fd_set()
            readFd = Darwin.fd_set()
            writeFd = Darwin.fd_set()
            fdSet.zero()
            fdSet.set(socket.fd)
            readFd.zero()
            writeFd.zero()
            let dir = libssh2_session_block_directions(rawSession)
            if (dir & LIBSSH2_SESSION_BLOCK_INBOUND) != 0 {
                readFd = fdSet
            }
            if (dir & LIBSSH2_SESSION_BLOCK_OUTBOUND) != 0 {
                writeFd = fdSet
            }
            let rc = Darwin.select(socket.fd + 1, &readFd, &writeFd, nil, &timeout)

            #if DEBUG
                print("阻塞:\(rc) dir: \(dir)")
            #endif
            return rc
        }
    }

    /// Closes the SSH connection by performing the following steps:
    /// 1. Shuts down the read side of the connection.
    /// 2. Locks the `lockRow` to ensure thread safety.
    /// 3. Frees any allocated resources.
    /// 4. Shuts down both the read and write sides of the connection.
    func close() {
        shutdown(.r)
        free()
        channelDelegate = nil
        sessionDelegate = nil
        shutdown(.rw)
    }
}
