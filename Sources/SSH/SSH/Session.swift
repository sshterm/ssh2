// Session.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import CSSH
import Foundation

public extension SSH {
    /// Checks if the SSH session is active by attempting to connect and send a version string.
    ///
    /// This function performs the following steps:
    /// 1. Attempts to establish a connection using the `connect` method.
    /// 2. If the connection is successful, it sends a version string "SSH-2.0-SSH2.app" followed by CRLF.
    /// 3. Reads the response from the server to verify if it starts with "SSH-".
    /// 4. If any step fails, it returns `false`.
    /// 5. Ensures that the connection is properly shut down after the check.
    ///
    /// - Returns: A boolean value indicating whether the SSH session is active.
    func checkActive() async -> Bool {
        guard await connect() else {
            return false
        }
        defer {
            shutdown()
        }
        return await call { [self] in
            guard var c = clientbanner.data(using: .ascii) else {
                return false
            }
            c.append([0x0D, 0x0A], count: 2)
            guard sockfd.write(c.bytes, c.count) == c.count else {
                return false
            }
            let buf: Buffer<UInt8> = .init(1)
            var data = Data()
            for _ in 0 ... 3 {
                guard sockfd.read(buf.buffer, 1) == 1 else {
                    return false
                }
                data.append(buf.buffer, count: 1)
            }
            guard let versionString = String(data: data, encoding: .ascii), versionString == "SSH-" else {
                return false
            }
            return true
        }
    }

    /// Initiates the SSH handshake process asynchronously.
    ///
    /// This function performs the necessary steps to establish an SSH connection
    /// with the remote server. It handles the exchange of keys and other
    /// authentication mechanisms required to securely connect to the server.
    ///
    /// - Returns: A Boolean value indicating whether the handshake was successful.
    func handshake() async -> Bool {
        await call { [self] in
            if let rawSession {
                free()
            }

            let disconnect: disconnectType = { sess, reason, message, messageLen, language, languageLen, abstract in
                abstract.ssh.disconnect(sess: sess, reason: reason, message: message, messageLen: messageLen, language: language, languageLen: languageLen)
            }

            let trac: libssh2_trace_handler_func = { sess, _, message, messageLen in
                guard let message else {
                    return
                }
                libssh2_session_abstract(sess).address.ssh.trace(message: message, messageLen: messageLen)
            }
            let send: sendType = { socket, buffer, length, flags, abstract in
                abstract.ssh.send(socket: socket, buffer: buffer, length: length, flags: flags)
            }
            let recv: recvType = { socket, buffer, length, flags, abstract in
                abstract.ssh.recv(socket: socket, buffer: buffer, length: length, flags: flags)
            }
            let debug: debugType = { sess, reason, message, messageLen, language, languageLen, abstract in
                abstract.ssh.debug(sess: sess, reason: reason, message: message, messageLen: messageLen, language: language, languageLen: languageLen)
            }
            rawSession = libssh2_session_init_ex(nil, nil, nil, Unmanaged.passUnretained(self).toOpaque())

            for (key, value) in methods {
                libssh2_session_method_pref(self.rawSession, key.value, value)
            }
            libssh2_session_callback_set2(rawSession, LIBSSH2_CALLBACK_DEBUG, unsafeBitCast(debug, to: cbGenericType.self))
            libssh2_session_set_blocking(rawSession, 1)
            libssh2_trace(rawSession, trace.trace)
            libssh2_trace_sethandler(rawSession, nil, trac)
            libssh2_session_callback_set2(rawSession, LIBSSH2_CALLBACK_DISCONNECT, unsafeBitCast(disconnect, to: cbGenericType.self))
            libssh2_session_callback_set2(rawSession, LIBSSH2_CALLBACK_SEND, unsafeBitCast(send, to: cbGenericType.self))
            libssh2_session_callback_set2(rawSession, LIBSSH2_CALLBACK_RECV, unsafeBitCast(recv, to: cbGenericType.self))
            libssh2_session_flag(rawSession, LIBSSH2_FLAG_COMPRESS, compress ? 1 : 0)
            libssh2_session_flag(rawSession, LIBSSH2_FLAG_SIGPIPE, 1)
            libssh2_session_flag(rawSession, LIBSSH2_FLAG_QUOTE_PATHS, 1)
            libssh2_session_set_timeout(rawSession, timeout * 1000)
            libssh2_session_banner_set(rawSession, clientbanner)
            let rec = callSSH2 {
                libssh2_session_handshake(rawSession, sockfd)
            }
            guard rec == LIBSSH2_ERROR_NONE else {
                freeSession()
                return false
            }
            guard sessionDelegate?.connect(ssh: self, fingerprint: fingerprint(algorithm) ?? "") ?? true else {
                freeSession()
                return false
            }

            return true
        }
    }

    /// A computed property that manages the blocking mode of the SSH session.
    ///
    /// - `isBlocking`: A Boolean value indicating whether the session is in blocking mode.
    /// - `set`: Sets the blocking mode of the session. If `newValue` is `true`, the session is set to blocking mode; otherwise, it is set to non-blocking mode.
    /// - `get`: Returns `true` if the session is in blocking mode, `false` otherwise.
    ///
    /// The property uses `libssh2_session_set_blocking` to set the blocking mode and `libssh2_session_get_blocking` to retrieve the current blocking mode.
    var isBlocking: Bool {
        set {
            if let rawSession {
                libssh2_session_set_blocking(rawSession, newValue ? 1 : 0)
            }
        }
        get {
            guard let rawSession else {
                return false
            }
            return libssh2_session_get_blocking(rawSession) == 1
        }
    }

    /// Generates the fingerprint of the host key using the specified SHA algorithm.
    ///
    /// - Parameter algorithm: The SHA algorithm to use for generating the fingerprint. Defaults to `.sha1`.
    /// - Returns: A string representing the fingerprint of the host key, or `nil` if the host key is not available.
    func fingerprint(_ algorithm: ShaAlgorithm = .sha1) -> String? {
        guard let hostkey else {
            return nil
        }
        let data = Crypto.shared.sha(hostkey.data, algorithm: algorithm)
        return data.fingerprint
    }

    /// Retrieves the host key of the SSH session.
    ///
    /// This computed property returns the host key of the SSH session if available. It uses the `libssh2_session_hostkey`
    /// function to obtain the key and its type. The key is then wrapped in a `Hostkey` object.
    ///
    /// - Returns: An optional `Hostkey` object containing the host key data and type, or `nil` if the session is not available
    ///            or the host key could not be retrieved.
    var hostkey: Hostkey? {
        guard let rawSession else {
            return nil
        }
        let len: Buffer<Int> = .init()
        let type: Buffer<Int32> = .init()
        guard let key = libssh2_session_hostkey(rawSession, len.buffer, type.buffer) else {
            return nil
        }
        return Hostkey(data: Data(bytes: key, count: len.pointee), type: HostkeyType(rawValue: type.pointee))
    }

    /// A computed property that retrieves the server banner from the SSH session.
    ///
    /// This property attempts to get the server banner string from the `rawSession`
    /// using the `libssh2_session_banner_get` function. If `rawSession` is `nil`,
    /// the property returns `nil`.
    ///
    /// - Returns: An optional `String` containing the server banner if available,
    ///            otherwise `nil`.
    var serverbanner: String? {
        guard let rawSession else {
            return nil
        }
        return libssh2_session_banner_get(rawSession).string.trim
    }

    /// A computed property that returns the client banner string.
    /// If the `banner` string starts with "SSH-", it returns the `banner` as is.
    /// Otherwise, it returns a default banner string in the format "SSH-2.0-libssh2_<LIBSSH2_VERSION>-ssh2.app".
    /// - Note: `LIBSSH2_VERSION` is a placeholder for the actual version of libssh2 being used.
    var clientbanner: String {
        banner.hasPrefix("SSH-") ? banner.trim : "SSH-2.0-libssh2_\(LIBSSH2_VERSION)-ssh2.app_\(Self.version)"
    }

    /// A computed property that checks if the SSH session is using compression.
    ///
    /// This property returns `true` if both the client-to-server and server-to-client
    /// compression methods have a prefix of "zlib", indicating that compression is enabled
    /// in both directions. Otherwise, it returns `false`.
    ///
    /// - Returns: A Boolean value indicating whether the SSH session is compressed.
    var isComp: Bool {
        methods(.comp_cs)?.hasPrefix("zlib") ?? false && methods(.comp_sc)?.hasPrefix("zlib") ?? false
    }

    /// Retrieves the available methods for a given type from the SSH session.
    ///
    /// - Parameter type: The type of method to retrieve.
    /// - Returns: A string representing the available methods for the specified type, or `nil` if the session or methods could not be retrieved.
    func methods(_ type: Method) -> String? {
        guard let rawSession else {
            return nil
        }
        guard let methods = libssh2_session_methods(rawSession, type.value) else {
            return nil
        }
        return methods.string
    }

    /// Frees the current SSH session.
    ///
    /// This method releases the resources associated with the current SSH session
    /// by calling `libssh2_session_free` on the `rawSession` if it exists, and then
    /// sets `rawSession` to `nil`.
    func freeSession() {
        if let rawSession {
            if isConnected {
                libssh2_session_disconnect_ex(rawSession, SSH_DISCONNECT_BY_APPLICATION, "Bye-Bye", "")
            }
            lockSSH2.lock()
            defer {
                lockSSH2.unlock()
            }
            libssh2_session_free(rawSession)
            self.rawSession = nil
        }
    }
}
