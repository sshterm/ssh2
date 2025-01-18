// Socket.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2024/8/15.

import CSSH
import Darwin
import Foundation

public extension SSH {
    /// A computed property that indicates whether the socket is connected.
    ///
    /// This property checks if the socket file descriptor (`sockfd`) is valid and
    /// then verifies the connection status of the socket.
    ///
    /// - Returns: `true` if the socket is connected, `false` otherwise.
    var isConnected: Bool {
        guard sockfd != -1 else {
            return false
        }
        return sockfd.isConnected
    }

    /// Asynchronously connects to a socket.
    ///
    /// This function attempts to connect to a socket using the provided socket file descriptor.
    /// If the socket file descriptor is invalid, the function returns `false`.
    /// Otherwise, it sets the internal socket file descriptor and returns the connection status.
    ///
    /// - Parameter sockfd: The socket file descriptor to connect to.
    /// - Returns: A boolean value indicating whether the connection was successful.
    func connect(sockfd: SockFD) async -> Bool {
        await call {
            guard sockfd != -1 else {
                return false
            }
            self.sockfd = sockfd
            return self.isConnected
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
            let sockfd: SockFD = .create(host, port, timeout)
            guard sockfd != -1 else {
                return false
            }
            self.sockfd = sockfd
            return isConnected
        }
    }

    /// Sends data through the specified socket.
    ///
    /// - Parameters:
    ///   - socket: The socket through which data will be sent.
    ///   - buffer: A pointer to the data to be sent.
    ///   - length: The length of the data to be sent.
    ///   - flags: Flags that influence the behavior of the send operation.
    /// - Returns: The number of bytes sent, or a negative error code if the send operation fails.
    func send(socket: SockFD, buffer: UnsafeRawPointer, length: size_t, flags: CInt) -> Int {
        let size = socket.send(buffer, length, flags)
        if size > 0 {
            addOperation {
                await self.sessionDelegate?.send(ssh: self, size: size)
            }
        }
        return size
    }

    /// Receives data from a socket.
    ///
    /// - Parameters:
    ///   - socket: The socket from which to receive data.
    ///   - buffer: A pointer to the buffer where the received data will be stored.
    ///   - length: The maximum number of bytes to receive.
    ///   - flags: Flags that influence the behavior of the receive operation.
    /// - Returns: The number of bytes received, or a negative error code if the operation fails.
    func recv(socket: SockFD, buffer: UnsafeMutableRawPointer, length: size_t, flags: CInt) -> Int {
        let size = socket.recv(buffer, length, flags)
        if size > 0 {
            addOperation {
                await self.sessionDelegate?.recv(ssh: self, size: size)
            }
        }
        return size
    }

    /// Shuts down the socket connection.
    ///
    /// - Parameter how: Specifies how the socket should be shut down.
    ///   The default value is `.rw`, which shuts down both reading and writing.
    ///   If `.rw` is specified, the socket will also be closed.
    func shutdown(_ how: Shout = .rw) {
        if sockfd != -1 {
            sockfd.shutdown(how)
            if how == .rw {
                sockfd = -1
            }
        }
    }

    /// Waits for the socket to be ready for reading or writing.
    ///
    /// This function uses the `select` system call to wait for the socket to be
    /// ready for reading or writing, based on the directions indicated by the
    /// libssh2 session.
    ///
    /// - Returns: An `Int32` value indicating the result of the `select` call.
    ///   - `0` if the timeout expired and no file descriptors were ready.
    ///   - A positive value indicating the number of file descriptors that are ready.
    ///   - `-1` if an error occurred.
    ///
    /// - Note: This function assumes that `rawSession` and `sockfd` are valid.
    ///   If `rawSession` is `nil` or `sockfd` is `-1`, the function returns `-1`.
    ///
    /// - Important: The `timeout` property is used to set the timeout value for
    ///   the `select` call.
    func waitsocket() -> Int32 {
        guard let rawSession, sockfd != -1 else {
            return -1
        }

        var timeout = timeval(tv_sec: 1, tv_usec: 0)

        var fdSet = fd_set()
        var readFd = fd_set()
        var writeFd = fd_set()
        fdSet.zero()
        fdSet.set(sockfd)
        readFd.zero()
        writeFd.zero()

        let dir = libssh2_session_block_directions(rawSession)

        if (dir & LIBSSH2_SESSION_BLOCK_INBOUND) != 0 {
            readFd = fdSet
        }

        if (dir & LIBSSH2_SESSION_BLOCK_OUTBOUND) != 0 {
            writeFd = fdSet
        }

        let rc = select(sockfd + 1, &readFd, &writeFd, nil, &timeout)
        #if DEBUG
            print("阻塞:\(rc) 方向: \(dir)")
        #endif
        return rc
    }
}
