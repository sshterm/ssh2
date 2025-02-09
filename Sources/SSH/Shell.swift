// Shell.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import CSSH
import Extension
import Foundation

public extension SSH {
    func shell(type: PtyType = .xterm, width: Int32 = LIBSSH2_TERM_WIDTH, height: Int32 = LIBSSH2_TERM_HEIGHT) async -> Bool {
        await call { [self] in
            rawChannel = newSession()
            guard rawChannel != nil else {
                return false
            }
            var code = callSSH2 {
                libssh2_channel_request_pty_ex(rawChannel, type.name, type.name.count.load(), nil, 0, width, height, LIBSSH2_TERM_WIDTH_PX, LIBSSH2_TERM_HEIGHT_PX)
            }
            guard code == LIBSSH2_ERROR_NONE else {
                closeShell()
                return false
            }
            pollShell()
            code = callSSH2 {
                libssh2_channel_process_startup(rawChannel, "shell", 5, nil, 0)
            }
            guard code == LIBSSH2_ERROR_NONE else {
                closeShell()
                return false
            }
            addOperation {
                channelDelegate?.connect(ssh: self, online: true)
            }
            return true
        }
    }

    func requestPtySize(width: Int32, height: Int32) async -> Bool {
        await call { [self] in
            guard let rawChannel else {
                return false
            }
            let code = callSSH2 {
                libssh2_channel_request_pty_size_ex(rawChannel, width, height, LIBSSH2_TERM_WIDTH_PX, LIBSSH2_TERM_HEIGHT_PX)
            }
            guard code == LIBSSH2_ERROR_NONE else {
                return false
            }
            return true
        }
    }

    func suspendPoll() {
        socketShell?.suspend()
    }

    func resumePoll() {
        socketShell?.resume()
    }

    func setEnv(name: String, value: String) async -> Bool {
        guard let rawChannel else {
            return false
        }
        return await call { [self] in
            let code = callSSH2 {
                libssh2_channel_setenv_ex(rawChannel, name, name.count.load(), value, value.count.load())
            }
            guard code == LIBSSH2_ERROR_NONE else {
                return false
            }
            return true
        }
    }

    func write(data: Data, stderr: Bool = false) async -> Bool {
        guard let rawChannel else {
            return false
        }
        return await call { [self] in
            let code = callSSH2 {
                libssh2_channel_write_ex(rawChannel, stderr ? SSH_EXTENDED_DATA_STDERR : 0, data.bytes, data.count)
            }
            guard code > 0 else {
                return false
            }
            return true
        }
    }

    func read(_ output: OutputStream, err: Bool = false, wait: Bool) -> Int {
        let rc = io.Copy(output, ChannelInputStream(rawChannel: rawChannel, ssh: self, err: err, wait: wait), bufferSize)
        return rc
    }

    func read(_ stdout: OutputStream, _ stderr: OutputStream) -> (Int, Int) {
        var rc, erc: Int
        rc = read(stdout, wait: false)
        erc = read(stderr, err: true, wait: false)
        return (rc, erc)
    }

    func pollShell() {
        libssh2_channel_set_blocking(rawChannel, 0)

        socketShell?.cancel()
        socketShell = nil
        socketShell = DispatchSource.makeReadSource(fileDescriptor: socket.fd, queue: queueSocket)
        socketShell?.setEventHandler { [self] in
            let (rc, erc) = read(PipeOutputStream { data in
                onData(data, true)
                return isPoll
            }, PipeOutputStream { data in
                onData(data, false)
                return isPollError
            })
            guard rc > 0 || erc > 0 else {
                guard rc != LIBSSH2_ERROR_SOCKET_RECV || erc != LIBSSH2_ERROR_SOCKET_RECV else {
                    closeShell()
                    return
                }
                return
            }
            if !isRead {
                closeShell()
            }
        }
        socketShell?.setCancelHandler {
            self.channelDelegate?.connect(ssh: self, online: false)
        }
        socketShell?.resume()
    }

    var isRead: Bool {
        !(receivedEOF || receivedExit) && isConnected
    }

    var receivedExit: Bool {
        guard let rawChannel else {
            return true
        }
        return libssh2_channel_get_exit_status(rawChannel) != 0
    }

    var isPoll: Bool {
        guard let rawChannel = rawChannel else {
            return false
        }
        return libssh2_poll_channel_read(rawChannel, 0) != 0
    }

    var isPollError: Bool {
        guard let rawChannel = rawChannel else {
            return false
        }
        return libssh2_poll_channel_read(rawChannel, SSH_EXTENDED_DATA_STDERR) != 0
    }

    var receivedEOF: Bool {
        guard let rawChannel else {
            return true
        }
        return libssh2_channel_eof(rawChannel) != 0
    }

    func sendEOF() -> Bool {
        guard !receivedEOF else {
            return true
        }
        guard let rawChannel else {
            return false
        }
        let code = callSSH2 {
            libssh2_channel_send_eof(rawChannel)
        }
        guard code == LIBSSH2_ERROR_NONE else {
            return false
        }
        return true
    }

    /// Closes the shell by canceling any active sources.
    ///
    /// This function is responsible for terminating the shell session
    /// by invoking the `cancelShell` method, which cancels any
    /// active sources associated with the shell.
    func closeShell() {
        socketShell?.cancel()
        socketShell = nil
        // sendEOF()
        closed(channel: rawChannel)
    }
}
