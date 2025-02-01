// Socket.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import Darwin
import Extension
import Foundation
import Network

public struct Socket {
    public internal(set) var fd: Int32 = -1
    public internal(set) var hostname: String = ""
    public internal(set) var port: String = ""

    public init(fd: Int32 = -1) {
        self.fd = fd
    }
}

// public typealias Socket = Int32

public extension Socket {
    /// A computed property that checks if the socket is connected.
    ///
    /// This property returns `true` if the socket is connected, and `false` otherwise.
    /// It performs the check by verifying that the socket file descriptor is not -1,
    /// and then using the `getsockopt` function to check for any socket errors.
    ///
    /// - Returns: A Boolean value indicating whether the socket is connected.
    var isConnected: Bool {
        guard fd != -1 else {
            return false
        }
        var optval: Int32 = 0
        var optlen: socklen_t = Darwin.socklen_t(MemoryLayout<Int32>.size)
        let result = withUnsafeMutablePointer(to: &optval) {
            getsockopt(fd, SOL_SOCKET, SO_ERROR, $0, &optlen)
        }
        return result == 0 && optval == 0
    }

    /// Shuts down the socket connection.
    ///
    /// - Parameter how: Specifies the type of shutdown. Default is `.rw` (read and write).
    ///   - `.rw`: Closes both read and write operations.
    ///   - `.read`: Closes read operations.
    ///   - `.write`: Closes write operations.
    ///
    /// If the socket file descriptor is valid (not equal to -1), it performs the shutdown operation
    /// using the specified type. If the type is `.rw`, it also closes the socket.
    ///
    /// - Note: Uses Darwin's `shutdown` and `close` functions.
    func shutdown(_ how: Shout = .rw) {
        if fd != -1 {
            switch how {
            case .rw:
                close()
            default:
                Darwin.shutdown(fd, how.raw)
            }
        }
    }

    /// Creates a socket file descriptor for the specified host and port, with an optional proxy configuration and timeout.
    ///
    /// - Parameters:
    ///   - host: The hostname or IP address to connect to.
    ///   - port: The port number to connect to.
    ///   - timeout: The timeout value in seconds for the connection.
    ///
    /// - Returns: A socket file descriptor (`Sock`) on success, or `-1` on failure.
    static func create(_ host: String, _ port: String, _ timeout: Int) -> Socket {
        var socket: Socket = .init()
        socket.port = port
        IP.getAddrInfo(host: host, port: port) { info in
            socket.fd = Darwin.socket(info.pointee.ai_family, info.pointee.ai_socktype, info.pointee.ai_protocol)
            if socket.fd < 0 {
                return false
            }
            var timeoutStruct = Darwin.timeval(tv_sec: timeout, tv_usec: 0)
            setsockopt(socket.fd, SOL_SOCKET, SO_SNDTIMEO, &timeoutStruct, socklen_t(MemoryLayout<Darwin.timeval>.size))
            setsockopt(socket.fd, SOL_SOCKET, SO_RCVTIMEO, &timeoutStruct, socklen_t(MemoryLayout<Darwin.timeval>.size))
            if Darwin.connect(socket.fd, info.pointee.ai_addr, info.pointee.ai_addrlen) != 0 {
                socket.close()
                socket.fd = -1
                return false
            }
            let buf: Buffer<CChar> = .init(Int(NI_MAXHOST))
            guard Darwin.getnameinfo(info.pointee.ai_addr, info.pointee.ai_addrlen, buf.buffer, socklen_t(buf.count), nil, 0, NI_NUMERICHOST) == 0 else {
                socket.close()
                socket.fd = -1
                return false
            }
            socket.hostname = buf.buffer.string
            return true
        }
        return socket
    }

    /// Sends data through the socket.
    ///
    /// - Parameters:
    ///   - buffer: A pointer to the data to be sent.
    ///   - length: The number of bytes to send from the buffer.
    ///   - flags: Optional flags to modify the behavior of the send operation. Defaults to 0.
    ///
    /// - Returns: The number of bytes sent on success, or a negative error code on failure.
    func send(_ buffer: UnsafeRawPointer, _ length: Int, _ flags: Int32 = 0) -> Int {
        let size = Darwin.send(fd, buffer, length, flags)
        if size < 0 {
            return Int(-errno)
        }
        return size
    }

    /// Receives data from the socket.
    ///
    /// - Parameters:
    ///   - buffer: A pointer to a buffer where the received data will be stored.
    ///   - length: The maximum number of bytes to receive.
    ///   - flags: The flags to control the behavior of the receive function. Defaults to 0.
    /// - Returns: The number of bytes received, or a negative error code if the receive operation fails.
    func recv(_ buffer: UnsafeMutableRawPointer, _ length: Int, _ flags: Int32 = 0) -> Int {
        let size = Darwin.recv(fd, buffer, length, flags)
        if size < 0 {
            return Int(-errno)
        }
        return size
    }

    /// Reads data into the provided buffer.
    ///
    /// - Parameters:
    ///   - buffer: A pointer to the buffer where the read data will be stored.
    ///   - len: The maximum number of bytes to read.
    /// - Returns: The number of bytes actually read, or a negative value if an error occurred.
    func read(_ buffer: UnsafeMutableRawPointer, _ len: Int) -> Int {
        Darwin.read(fd, buffer, len)
    }

    /// Writes data from the provided buffer to the socket.
    ///
    /// - Parameters:
    ///   - buffer: A pointer to the data to be written.
    ///   - len: The number of bytes to write from the buffer.
    /// - Returns: The number of bytes that were written, or a negative value if an error occurred.
    func write(_ buffer: UnsafeRawPointer, _ len: Int) -> Int {
        Darwin.write(fd, buffer, len)
    }

    /// Closes the socket file descriptor.
    ///
    /// This function wraps the `Darwin.close` function to close the socket file descriptor
    /// associated with the current instance. It is important to call this function to
    /// release the resources associated with the socket.
    func close() {
        Darwin.close(fd)
    }
}

/// An enumeration representing the type of shutdown operation to perform on a socket.
///
/// This enum defines three cases, each corresponding to a different type of shutdown operation:
/// - `.r`: Shutdown the read half of the socket.
/// - `.w`: Shutdown the write half of the socket.
/// - `.rw`: Shutdown both the read and write halves of the socket.
///
/// The `raw` computed property returns the corresponding POSIX shutdown constant for each case.
///
/// - SeeAlso: `shutdown` function in POSIX sockets.
public enum Shout {
    /// Shutdown the read half of the socket.
    case r

    /// Shutdown the write half of the socket.
    case w

    /// Shutdown both the read and write halves of the socket.
    case rw

    /// The raw POSIX shutdown constant corresponding to the enum case.
    ///
    /// - Returns: An `Int32` representing the POSIX shutdown constant.
    var raw: Int32 {
        switch self {
        case .r:
            return SHUT_RD
        case .w:
            return SHUT_WR
        case .rw:
            return SHUT_RDWR
        }
    }
}
