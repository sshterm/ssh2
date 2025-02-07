// Channel.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import CSSH
import Darwin
import Extension
import Foundation

public extension SSH {
    func newSession() -> OpaquePointer? {
        callSSH2 { [self] in
            libssh2_channel_open_ex(rawSession, "session", 7, 0x200000, 0x8000, nil, 0)
        }
    }

    func closed(channel: OpaquePointer?) {
        lock.withLock {
            if channel != nil {
                libssh2_channel_wait_closed(channel)
                libssh2_channel_free(channel)
            }
        }
    }

    func isEcho() async -> Bool {
        guard let data = await exec("echo \">TEST<\"", count: 6) else {
            return false
        }
        guard data.string?.trim.hasPrefix(">TEST<") ?? false else {
            return false
        }
        return true
    }

    func exec(_ command: String, _ output: OutputStream) async -> Int {
        await call { [self] in
            guard let rawChannel = newSession() else {
                return -1
            }
            libssh2_channel_set_blocking(rawChannel, 1)
            defer {
                closed(channel: rawChannel)
            }
            let code = callSSH2 {
                libssh2_channel_process_startup(rawChannel, "exec", 4, command, command.count.load())
            }
            guard code == LIBSSH2_ERROR_NONE else {
                return -1
            }
            return io.Copy(output, ChannelInputStream(rawChannel: rawChannel, ssh: self, wait: true), bufferSize)
        }
    }

    func exec(_ command: String, count: Int = 0) async -> Data? {
        var data = Data()
        let rc = await exec(command, PipeOutputStream { d in
            data.append(d)
            if count > 0 {
                return data.count < count
            }
            return true
        })
        guard rc >= 0 else {
            return nil
        }
        return data
    }
}
