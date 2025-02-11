// SCP.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import CSSH
import Extension
import Foundation

public extension SSH {
    /// Sends a file from a local path to a remote path using SCP (Secure Copy Protocol).
    ///
    /// - Parameters:
    ///   - local: The local file path of the file to be sent.
    ///   - remote: The remote file path where the file will be sent.
    ///   - permissions: The file permissions to be set on the remote file. Defaults to `.default`.
    ///   - progress: A closure that is called with the number of bytes sent. Returns a `Bool` indicating whether to continue sending.
    /// - Returns: A `Bool` indicating whether the file was successfully sent.
    func send(local: String, remote: String, permissions: FilePermissions = .default, sftp: Bool = false, progress: @escaping (_ send: Int) -> Bool = { _ in true }) async -> Bool {
        if sftp {
            return await upload(local: local, remote: remote, permissions: permissions, progress: progress)
        }
        guard let stream = InputStream(fileAtPath: local) else {
            return false
        }
        guard let size = getFileSize(filePath: local) else {
            return false
        }
        return await send(local: stream, size: size, remote: remote, permissions: permissions, progress: progress)
    }

    func send(local: InputStream, size: Int64, remote: String, permissions: FilePermissions = .default, sftp: Bool = false, progress: @escaping (_ send: Int) -> Bool = { _ in true }) async -> Bool {
        sftp ? await upload(local: local, remote: remote, permissions: permissions, progress: progress) : await call { [self] in
            let remote = SCPOutputStream(ssh: self, remotePath: remote, permissions: permissions, size: size)
            let rc = io.Copy(local, remote, bufferSize) { send in
                progress(send)
            }
            guard rc >= 0 else {
                return false
            }
            return true
        }
    }

    /// Receives a file from a remote path to a local path asynchronously, with progress tracking.
    ///
    /// - Parameters:
    ///   - remote: The remote file path to receive from.
    ///   - local: The local file path to save the received file.
    ///   - progress: A closure that is called with the number of bytes sent and the total size of the file.
    ///               Returns `true` to continue the transfer, or `false` to cancel it.
    /// - Returns: A Boolean value indicating whether the file was successfully received.
    func recv(remote: String, local: String, sftp: Bool = false, progress: @escaping (_ send: Int, _ size: Int) -> Bool = { _, _ in true }) async -> Bool {
        guard let stream = OutputStream(toFileAtPath: local, append: false) else {
            return false
        }
        return await recv(remote: remote, local: stream, sftp: sftp, progress: progress)
    }

    func recv(remote: String, local: OutputStream, sftp: Bool = false, progress: @escaping (_ send: Int, _ size: Int) -> Bool = { _, _ in true }) async -> Bool {
        sftp ? await download(remote: remote, local: local, progress: progress) : await call { [self] in

            let remote = SCPInputStream(ssh: self, remotePath: remote)
            let rc = io.Copy(remote, local, bufferSize) { send in
                progress(send, remote.size)
            }
            guard rc == remote.size else {
                return false
            }
            return true
        }
    }
}
