// SCP.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import CSSH
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
    func send(local: String, remote: String, permissions: FilePermissions = .default, progress: @escaping (_ send: Int) -> Bool) async -> Bool {
        await call { [self] in
            guard let rawSession else {
                return false
            }
            guard let stream = InputStream(fileAtPath: local) else {
                return false
            }
            guard let size = getFileSize(filePath: local) else {
                return false
            }
            let remote = SCPOutputStream(ssh: self, remotePath: remote, permissions: permissions, size: size)
            guard io.Copy(stream, remote, buffer, { send in
                progress(send)
            }) >= 0 else {
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
    func recv(remote: String, local: String, progress: @escaping (_ send: Int, _ size: Int) -> Bool) async -> Bool {
        await call { [self] in
            guard let rawSession else {
                return false
            }
            guard let stream = OutputStream(toFileAtPath: local, append: false) else {
                return false
            }
            let remote = SCPInputStream(ssh: self, remotePath: remote)
            guard io.Copy(remote, stream, buffer, { send in
                progress(send, remote.size)
            }) == remote.size else {
                return false
            }
            return true
        }
    }
}
