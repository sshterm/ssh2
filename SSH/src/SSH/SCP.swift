// SCP.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import CSSH
import Foundation

public extension SSH {
    /// Uploads a local data to a remote location with specified permissions and progress tracking.
    ///
    /// - Parameters:
    ///   - local: The local data to be uploaded.
    ///   - remote: The remote file path where the data will be uploaded.
    ///   - permissions: The file permissions to be set for the remote file. Defaults to `.default`.
    ///   - progress: A closure that is called with the number of bytes sent. Returns a boolean indicating whether to continue the upload.
    ///
    /// - Returns: A boolean indicating whether the upload was successful.
    func upload(local: Data, remote: String, permissions: FilePermissions = .default, progress: @escaping (_ send: Int) -> Bool) async -> Bool {
        await upload(local: InputStream(data: local), remote: remote, permissions: permissions, progress: progress)
    }

    /// Uploads a local file to a remote location with specified permissions and progress tracking.
    ///
    /// - Parameters:
    ///   - local: The path to the local file to be uploaded.
    ///   - remote: The remote destination path where the file will be uploaded.
    ///   - permissions: The file permissions to be set for the uploaded file. Defaults to `.default`.
    ///   - progress: A closure that is called with the number of bytes sent. Returns a boolean indicating whether to continue the upload.
    ///
    /// - Returns: A boolean indicating whether the upload was successful.
    func upload(local: String, remote: String, permissions: FilePermissions = .default, progress: @escaping (_ send: Int) -> Bool) async -> Bool {
        guard let stream = InputStream(fileAtPath: local) else {
            return false
        }
        return await upload(local: stream, remote: remote, permissions: permissions, progress: progress)
    }

    /// Downloads a remote file and returns its data.
    ///
    /// - Parameters:
    ///   - remote: The path to the remote file to be downloaded.
    ///   - progress: A closure that is called with the current progress of the download.
    ///               The closure takes two parameters: `send` which is the number of bytes sent,
    ///               and `size` which is the total size of the file. The closure returns a `Bool`
    ///               indicating whether the download should continue.
    ///
    /// - Returns: The data of the downloaded file, or `nil` if the download failed.
    func download(remote: String, progress: @escaping (_ send: Int, _ size: Int) -> Bool) async -> Data? {
        let stream = OutputStream.toMemory()
        guard await download(remote: remote, local: stream, progress: progress) else {
            return nil
        }
        return stream.data
    }

    /// Downloads a file from a remote path to a local path.
    ///
    /// - Parameters:
    ///   - remote: The remote file path to download from.
    ///   - local: The local file path to download to.
    ///   - progress: A closure that is called with the current progress of the download.
    ///     - send: The number of bytes sent so far.
    ///     - size: The total size of the file being downloaded.
    ///     - Returns: A Boolean value indicating whether the download should continue.
    /// - Returns: A Boolean value indicating whether the download was successful.
    func download(remote: String, local: String, progress: @escaping (_ send: Int, _ size: Int) -> Bool) async -> Bool {
        guard let stream = OutputStream(toFileAtPath: local, append: false) else {
            return false
        }
        return await download(remote: remote, local: stream, progress: progress)
    }
}
