// Direct.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/21.

import CSSH
import Foundation

public extension SSH {
    func tcpip(host: String, port: Int32, shost: String, sport: Int32) async -> OpaquePointer? {
        await call { [self] in
            guard let rawSession else {
                return nil
            }

            let rawChannel = callSSH2 {
                libssh2_channel_direct_tcpip_ex(rawSession, host, port, shost, sport)
            }
            return rawChannel
        }
    }

    func streamlocal(socketpath: String, shost: String, sport: Int32) async -> OpaquePointer? {
        await call { [self] in
            guard let rawSession else {
                return nil
            }
            let rawChannel = callSSH2 {
                libssh2_channel_direct_streamlocal_ex(rawSession, socketpath, shost, sport)
            }
            return rawChannel
        }
    }

    func receivedEOF(channel _: OpaquePointer?) -> Bool {
        guard let rawChannel else {
            return true
        }
        return libssh2_channel_eof(rawChannel) != 0
    }

    func close(channel: OpaquePointer?) {
        guard channel != nil else {
            return
        }
        libssh2_channel_free(channel)
    }
}
