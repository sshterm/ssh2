// Stream.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import CSSH
import Extension
import Foundation

class SFTPInputStream: InputStream {
    var ssh: SSH
    let remotePath: String
    var handle, rawSFTP: OpaquePointer?
    var got: Int = 0
    var nread: Int = 0

    var size: Int = 0

    init(ssh: SSH, remotePath: String) {
        self.ssh = ssh
        self.remotePath = remotePath
        super.init()
    }

    override func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int {
        guard let handle else {
            return -1
        }
        nread = ssh.callSSH2 {
            libssh2_sftp_read(handle, buffer, len)
        }
        got += nread
        return nread
    }

    override func open() {
        guard ssh.rawSession != nil else {
            return
        }
        rawSFTP = ssh.callSSH2 { [self] in
            libssh2_sftp_init(ssh.rawSession)
        }
        guard let rawSFTP else {
            return
        }
        var fileinfo = LIBSSH2_SFTP_ATTRIBUTES()

        guard ssh.callSSH2 { [self] in libssh2_sftp_stat_ex(rawSFTP, remotePath, remotePath.count.load(), LIBSSH2_SFTP_STAT, &fileinfo) } == LIBSSH2_ERROR_NONE else {
            libssh2_sftp_shutdown(rawSFTP)
            return
        }
        handle = ssh.callSSH2 { [self] in libssh2_sftp_open_ex(rawSFTP, remotePath, remotePath.count.load(), UInt(LIBSSH2_FXF_READ), 0, LIBSSH2_SFTP_OPENFILE) }

        size = fileinfo.filesize.load()
    }

    override func close() {
        if let handle {
            libssh2_sftp_close_handle(handle)
        }
        if let rawSFTP {
            libssh2_sftp_shutdown(rawSFTP)
        }
    }

    override var hasBytesAvailable: Bool {
        handle != nil && got < size && nread >= 0 && libssh2_sftp_last_error(handle) == LIBSSH2_FX_OK
    }
}

class SFTPOutputStream: OutputStream {
    var ssh: SSH
    let remotePath: String
    var nwrite: Int = 0
    var handle, rawSFTP: OpaquePointer?
    let permissions: FilePermissions

    init(ssh: SSH, remotePath: String, permissions: FilePermissions) {
        self.ssh = ssh
        self.remotePath = remotePath
        self.permissions = permissions
        super.init()
    }

    override func write(_ buffer: UnsafePointer<UInt8>, maxLength len: Int) -> Int {
        guard let handle else {
            return -1
        }
        nwrite = ssh.callSSH2 { libssh2_sftp_write(handle, buffer, len) }
        return nwrite
    }

    override func open() {
        guard ssh.rawSession != nil else {
            return
        }
        rawSFTP = ssh.callSSH2 { [self] in
            libssh2_sftp_init(ssh.rawSession)
        }
        guard let rawSFTP else {
            return
        }
        handle = ssh.callSSH2 { [self] in
            libssh2_sftp_open_ex(rawSFTP, remotePath, remotePath.count.load(), UInt(LIBSSH2_FXF_WRITE | LIBSSH2_FXF_CREAT | LIBSSH2_FXF_TRUNC), permissions.rawInt, LIBSSH2_SFTP_OPENFILE)
        }
    }

    override func close() {
        if let handle {
            libssh2_sftp_close_handle(handle)
        }
        if let rawSFTP {
            libssh2_sftp_shutdown(rawSFTP)
        }
    }

    override var hasSpaceAvailable: Bool {
        handle != nil && nwrite >= 0 && libssh2_sftp_last_error(handle) == LIBSSH2_FX_OK
    }
}

class SCPInputStream: InputStream {
    var ssh: SSH
    let remotePath: String
    var handle: OpaquePointer?
    var got: Int = 0
    var nread: Int = 0

    var size: Int = 0

    init(ssh: SSH, remotePath: String) {
        self.ssh = ssh
        self.remotePath = remotePath
        super.init()
    }

    override func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int {
        guard let handle else {
            return -1
        }
        var amount = len
        if size - got < amount {
            amount = size - got
        }
        nread = ssh.callSSH2 {
            libssh2_channel_read_ex(handle, 0, buffer, amount)
        }
        got += nread
        return nread
    }

    override func open() {
        guard ssh.rawSession != nil else {
            return
        }
        var fileinfo = libssh2_struct_stat()
        handle = ssh.callSSH2 { [self] in
            libssh2_scp_recv2(ssh.rawSession, remotePath, &fileinfo)
        }

        size = fileinfo.st_size.load()
    }

    override func close() {
        if let handle {
            libssh2_channel_send_eof(handle)
            libssh2_channel_free(handle)
        }
    }

    override var hasBytesAvailable: Bool {
        handle != nil && got < size && nread >= 0
    }
}

class SCPOutputStream: OutputStream {
    var ssh: SSH
    let remotePath: String
    var nwrite: Int = 0
    var handle: OpaquePointer?
    let permissions: FilePermissions
    let size: Int64

    init(ssh: SSH, remotePath: String, permissions: FilePermissions, size: Int64) {
        self.ssh = ssh
        self.remotePath = remotePath
        self.permissions = permissions
        self.size = size
        super.init()
    }

    override func write(_ buffer: UnsafePointer<UInt8>, maxLength len: Int) -> Int {
        guard let handle else {
            return -1
        }
        nwrite = ssh.callSSH2 { libssh2_channel_write_ex(handle, 0, buffer, len) }
        return nwrite
    }

    override func open() {
        guard ssh.rawSession != nil else {
            return
        }
        handle = ssh.callSSH2 { [self] in
            libssh2_scp_send64(ssh.rawSession, remotePath, permissions.rawValue, size, 0, 0)
        }
    }

    override func close() {
        if let handle {
            libssh2_channel_send_eof(handle)
            libssh2_channel_free(handle)
        }
    }

    override var hasSpaceAvailable: Bool {
        handle != nil && nwrite >= 0
    }
}

class PipeOutputStream: OutputStream {
    let callback: (Data) -> Bool
    var ok: Bool = true
    init(callback: @escaping (Data) -> Bool) {
        self.callback = callback
        super.init()
    }

    override func write(_ buffer: UnsafePointer<UInt8>, maxLength len: Int) -> Int {
        ok = callback(Data(bytes: buffer, count: len))
        return len
    }

    override func open() {}

    override func close() {}

    override var hasSpaceAvailable: Bool {
        ok
    }
}

class ChannelInputStream: InputStream {
    let handle: OpaquePointer
    let err: Bool
    var nread: Int = 0

    init(handle: OpaquePointer, err: Bool = false) {
        self.handle = handle
        self.err = err
        super.init()
    }

    override func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int {
        nread = libssh2_channel_read_ex(handle, err ? SSH_EXTENDED_DATA_STDERR : 0, buffer, len)
        return nread
    }

    override func open() {}

    override func close() {}

    override var hasBytesAvailable: Bool {
        nread >= 0
    }
}

class ChannelOutputStream: OutputStream {
    let handle: OpaquePointer
    let err: Bool
    var nwrite: Int = 0
    init(handle: OpaquePointer, err: Bool = false) {
        self.handle = handle
        self.err = err
        super.init()
    }

    override func write(_ buffer: UnsafePointer<UInt8>, maxLength len: Int) -> Int {
        nwrite = libssh2_channel_write_ex(handle, err ? SSH_EXTENDED_DATA_STDERR : 0, buffer, len)
        return nwrite
    }

    override func open() {}

    override func close() {}

    override var hasSpaceAvailable: Bool {
        nwrite >= 0
    }
}

class SocketOutput: OutputStream {
    let fd: Socket
    var nwrite: Int = 0
    init(_ fd: Socket) {
        self.fd = fd
        super.init()
    }

    override func write(_ buffer: UnsafePointer<UInt8>, maxLength len: Int) -> Int {
        nwrite = fd.write(buffer, len)
        return nwrite
    }

    override func open() {}

    override func close() {}

    override var hasSpaceAvailable: Bool {
        nwrite >= 0
    }
}

class SocketInput: InputStream {
    let fd: Socket
    var nread: Int = 0
    init(_ fd: Socket) {
        self.fd = fd
        super.init()
    }

    override func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int {
        nread = fd.read(buffer, len)
        return nread
    }

    override func open() {}

    override func close() {}

    override var hasBytesAvailable: Bool {
        nread >= 0
    }
}
