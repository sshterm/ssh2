// SSH.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/16.

import CSSH
import Foundation

public class SSH {
    /// The current version of the SSH library.
    ///
    /// This constant holds the version number of the SSH library as a string.
    /// It can be used to check the version of the library being used in the project.
    public static let version = "0.0.1"

    /// A constant representing the version of the libssh2 library being used.
    /// This value is defined by the `LIBSSH2_VERSION` macro.
    public static let libssh2_version = LIBSSH2_VERSION

    public var buffer = 0x4000

    public var ignoredFiles = [".", ".."]

    /// A public variable representing the socket file descriptor.
    /// It is initialized to `-1`.
    public var sockfd: SockFD = -1
    public let host: String
    public let port: String
    public let user: String
    public let timeout: Int
    public let compress: Bool

    /// An array that holds the trace types for SSH operations.
    /// By default, it contains a single element `.none`.
    /// - Note: This property is public and can be accessed and modified from outside the module.
    public var trace: [TraceType] = [.none]
    /// A dictionary that maps `Method` keys to their corresponding string values.
    /// This property is used to store SSH methods and their associated descriptions or identifiers.
    public var methods: [Method: String] = [:]
    /// The algorithm used for SSH fingerprint.
    /// Default value is `ShaAlgorithm.sha1`.
    public var algorithm: ShaAlgorithm = .sha1

    /// A string representing the banner message for the SSH session.
    public var banner = "SSH-2.0-libssh2_\(LIBSSH2_VERSION)-ssh2.app"

    /// The delegate responsible for handling session-related events.
    public var sessionDelegate: SessionDelegate?

    /// The delegate responsible for handling channel-related events.
    public var channelDelegate: ChannelDelegate?

    var lockRow = NSLock()
    var lockSSH2 = NSLock()

    let queue: DispatchQueue = .init(label: "SSH Queue", attributes: .concurrent)
    var socketShell: DispatchSourceRead?

    /// An `OperationQueue` instance used to manage and execute a collection of operations.
    /// This queue allows for the concurrent execution of multiple operations, providing
    /// a way to manage dependencies and priorities among them.
    let job = OperationQueue()

    /// The raw pointers to the SSH session, channel, and SFTP session.
    /// - `rawSession`: A pointer to the SSH session.
    /// - `rawChannel`: A pointer to the SSH channel.
    /// - `rawSFTP`: A pointer to the SFTP session.
    public var rawSession, rawChannel, rawSFTP: OpaquePointer?

    /// Initializes a new SSH connection with the specified parameters.
    ///
    /// - Parameters:
    ///   - host: The hostname or IP address of the SSH server.
    ///   - port: The port number to connect to on the SSH server.
    ///   - user: The username to authenticate with on the SSH server.
    ///   - timeout: The timeout duration for the connection in seconds. Default is 5 seconds.
    ///   - compress: A Boolean value indicating whether to enable compression. Default is true.
    public init(host: String, port: String, user: String, timeout: Int = 5, compress: Bool = true) {
        self.host = host
        self.port = port
        self.user = user
        self.timeout = timeout
        self.compress = compress
        libssh2_init(0)
    }

    /// Closes the SSH connection by performing the following steps:
    /// 1. Shuts down the read side of the connection.
    /// 2. Locks the `lockRow` to ensure thread safety.
    /// 3. Frees any allocated resources.
    /// 4. Shuts down both the read and write sides of the connection.
    public func close() {
        shutdown(.r)
        lockRow.lock()
        defer {
            lockRow.unlock()
        }
        free()
        shutdown(.rw)
    }

    /// Frees the resources associated with the SSH connection.
    ///
    /// This method releases the resources allocated for the SSH channel, SFTP session, and SSH session.
    /// It should be called when the SSH connection is no longer needed to ensure proper cleanup.
    ///
    /// - Note: Ensure that no operations are being performed on the SSH connection before calling this method.
    func free() {
        freeChannel()
        freeSFTP()
        freeSession()
    }

    /// Deinitializer for the SSH class.
    ///
    /// This method is called when the instance of the SSH class is being deallocated.
    /// It ensures that the SSH connection is properly closed and the libssh2 library is
    /// properly cleaned up by calling `close()` and `libssh2_exit()`.
    deinit {
        close()
        libssh2_exit()
    }
}
