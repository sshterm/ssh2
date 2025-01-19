// Darwin+.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import Darwin
import Foundation

// Define the number of file descriptors each fd_set can hold
let __fd_set_count = Int(__DARWIN_FD_SETSIZE) / 32

public extension Darwin.fd_set {
    // Inline function to calculate the position and mask of a file descriptor in fd_set
    @inline(__always)
    private static func address(for fd: Int32) -> (Int, Int32) {
        let intOffset = Int(fd) / __fd_set_count
        let bitOffset = Int(fd) % __fd_set_count
        let mask = Int32(bitPattern: UInt32(1 << bitOffset))
        return (intOffset, mask)
    }

    /// Sets all bits in the fd_set to 0
    mutating func zero() {
        withCArrayAccess { $0.initialize(repeating: 0, count: __fd_set_count) }
    }

    /// Sets a file descriptor in the fd_set
    /// - Parameter fd: The file descriptor to add to the fd_set
    mutating func set(_ fd: Int32) {
        let (index, mask) = fd_set.address(for: fd)
        withCArrayAccess { $0[index] |= mask }
    }

    /// Clears a file descriptor from the fd_set
    /// - Parameter fd: The file descriptor to clear from the fd_set
    mutating func clear(_ fd: Int32) {
        let (index, mask) = fd_set.address(for: fd)
        withCArrayAccess { $0[index] &= ~mask }
    }

    /// Checks if a file descriptor is set in the fd_set
    /// - Parameter fd: The file descriptor to check
    /// - Returns: `True` if the file descriptor is set, otherwise `false`
    mutating func isSet(_ fd: Int32) -> Bool {
        let (index, mask) = fd_set.address(for: fd)
        return withCArrayAccess { $0[index] & mask != 0 }
    }

    // Inline function to safely access the internal array of fd_set
    @inline(__always)
    internal mutating func withCArrayAccess<T>(block: (UnsafeMutablePointer<Int32>) throws -> T) rethrows -> T {
        return try withUnsafeMutablePointer(to: &fds_bits) {
            try block(UnsafeMutableRawPointer($0).assumingMemoryBound(to: Int32.self))
        }
    }
}
