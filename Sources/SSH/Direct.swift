// Direct.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/21.

import CSSH
import Foundation

public extension SSH {
    /// The `tcpip` method is used to create an SSH channel over a TCP/IP connection.
    ///
    /// - Parameters:
    ///   - host: The target host address.
    ///   - port: The target host port number.
    ///   - shost: The host that initiates the connection to inform the SSH server.
    ///   - sport: The port from which the connection originates to inform the SSH server.
    /// - Returns: Returns `true` if the channel is successfully created, otherwise returns `false`.
    func tcpip(host: String, port: Int32, shost: String, sport: Int32) async -> Bool {
        await call { [self] in
            guard let rawSession else {
                return false
            }
            freeChannel()
            let rawChannel = callSSH2 {
                libssh2_channel_direct_tcpip_ex(rawSession, host, port, shost, sport)
            }
            guard let rawChannel else {
                return false
            }
            self.rawChannel = rawChannel
            return true
        }
    }

    /// The `streamlocal` method is used to create an SSH channel through a local socket.
    ///
    /// - Parameters:
    ///   - socketpath: The path of the server's local socket.
    ///   - shost: The host that initiates the connection to inform the SSH server.
    ///   - sport: The port from which the connection originates to inform the SSH server.
    /// - Returns: Returns `true` if the channel is successfully created, otherwise returns `false`.
    func streamlocal(socketpath: String, shost: String, sport: Int32) async -> Bool {
        await call { [self] in
            guard let rawSession else {
                return false
            }
            freeChannel()
            let rawChannel = callSSH2 {
                libssh2_channel_direct_streamlocal_ex(rawSession, socketpath, shost, sport)
            }
            guard let rawChannel else {
                return false
            }
            self.rawChannel = rawChannel
            return true
        }
    }
}
