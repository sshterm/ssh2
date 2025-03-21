// SSH.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import Crypto
import CSSH
import Extension
import Foundation
import Network
import Proxy
import Socket

public class SSH {
    /// The current version of the SSH library.
    ///
    /// This constant holds the version number of the SSH library as a string.
    /// It can be used to check the version of the library being used in the project.
    public static let version = "0.0.2"

    /// A constant representing the version of the libssh2 library being used.
    /// This value is defined by the `LIBSSH2_VERSION` macro.
    public static let libssh2_version = LIBSSH2_VERSION

    public static var traceFD: Int32 = -1

    /// The size of the buffer used for SSH operations.
    ///
    /// This property defines the size of the buffer in bytes. The default value is set to 0x4000 (16384 bytes).
    public var buffersize = 0x4000

    /// An array of filenames that should be ignored.
    ///
    /// This array contains the default filenames `"."` and `".."` which are typically used to represent the current directory and the parent directory, respectively.
    public var ignoredfiles: [String] = [".", "..", ".DS_Store"]

    public internal(set) var socket: Socket = .init()
    public let host: String
    public let port: String
    public var user: String
    public let timeout: Int
    public let compress: Bool

    /// An array that holds the trace types for SSH operations.
    /// By default, it contains a single element `.none`.
    /// - Note: This property is public and can be accessed and modified from outside the module.
    public var trace: [TraceType] = [.none]
    /// A dictionary that maps `Method` keys to their corresponding string values.
    /// This property is used to store SSH methods and their associated descriptions or identifiers.
    public var methods: [MethodType: String] = [:]
    /// The algorithm used for SSH fingerprint.
    /// Default value is `ShaAlgorithm.sha1`.
    public var algorithm: ShaAlgorithm = .sha1

    /// A string representing the banner message for the SSH session.
    public var banner = ""

    public var proxy: ProxyConfig?

    /// A Boolean property that determines whether the SSH connection operates in blocking mode.
    ///
    /// When `true`, the connection will block the execution of the program until the operation completes.
    /// When `false`, the connection will operate in non-blocking mode, allowing the program to continue execution
    /// while the operation is still in progress.
    public var blocking: Bool = true

    /// The delegate responsible for handling session-related events.
    public var sessionDelegate: SessionDelegate?

    /// The delegate responsible for handling channel-related events.
    public var channelDelegate: ChannelDelegate?

    let lock = NSLock()
    let waitGroup = WaitGroup()

    let queueSocket: DispatchQueue = .main
    let queueKeep: DispatchQueue = .init(label: "ssh.ssh2.app", qos: .background, attributes: .concurrent)
    var socketShell: DispatchSourceRead?
    var keepAliveSource: DispatchSourceTimer?

    /// An `OperationQueue` instance used to manage and execute a collection of operations.
    /// This queue allows for the concurrent execution of multiple operations, providing
    /// a way to manage dependencies and priorities among them.
    let job: OperationQueue = .main

    /// The raw pointers to the SSH session, channel, and SFTP session.
    /// - `rawSession`: A pointer to the SSH session.
    /// - `rawChannel`: A pointer to the SSH channel.
    /// - `rawSFTP`: A pointer to the SFTP session.
    public internal(set) var rawSession, rawChannel, rawSFTP: OpaquePointer?

    public internal(set) var send: Int64 = 0
    public internal(set) var recv: Int64 = 0
    public internal(set) var isFree: Bool = false

    public internal(set) var error: String?

    public var encoding: String.Encoding = .utf8

    var flowSource: DispatchSourceTimer?

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

    public init(_ connect: Connect) {
        host = connect.host
        port = connect.port
        user = connect.user
        timeout = 5
        compress = true
        libssh2_init(0)
    }

    deinit {
        libssh2_exit()
    }
}
