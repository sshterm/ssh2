// File.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import CSSH
import Foundation

public struct FileStat: Identifiable, Equatable {
    public static func == (lhs: FileStat, rhs: FileStat) -> Bool {
        lhs.id == rhs.id
    }

    public let id = UUID()
    // File type
    public let fileType: FileType

    // File size
    public let size: UInt64

    // User ID
    public let userId: UInt

    // Group ID
    public let groupId: UInt

    // File permissions
    public let permissions: FilePermissions

    // Last accessed time
    public let lastAccessed: Date

    // Last modified time
    public let lastModified: Date

    /**
     Initializes the FileStat structure
     - Parameters:
        - attributes: LIBSSH2_SFTP_ATTRIBUTES type attributes containing various file information
     - Returns: If attributes can be successfully parsed, returns a FileStat instance, otherwise returns nil
     */
    init(attributes: LIBSSH2_SFTP_ATTRIBUTES) {
        fileType = FileType(rawValue: Int32(attributes.permissions))
        // Directly assign other attributes
        size = attributes.filesize
        userId = attributes.uid
        groupId = attributes.gid
        permissions = FilePermissions(rawValue: Int32(attributes.permissions))
        lastAccessed = Date(timeIntervalSince1970: Double(attributes.atime))
        lastModified = Date(timeIntervalSince1970: Double(attributes.mtime))
    }
}

public struct FileAttributes: Identifiable, Equatable {
    public static func == (lhs: FileAttributes, rhs: FileAttributes) -> Bool {
        lhs.id == rhs.id
    }

    public let id = UUID()

    // File name
    public let name: String
    // Long file name, may contain user and group information
    public let longname: String

    // File type
    public let fileType: FileType

    // File size
    public let size: Int64

    // File owner
    public let user: String

    // File group
    public let group: String

    // User ID
    public let userId: UInt

    // Group ID
    public let groupId: UInt

    // File permissions
    public let permissions: FilePermissions

    // Last accessed time
    public let lastAccessed: Date

    // Last modified time
    public let lastModified: Date

    /**
     Initializes the FileAttributes instance using LIBSSH2_SFTP_ATTRIBUTES structure

     - Parameters:
        - attributes: LIBSSH2_SFTP_ATTRIBUTES structure containing file attribute information

     - Returns: If fileType can be correctly parsed from attributes.permissions, returns a FileAttributes instance, otherwise returns nil
     */
    init(attributes: LIBSSH2_SFTP_ATTRIBUTES) {
        fileType = FileType(rawValue: Int32(attributes.permissions))
        name = ""
        longname = ""
        size = Int64(attributes.filesize)
        userId = attributes.uid
        groupId = attributes.gid
        permissions = FilePermissions(rawValue: Int32(attributes.permissions))
        lastAccessed = Date(timeIntervalSince1970: Double(attributes.atime))
        lastModified = Date(timeIntervalSince1970: Double(attributes.mtime))
        user = ""
        group = ""
    }

    /**
     Initializes the FileAttributes instance using file name, long name, and LIBSSH2_SFTP_ATTRIBUTES structure

     - Parameters:
        - name: File name
        - longname: Long file name, may contain user and group information
        - attributes: LIBSSH2_SFTP_ATTRIBUTES structure containing file attribute information

     - Returns: If fileType can be correctly parsed from attributes.permissions, returns a FileAttributes instance, otherwise returns nil
     */
    init(name: String, longname: String, attributes: LIBSSH2_SFTP_ATTRIBUTES) {
        fileType = FileType(rawValue: Int32(attributes.permissions))
        self.name = name
        self.longname = longname
        size = Int64(attributes.filesize)
        userId = attributes.uid
        groupId = attributes.gid
        permissions = FilePermissions(rawValue: Int32(attributes.permissions))
        lastAccessed = Date(timeIntervalSince1970: Double(attributes.atime))
        lastModified = Date(timeIntervalSince1970: Double(attributes.mtime))
        user = sftpParseLongname(longname, .owner) ?? ""
        group = sftpParseLongname(longname, .group) ?? ""
    }
}

enum SFTPField: Int {
    case perm = 0 // Permissions
    case fixme // To be fixed
    case owner // Owner
    case group // Group
    case size // Size
    case moon // Month
    case day // Day
    case time // Time
}

/// Parses specific fields from the long file name
///
/// - Parameters:
///   - longname: Long file name string containing multiple fields
///   - field: SFTPField enum value representing the field to be parsed
/// - Returns: If the long file name is valid and the requested field exists, returns the value of the field; otherwise returns nil
func sftpParseLongname(_ longname: String, _ field: SFTPField) -> String? {
    // Split the long file name string by spaces
    let components = longname.split(separator: " ")
    // Check if the number of components is greater than 8 and if the requested field index is within the valid range
    guard components.count > 8, field.rawValue < components.count else { return nil }
    // Return the value of the requested field
    return String(components[field.rawValue])
}

// Permissions struct defines a set of permissions using the OptionSet protocol to implement bitmask operations.
public struct Permissions: OptionSet {
    // rawValue property stores the raw value of the permissions set, which is an unsigned integer.
    public let rawValue: UInt

    // init(rawValue:) is the initializer for the Permissions struct, used to create a permissions instance from a given raw value.
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    // read is a static property representing read permission. Its rawValue is set to 1 shifted left by 1 bit, which is binary 0010.
    public static let read = Permissions(rawValue: 1 << 1)

    // write is a static property representing write permission. Its rawValue is set to 1 shifted left by 2 bits, which is binary 0100.
    public static let write = Permissions(rawValue: 1 << 2)

    // execute is a static property representing execute permission. Its rawValue is set to 1 shifted left by 3 bits, which is binary 1000.
    public static let execute = Permissions(rawValue: 1 << 3)
}

public struct FilePermissions: RawRepresentable {
    // Owner's permissions
    public var owner: Permissions

    // Group's permissions
    public var group: Permissions

    // Others' permissions
    public var others: Permissions

    /**
     Initializes the FilePermissions object

     - Parameters:
        - owner: Permissions object for the file owner
        - group: Permissions object for the file group
        - others: Permissions object for other users
     */
    public init(owner: Permissions, group: Permissions, others: Permissions) {
        self.owner = owner
        self.group = group
        self.others = others
    }

    // Initializer that sets file permissions based on the given raw integer value
    public init(rawValue: Int32) {
        // Initialize permissions sets for owner, group, and others
        var owner: Permissions = []
        var group: Permissions = []
        var others: Permissions = []

        // Check and set read permission for owner
        if rawValue & LIBSSH2_SFTP_S_IRUSR == LIBSSH2_SFTP_S_IRUSR { owner.insert(.read) }
        // Check and set write permission for owner
        if rawValue & LIBSSH2_SFTP_S_IWUSR == LIBSSH2_SFTP_S_IWUSR { owner.insert(.write) }
        // Check and set execute permission for owner
        if rawValue & LIBSSH2_SFTP_S_IXUSR == LIBSSH2_SFTP_S_IXUSR { owner.insert(.execute) }
        // Check and set read permission for group
        if rawValue & LIBSSH2_SFTP_S_IRGRP == LIBSSH2_SFTP_S_IRGRP { group.insert(.read) }
        // Check and set write permission for group
        if rawValue & LIBSSH2_SFTP_S_IWGRP == LIBSSH2_SFTP_S_IWGRP { group.insert(.write) }
        // Check and set execute permission for group
        if rawValue & LIBSSH2_SFTP_S_IXGRP == LIBSSH2_SFTP_S_IXGRP { group.insert(.execute) }
        // Check and set read permission for others
        if rawValue & LIBSSH2_SFTP_S_IROTH == LIBSSH2_SFTP_S_IROTH { others.insert(.read) }
        // Check and set write permission for others
        if rawValue & LIBSSH2_SFTP_S_IWOTH == LIBSSH2_SFTP_S_IWOTH { others.insert(.write) }
        // Check and set execute permission for others
        if rawValue & LIBSSH2_SFTP_S_IXOTH == LIBSSH2_SFTP_S_IXOTH { others.insert(.execute) }

        // Initialize the current object with the set permissions
        self.init(owner: owner, group: group, others: others)
    }

    public var rawUInt: UInt {
        UInt(rawValue)
    }

    public var rawInt: Int {
        Int(rawValue)
    }

    // Calculate and return the raw value of the SFTP file permissions
    public var rawValue: Int32 {
        var flag: Int32 = 0 // Initialize the permissions flag to 0

        // Check if the owner has read permission and update the permissions flag
        if owner.contains(.read) { flag |= LIBSSH2_SFTP_S_IRUSR }
        // Check if the owner has write permission and update the permissions flag
        if owner.contains(.write) { flag |= LIBSSH2_SFTP_S_IWUSR }
        // Check if the owner has execute permission and update the permissions flag
        if owner.contains(.execute) { flag |= LIBSSH2_SFTP_S_IXUSR }

        // Check if the group has read permission and update the permissions flag
        if group.contains(.read) { flag |= LIBSSH2_SFTP_S_IRGRP }
        // Check if the group has write permission and update the permissions flag
        if group.contains(.write) { flag |= LIBSSH2_SFTP_S_IWGRP }
        // Check if the group has execute permission and update the permissions flag
        if group.contains(.execute) { flag |= LIBSSH2_SFTP_S_IXGRP }

        // Check if others have read permission and update the permissions flag
        if others.contains(.read) { flag |= LIBSSH2_SFTP_S_IROTH }
        // Check if others have write permission and update the permissions flag
        if others.contains(.write) { flag |= LIBSSH2_SFTP_S_IWOTH }
        // Check if others have execute permission and update the permissions flag
        if others.contains(.execute) { flag |= LIBSSH2_SFTP_S_IXOTH }

        return flag // Return the calculated raw value of the permissions
    }

    // The mode property is used to get the octal representation of the file permissions.
    // It performs a bitwise AND operation with 0o777 on rawValue and then uses the String format method to convert it to a three-digit octal string.
    public var mode: String {
        String(format: "%03o", rawValue & 0o777)
    }

    /// The default instance of the FilePermissions struct, representing file permissions.
    /// - owner: Permissions for the file owner, default is read and write.
    /// - group: Permissions for the file group, default is read.
    /// - others: Permissions for other users, default is read.
    public static let `default` = FilePermissions(owner: [.read, .write], group: [.read], others: [.read])
}

public struct Statvfs: Identifiable, Equatable {
    public let id = UUID()
    // File system block size
    public let bsize: UInt64
    // System allocated block size
    public let frsize: UInt64
    // Total number of data blocks in the file system
    public let blocks: UInt64
    // Total number of available data blocks
    public let bfree: UInt64
    // Total number of available data blocks for non-superuser
    public let bavail: UInt64
    // Total number of file nodes
    public let files: UInt64
    // Total number of available file nodes
    public let ffree: UInt64
    // Total number of available file nodes for non-superuser
    public let favail: UInt64
    // File system ID
    public let fsid: UInt64
    // File system flags
    public let flag: UInt64
    // Maximum length of file names
    public let namemax: UInt64

    /**
     Initializes the Statvfs structure instance
     - Parameter statvfs: LIBSSH2_SFTP_STATVFS type structure containing file system statistics
     */
    init(statvfs: LIBSSH2_SFTP_STATVFS) {
        bsize = statvfs.f_bsize
        frsize = statvfs.f_frsize
        blocks = statvfs.f_blocks
        bfree = statvfs.f_bfree
        bavail = statvfs.f_bavail
        files = statvfs.f_files
        ffree = statvfs.f_ffree
        favail = statvfs.f_favail
        fsid = statvfs.f_fsid
        flag = statvfs.f_flag
        namemax = statvfs.f_namemax
    }

    public var totalSpace: UInt64 {
        frsize * blocks
    }

    public var freeSpace: UInt64 {
        frsize * bfree
    }
}

public enum FileType: String, CaseIterable {
    case link // Link
    case regularFile // Regular file
    case directory // Directory
    case characterSpecialFile // Character special file
    case blockSpecialFile // Block special file
    case fifo // FIFO queue
    case socket // Socket
    case unknown // Unrecognized file type

    /**
     Initializes the file type enum based on an integer value
     - Parameter rawValue: Integer representation of the file type
     - Returns: Corresponding FileType enum value, returns nil if unrecognized
     */
    public init(rawValue: Int32) {
        switch rawValue & LIBSSH2_SFTP_S_IFMT {
        case LIBSSH2_SFTP_S_IFLNK:
            self = .link
        case LIBSSH2_SFTP_S_IFREG:
            self = .regularFile
        case LIBSSH2_SFTP_S_IFDIR:
            self = .directory
        case LIBSSH2_SFTP_S_IFCHR:
            self = .characterSpecialFile
        case LIBSSH2_SFTP_S_IFBLK:
            self = .blockSpecialFile
        case LIBSSH2_SFTP_S_IFIFO:
            self = .fifo
        case LIBSSH2_SFTP_S_IFSOCK:
            self = .socket
        default:
            self = .unknown
        }
    }

    public var name: String {
        switch self {
        case .link:
            "Link"
        case .regularFile:
            "Regular File"
        case .directory:
            "Directory"
        case .characterSpecialFile:
            "Character"
        case .blockSpecialFile:
            "Block"
        case .fifo:
            "FIFO"
        case .socket:
            "Socket"
        case .unknown:
            "Unknown"
        }
    }
}
