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

extension [TraceType] {
    var trace: Int32 {
        var traces: Int32 = 0
        for t in self {
            traces |= t.trace
        }
        return traces
    }
}

public enum Method: String, CaseIterable {
    case kex
    case hostkey
    case crypt_cs
    case crypt_sc
    case mac_cs
    case mac_sc
    case comp_cs
    case comp_sc
    case lang_cs
    case lang_sc
    case sign_algo0

    var value: Int32 {
        switch self {
        case .kex:
            LIBSSH2_METHOD_KEX
        case .hostkey:
            LIBSSH2_METHOD_HOSTKEY
        case .crypt_cs:
            LIBSSH2_METHOD_CRYPT_CS
        case .crypt_sc:
            LIBSSH2_METHOD_CRYPT_SC
        case .mac_cs:
            LIBSSH2_METHOD_MAC_CS
        case .mac_sc:
            LIBSSH2_METHOD_MAC_SC
        case .comp_cs:
            LIBSSH2_METHOD_COMP_CS
        case .comp_sc:
            LIBSSH2_METHOD_COMP_SC
        case .lang_cs:
            LIBSSH2_METHOD_LANG_CS
        case .lang_sc:
            LIBSSH2_METHOD_LANG_SC
        case .sign_algo0:
            LIBSSH2_METHOD_SIGN_ALGO
        }
    }
}
