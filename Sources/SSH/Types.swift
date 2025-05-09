// Types.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import CSSH
import Darwin
import Foundation

/// An enumeration representing different types of SSH host keys.
///
/// - unknown: Represents an unknown host key type.
/// - rsa: Represents an RSA host key type.
/// - dss: Represents a DSS (DSA) host key type.
/// - ecdsa_256: Represents an ECDSA host key type with a 256-bit key.
/// - ecdsa_384: Represents an ECDSA host key type with a 384-bit key.
/// - ecdsa_521: Represents an ECDSA host key type with a 521-bit key.
/// - ed25519: Represents an Ed25519 host key type.
///
/// This enumeration conforms to the `CaseIterable` protocol, allowing iteration over all cases.
///
/// - Parameters:
///   - rawValue: An `Int32` value representing the raw value of the host key type.
///
/// - Returns: An instance of `HostkeyType` corresponding to the provided raw value.
///
/// The initializer maps the raw value to the corresponding `HostkeyType` case based on the following values:
/// - `LIBSSH2_HOSTKEY_TYPE_UNKNOWN`: Maps to `.unknown`
/// - `LIBSSH2_HOSTKEY_TYPE_RSA`: Maps to `.rsa`
/// - `LIBSSH2_HOSTKEY_TYPE_DSS`: Maps to `.dss`
/// - `LIBSSH2_HOSTKEY_TYPE_ECDSA_256`: Maps to `.ecdsa_256`
/// - `LIBSSH2_HOSTKEY_TYPE_ECDSA_384`: Maps to `.ecdsa_384`
/// - `LIBSSH2_HOSTKEY_TYPE_ECDSA_521`: Maps to `.ecdsa_521`
/// - `LIBSSH2_HOSTKEY_TYPE_ED25519`: Maps to `.ed25519`
/// - Any other value: Maps to `.unknown`
public enum HostkeyType: String, CaseIterable {
    case unknown, rsa, dss, ecdsa_256, ecdsa_384, ecdsa_521, ed25519

    public init(rawValue: Int32) {
        switch rawValue {
        case LIBSSH2_HOSTKEY_TYPE_RSA:
            self = .rsa
        case LIBSSH2_HOSTKEY_TYPE_DSS:
            self = .dss
        case LIBSSH2_HOSTKEY_TYPE_ECDSA_256:
            self = .ecdsa_256
        case LIBSSH2_HOSTKEY_TYPE_ECDSA_384:
            self = .ecdsa_384
        case LIBSSH2_HOSTKEY_TYPE_ECDSA_521:
            self = .ecdsa_521
        case LIBSSH2_HOSTKEY_TYPE_ED25519:
            self = .ed25519
        default:
            self = .unknown
        }
    }
}

/// A structure representing a host key used in SSH connections.
///
/// The `Hostkey` structure contains the key data and its type.
///
/// - Properties:
///   - data: The raw data of the host key.
///   - type: The type of the host key, represented by the `HostkeyType` enum.
public struct Hostkey {
    public let data: Data
    public let type: HostkeyType
}

/// An enumeration representing different types of pseudo-terminals (PTY).
///
/// - vanilla: A basic PTY type with no special features.
/// - vt100: A PTY type emulating the VT100 terminal.
/// - vt102: A PTY type emulating the VT102 terminal.
/// - vt220: A PTY type emulating the VT220 terminal.
/// - ansi: A PTY type with ANSI escape codes support.
/// - xterm: A PTY type emulating the Xterm terminal.
public enum PtyType: String, CaseIterable {
    case vanilla, vt100, vt102, vt220, ansi, xterm

    var name: String {
        rawValue
    }
}

/// An enumeration representing different types of SSH trace levels.
/// Each case corresponds to a specific trace level used in SSH operations.
///
/// - trans: Transport layer tracing.
/// - kex: Key exchange tracing.
/// - auth: Authentication tracing.
/// - conn: Connection tracing.
/// - scp: SCP (Secure Copy Protocol) tracing.
/// - sftp: SFTP (SSH File Transfer Protocol) tracing.
/// - error: Error tracing.
/// - publickey: Public key tracing.
/// - socket: Socket tracing.
/// - all: Enable all tracing.
/// - none: Disable all tracing.
///
/// The `trace` computed property returns the corresponding `Int32` value
/// for each trace type, which is used by the underlying SSH library.
public enum TraceType: String, CaseIterable {
    case trans, kex, auth, conn, scp, sftp, error, publickey, socket, all, none

    var trace: Int32 {
        switch self {
        case .trans:
            LIBSSH2_TRACE_TRANS
        case .kex:
            LIBSSH2_TRACE_KEX
        case .auth:
            LIBSSH2_TRACE_AUTH
        case .conn:
            LIBSSH2_TRACE_CONN
        case .scp:
            LIBSSH2_TRACE_SCP
        case .sftp:
            LIBSSH2_TRACE_SFTP
        case .error:
            LIBSSH2_TRACE_ERROR
        case .publickey:
            LIBSSH2_TRACE_PUBLICKEY
        case .socket:
            LIBSSH2_TRACE_SOCKET
        case .all:
            ~0
        case .none:
            0
        }
    }
}

/// Extension for an array of `TraceType` to compute the combined trace value.
extension [TraceType] {
    /// Computes the combined trace value for an array of `TraceType`.
    ///
    /// This property iterates through the array of `TraceType` and combines their trace values using the bitwise OR operation.
    ///
    /// - Returns: An `Int32` value representing the combined trace value.
    var trace: Int32 {
        var traces: Int32 = 0
        for t in self {
            traces |= t.trace
        }
        return traces
    }
}

/// Represents various SSH methods used in the SSH protocol.
public enum MethodType: String, CaseIterable {
    case kex // Key exchange method
    case hostkey // Host key method
    case crypt_cs // Encryption method for client to server
    case crypt_sc // Encryption method for server to client
    case mac_cs // MAC (Message Authentication Code) method for client to server
    case mac_sc // MAC (Message Authentication Code) method for server to client
    case comp_cs // Compression method for client to server
    case comp_sc // Compression method for server to client
    case lang_cs // Language method for client to server
    case lang_sc // Language method for server to client
    case sign_algo0 // Signature algorithm method

    /// Returns the corresponding `Int32` value for each SSH method.
    var value: Int32 {
        switch self {
        case .kex:
            return LIBSSH2_METHOD_KEX
        case .hostkey:
            return LIBSSH2_METHOD_HOSTKEY
        case .crypt_cs:
            return LIBSSH2_METHOD_CRYPT_CS
        case .crypt_sc:
            return LIBSSH2_METHOD_CRYPT_SC
        case .mac_cs:
            return LIBSSH2_METHOD_MAC_CS
        case .mac_sc:
            return LIBSSH2_METHOD_MAC_SC
        case .comp_cs:
            return LIBSSH2_METHOD_COMP_CS
        case .comp_sc:
            return LIBSSH2_METHOD_COMP_SC
        case .lang_cs:
            return LIBSSH2_METHOD_LANG_CS
        case .lang_sc:
            return LIBSSH2_METHOD_LANG_SC
        case .sign_algo0:
            return LIBSSH2_METHOD_SIGN_ALGO
        }
    }
}

public enum AuthType: String, CaseIterable {
    case none, password, publickey, keyboard // , hostbased

    public var name: String {
        switch self {
        case .none:
            "None"
        case .password:
            "Password"
        case .publickey:
            "Public Key"
        case .keyboard:
            "Keyboard Interactive"
//        case .hostbased:
//            "Host Based"
        }
    }
}

/// A structure representing a connection configuration.
///
/// The `Connect` structure conforms to `Identifiable`, `Equatable`, `Hashable`, and `Codable` protocols,
/// making it suitable for use in SwiftUI, collections, and serialization.
///
/// - Properties:
///   - `id`: A unique identifier for the connection, automatically generated as a `UUID`.
///   - `user`: The username for the connection.
///   - `host`: The hostname or IP address of the server.
///   - `port`: The port number for the connection, represented as a string.
///   - `password`: The password for the connection.
///
/// - Note:
///   The `CodingKeys` enum is used to specify the keys for encoding and decoding the structure.
public struct Connect: Identifiable, Equatable, Hashable, Codable {
    public let id: UUID = .init()
    public let user: String
    public let host: String
    public let port: String
    public let password: String
    public init(user: String, host: String, port: String, password: String) {
        self.user = user
        self.host = host
        self.port = port
        self.password = password
    }

    public enum CodingKeys: String, CodingKey {
        case user, host, port, password
    }
}

/// An enumeration representing different types of containerization platforms.
///
/// - `docker`: Represents the Docker containerization platform.
/// - `podman`: Represents the Podman containerization platform.
///
/// Each case has an associated `command` property that returns the raw string value of the case.
public enum ContainerType: String, CaseIterable {
    case docker, podman

    var command: String {
        rawValue
    }
}
