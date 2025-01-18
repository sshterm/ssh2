// Stream.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import CSSH
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
        handle != nil && got < size && nread > 0 && libssh2_sftp_last_error(handle) == LIBSSH2_FX_OK
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
        rawSFTP = ssh.callSSH2 { [self] in
            libssh2_sftp_init(ssh.rawSession)
        }
        guard let rawSFTP else {
            return
        }
        handle = libssh2_sftp_open_ex(rawSFTP, remotePath, remotePath.count.load(), UInt(LIBSSH2_FXF_WRITE | LIBSSH2_FXF_CREAT | LIBSSH2_FXF_TRUNC), permissions.rawInt, LIBSSH2_SFTP_OPENFILE)
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
        handle != nil && nwrite > 0 && libssh2_sftp_last_error(handle) == LIBSSH2_FX_OK
    }
}
