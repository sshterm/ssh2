// SFTP.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import CSSH
import Foundation

public extension SSH {
    /// Opens an SFTP session asynchronously.
    ///
    /// This function initializes an SFTP session using the current SSH session.
    /// It uses the `libssh2_sftp_init` function to create the SFTP session and assigns it to `self.rawSFTP`.
    ///
    /// - Returns: A boolean value indicating whether the SFTP session was successfully opened.
    func openSFTP() async -> Bool {
        await call { [self] in
            guard let rawSession else {
                return false
            }
            freeSFTP()
            let rawSFTP = callSSH2 {
                libssh2_sftp_init(rawSession)
            }
            guard let rawSFTP else {
                return false
            }
            self.rawSFTP = rawSFTP
            return true
        }
    }

    /// A computed property that checks if there is an SFTP error.
    ///
    /// This property returns `true` if `rawSFTP` is `nil` or if the last SFTP error
    /// code is not `LIBSSH2_FX_OK`.
    ///
    /// - Returns: A Boolean value indicating whether there is an SFTP error.
    var isSFTPError: Bool {
        guard let rawSFTP else {
            return true
        }
        return libssh2_sftp_last_error(rawSFTP) != LIBSSH2_FX_OK
    }

    /// Reads the target of a symbolic link at the specified path.
    ///
    /// This function asynchronously reads the target of a symbolic link using the SFTP protocol.
    ///
    /// - Parameter path: The path of the symbolic link to read.
    /// - Returns: A `String` containing the target of the symbolic link if successful, or `nil` if an error occurs.
    ///
    /// This function uses the `libssh2_sftp_symlink_ex` function to read the symbolic link.
    /// If the SFTP session (`rawSFTP`) is not available or if the read operation fails, the function returns `nil`.
    func readlink(path: String) async -> String? {
        await call { [self] in
            guard let rawSFTP else {
                return nil
            }
            let buf: Buffer<CChar> = .init()
            let rc = callSSH2 {
                libssh2_sftp_symlink_ex(rawSFTP, path, path.count.load(), buf.buffer, buffer.load(), LIBSSH2_SFTP_READLINK)
            }
            guard rc > 0 else {
                return nil
            }
            return buf.data(rc.load()).string
        }
    }

    /// Resolves the absolute path of a given symbolic link or relative path.
    ///
    /// This function uses the `libssh2_sftp_symlink_ex` function to resolve the
    /// absolute path of the provided `path`. It returns the resolved path as a
    /// `String` if successful, or `nil` if an error occurs.
    ///
    /// - Parameter path: The symbolic link or relative path to be resolved.
    /// - Returns: The resolved absolute path as a `String`, or `nil` if an error occurs.
    /// - Note: This function is asynchronous and should be called with `await`.
    func realpath(path: String) async -> String? {
        await call { [self] in
            guard let rawSFTP else {
                return nil
            }
            let buf: Buffer<CChar> = .init()
            let rc = callSSH2 {
                libssh2_sftp_symlink_ex(rawSFTP, path, path.count.load(), buf.buffer, buffer.load(), LIBSSH2_SFTP_REALPATH)
            }
            guard rc > 0 else {
                return nil
            }
            return buf.data(rc.load()).string
        }
    }

    /**
     Renames a file on the SFTP server.

     - Parameters:
       - orig: The original name of the file.
       - newname: The new name for the file.

     - Returns: A boolean value indicating whether the rename operation was successful.

     This function uses the `libssh2_sftp_rename_ex` function to rename a file on the SFTP server. It ensures that the rename operation is atomic and can overwrite existing files if necessary. The function is asynchronous and returns `true` if the rename operation succeeds, and `false` otherwise.
     */
    func rename(orig: String, newname: String) async -> Bool {
        await call { [self] in
            guard let rawSFTP else {
                return false
            }
            let rc = callSSH2 {
                libssh2_sftp_rename_ex(rawSFTP, orig, orig.count.load(), newname, newname.count.load(), Int(LIBSSH2_SFTP_RENAME_OVERWRITE | LIBSSH2_SFTP_RENAME_ATOMIC | LIBSSH2_SFTP_RENAME_NATIVE))
            }
            guard rc == LIBSSH2_ERROR_NONE else {
                return false
            }
            return true
        }
    }

    /**
     Creates a directory at the specified path with the given permissions.

     - Parameters:
       - path: The path where the directory should be created.
       - permissions: The permissions to set for the new directory. Defaults to `.default`.

     - Returns: A boolean value indicating whether the directory was successfully created.
     */
    func mkdir(path: String, permissions: FilePermissions = .default) async -> Bool {
        await call { [self] in
            guard let rawSFTP else {
                return false
            }
            let rc = callSSH2 {
                libssh2_sftp_mkdir_ex(rawSFTP, path, path.count.load(), permissions.rawInt)
            }
            guard rc == LIBSSH2_ERROR_NONE else {
                return false
            }
            return true
        }
    }

    /**
     Creates a new file at the specified path with the given permissions.

     - Parameters:
       - path: The path where the new file should be created.
       - permissions: The file permissions to set for the new file. Defaults to `.default`.

     - Returns: A boolean value indicating whether the file was successfully created.

     This function uses the SSH2 protocol to create a new file on a remote server. It opens a handle to the file with write, create, and truncate flags, sets the specified permissions, and then closes the handle.
     */
    func mkfile(path: String, permissions: FilePermissions = .default) async -> Bool {
        await call { [self] in
            guard let rawSFTP else {
                return false
            }
            let handle = callSSH2 {
                libssh2_sftp_open_ex(rawSFTP, path, path.count.load(), UInt(LIBSSH2_FXF_WRITE | LIBSSH2_FXF_CREAT | LIBSSH2_FXF_TRUNC), permissions.rawInt, LIBSSH2_SFTP_OPENFILE)
            }
            guard let handle else {
                return false
            }
            libssh2_sftp_close_handle(handle)
            return true
        }
    }

    /// Removes a directory at the specified path asynchronously.
    ///
    /// - Parameter path: The path of the directory to be removed.
    /// - Returns: A Boolean value indicating whether the directory was successfully removed.
    ///
    /// This function uses the `libssh2_sftp_rmdir_ex` function to remove the directory.
    /// If the `rawSFTP` instance is `nil` or if the removal operation fails, the function returns `false`.
    /// Otherwise, it returns `true`.
    func rmdir(path: String) async -> Bool {
        await call { [self] in
            guard let rawSFTP else {
                return false
            }
            let rc = callSSH2 {
                libssh2_sftp_rmdir_ex(rawSFTP, path, path.count.load())
            }
            guard rc == LIBSSH2_ERROR_NONE else {
                return false
            }
            return true
        }
    }

    /// Asynchronously unlinks (deletes) a file at the specified path on the SFTP server.
    ///
    /// This function uses the `libssh2_sftp_unlink_ex` function to perform the unlink operation.
    ///
    /// - Parameter path: The path of the file to be unlinked.
    /// - Returns: A Boolean value indicating whether the unlink operation was successful.
    /// - Note: This function returns `false` if the `rawSFTP` instance is `nil` or if the unlink operation fails.
    func unlink(path: String) async -> Bool {
        await call { [self] in
            guard let rawSFTP else {
                return false
            }
            let rc = callSSH2 {
                libssh2_sftp_unlink_ex(rawSFTP, path, path.count.load())
            }
            guard rc == LIBSSH2_ERROR_NONE else {
                return false
            }
            return true
        }
    }

    /// Creates a symbolic link at the specified path.
    ///
    /// - Parameters:
    ///   - orig: The original path to which the symbolic link should point.
    ///   - linkpath: The path where the symbolic link should be created.
    /// - Returns: A Boolean value indicating whether the symbolic link was successfully created.
    func symlink(orig: String, linkpath: String) async -> Bool {
        await call { [self] in
            guard let rawSFTP else {
                return false
            }
            let rc = callSSH2 {
                libssh2_sftp_symlink_ex(rawSFTP, orig, orig.count.load(), linkpath.bytes, linkpath.count.load(), LIBSSH2_SFTP_SYMLINK)
            }
            guard rc == LIBSSH2_ERROR_NONE else {
                return false
            }
            return true
        }
    }

    /// Changes the owner and group of a file at the specified path.
    ///
    /// - Parameters:
    ///   - path: The path to the file whose owner and group are to be changed.
    ///   - uid: The user ID to set as the owner of the file.
    ///   - gid: The group ID to set as the group of the file.
    /// - Returns: A Boolean value indicating whether the operation was successful.
    /// - Note: This function is asynchronous and uses the `libssh2` library to perform the operation.
    func chown(path: String, uid: UInt, gid: UInt) async -> Bool {
        await call { [self] in
            guard let rawSFTP else {
                return false
            }
            var attrs = LIBSSH2_SFTP_ATTRIBUTES()
            attrs.flags = UInt(LIBSSH2_SFTP_ATTR_UIDGID)
            attrs.uid = uid
            attrs.gid = gid

            let rc = callSSH2 {
                libssh2_sftp_stat_ex(rawSFTP, path, path.count.load(), LIBSSH2_SFTP_SETSTAT, &attrs)
            }
            guard rc == LIBSSH2_ERROR_NONE else {
                return false
            }
            return true
        }
    }

    /**
     Changes the ownership of a file at the specified path with the given permissions.

     - Parameters:
       - path: The path of the file whose ownership is to be changed.
       - permissions: The new file permissions to be set.

     - Returns: A boolean value indicating whether the operation was successful.

     This function uses the `libssh2_sftp_stat_ex` function to set the file permissions.
     It returns `false` if the `rawSFTP` is `nil` or if the operation fails.
     */
    func chown(path: String, permissions: FilePermissions) async -> Bool {
        await call { [self] in
            guard let rawSFTP else {
                return false
            }
            var attrs = LIBSSH2_SFTP_ATTRIBUTES()
            attrs.flags = UInt(LIBSSH2_SFTP_ATTR_PERMISSIONS)
            attrs.permissions = permissions.rawUInt

            let rc = callSSH2 {
                libssh2_sftp_stat_ex(rawSFTP, path, path.count.load(), LIBSSH2_SFTP_SETSTAT, &attrs)
            }
            guard rc == LIBSSH2_ERROR_NONE else {
                return false
            }
            return true
        }
    }

    /// Retrieves file system statistics for the specified path using the `statvfs` system call.
    ///
    /// - Parameter path: The path for which to retrieve file system statistics. Defaults to the root directory ("/").
    /// - Returns: A `Statvfs` object containing the file system statistics, or `nil` if an error occurs or the SFTP session is not available.
    ///
    /// This function uses the `libssh2_sftp_statvfs` function to obtain file system statistics. It performs the call asynchronously and handles errors by returning `nil` if the operation fails.
    func statvfs(path: String = "/") async -> Statvfs? {
        await call { [self] in
            guard let rawSFTP else {
                return nil
            }
            var st = LIBSSH2_SFTP_STATVFS()
            let code = callSSH2 {
                libssh2_sftp_statvfs(rawSFTP, path, path.count, &st)
            }
            guard code == LIBSSH2_ERROR_NONE else {
                return nil
            }
            return Statvfs(statvfs: st)
        }
    }

    /// Retrieves the file status for a given path asynchronously.
    ///
    /// This function uses the `libssh2_sftp_stat_ex` function to get the file status
    /// and returns a `FileStat` object containing the file attributes if successful.
    ///
    /// - Parameter path: The path of the file to retrieve the status for.
    /// - Returns: A `FileStat` object containing the file attributes if successful, otherwise `nil`.
    /// - Note: This function requires an active SFTP session (`rawSFTP`).
    /// - Important: Ensure that the `rawSFTP` session is valid before calling this function.
    func stat(path: String) async -> FileStat? {
        await call { [self] in
            guard let rawSFTP else {
                return nil
            }
            var st = LIBSSH2_SFTP_ATTRIBUTES()
            let code = callSSH2 {
                libssh2_sftp_stat_ex(rawSFTP, path, path.count.load(), LIBSSH2_SFTP_STAT, &st)
            }
            guard code == LIBSSH2_ERROR_NONE else {
                return nil
            }
            return FileStat(attributes: st)
        }
    }

    /// Opens a directory at the specified path and retrieves its file attributes.
    ///
    /// This function asynchronously opens a directory using the SFTP protocol and reads the file attributes
    /// of the files within the directory. It returns an array of `FileAttributes` objects representing the
    /// files in the directory.
    ///
    /// - Parameter path: The path of the directory to open. Defaults to the root directory ("/").
    /// - Returns: An array of `FileAttributes` objects representing the files in the directory. If the directory
    ///            cannot be opened or read, an empty array is returned.
    func openDir(path: String = "/") async -> [FileAttributes] {
        await call { [self] in
            guard let rawSFTP else {
                return []
            }
            let handle = callSSH2 {
                libssh2_sftp_open_ex(rawSFTP, path, path.count.load(), UInt(LIBSSH2_FXF_READ), 0, LIBSSH2_SFTP_OPENDIR)
            }
            guard let handle else {
                return []
            }
            defer {
                libssh2_sftp_close_handle(handle)
            }
            var data: [FileAttributes] = []
            var rc: Int32
            let maxLen = 512
            let buffer: Buffer<CChar> = .init(maxLen)
            let longEntry: Buffer<CChar> = .init(maxLen)
            var attrs = LIBSSH2_SFTP_ATTRIBUTES()
            repeat {
                rc = callSSH2 {
                    libssh2_sftp_readdir_ex(handle, buffer.buffer, maxLen, longEntry.buffer, maxLen, &attrs)
                }
                if rc > 0 {
                    guard let name = buffer.data.string,!ignoredFiles.contains(name) else {
                        continue
                    }
                    guard let longname = longEntry.data.string else {
                        continue
                    }
                    data.append(FileAttributes(name: name, longname: longname, attributes: attrs))
                }
            } while rc > 0
            return data
        }
    }

    /// Uploads a local data to a remote location with specified permissions and progress tracking.
    ///
    /// - Parameters:
    ///   - local: The local data to be uploaded.
    ///   - remote: The remote file path where the data will be uploaded.
    ///   - permissions: The file permissions to be set for the remote file. Defaults to `.default`.
    ///   - progress: A closure that is called with the number of bytes sent. Returns a boolean indicating whether to continue the upload.
    ///
    /// - Returns: A boolean indicating whether the upload was successful.
    func upload(local: Data, remote: String, permissions: FilePermissions = .default, progress: @escaping (_ send: Int) -> Bool = { _ in true }) async -> Bool {
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
    func upload(local: String, remote: String, permissions: FilePermissions = .default, progress: @escaping (_ send: Int) -> Bool = { _ in true }) async -> Bool {
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
    func download(remote: String, progress: @escaping (_ send: Int, _ size: Int) -> Bool = { _, _ in true }) async -> Data? {
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
    func download(remote: String, local: String, progress: @escaping (_ send: Int, _ size: Int) -> Bool = { _, _ in true }) async -> Bool {
        guard let stream = OutputStream(toFileAtPath: local, append: false) else {
            return false
        }
        return await download(remote: remote, local: stream, progress: progress)
    }

    /// Uploads a local file to a remote location via SFTP.
    ///
    /// - Parameters:
    ///   - local: The input stream of the local file to be uploaded.
    ///   - remote: The remote file path where the file will be uploaded.
    ///   - permissions: The file permissions to set on the remote file. Defaults to `.default`.
    ///   - progress: A closure that is called with the number of bytes sent. Returns a boolean indicating whether to continue the upload.
    ///
    /// - Returns: A boolean indicating whether the upload was successful.
    func upload(local: InputStream, remote: String, permissions: FilePermissions = .default, progress: @escaping (_ send: Int) -> Bool = { _ in true }) async -> Bool {
        await call { [self] in
            let remote = SFTPOutputStream(ssh: self, remotePath: remote, permissions: permissions)
            guard io.Copy(local, remote, buffer, { send in
                progress(send)
            }) >= 0 else {
                return false
            }
            return true
        }
    }

    /// Downloads a file from a remote path to a local output stream with progress tracking.
    ///
    /// - Parameters:
    ///   - remote: The remote file path to download from.
    ///   - local: The local `OutputStream` to write the downloaded data to.
    ///   - progress: A closure that is called with the number of bytes sent and the total size of the remote file.
    ///               The closure should return `true` to continue the download or `false` to cancel it.
    /// - Returns: A boolean value indicating whether the download was successful.
    func download(remote: String, local: OutputStream, progress: @escaping (_ send: Int, _ size: Int) -> Bool = { _, _ in true }) async -> Bool {
        await call { [self] in
            let remote = SFTPInputStream(ssh: self, remotePath: remote)
            guard io.Copy(remote, local, buffer, { send in
                progress(send, remote.size)
            }) == remote.size else {
                return false
            }
            return true
        }
    }

    /// Retrieves the size of a file at the specified file path.
    ///
    /// This function checks if the file exists and is not a directory, then retrieves its size using the file attributes.
    ///
    /// - Parameter filePath: The path to the file whose size is to be determined.
    /// - Returns: The size of the file in bytes as an `Int64` if the file exists and is not a directory, otherwise `nil`.
    func getFileSize(filePath: String) -> Int64? {
        let fileManager = FileManager.default
        var fileSize: Int64?
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: filePath, isDirectory: &isDir) {
            if !isDir.boolValue {
                if let attr = try? fileManager.attributesOfItem(atPath: filePath) {
                    fileSize = attr[FileAttributeKey.size] as? Int64
                }
            }
        }
        return fileSize
    }

    /**
     Frees the SFTP session by shutting it down and setting the `rawSFTP` property to `nil`.

     This method locks the `lockSSH2` mutex before performing the shutdown operation to ensure thread safety.
     The lock is released automatically after the shutdown operation is completed.

     If `rawSFTP` is `nil`, this method does nothing.
     */
    func freeSFTP() {
        if let rawSFTP {
            lockSSH2.lock()
            defer {
                lockSSH2.unlock()
            }
            libssh2_sftp_shutdown(rawSFTP)
            self.rawSFTP = nil
        }
    }
}
