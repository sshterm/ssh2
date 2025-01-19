// Buffer.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import Foundation

/// A generic buffer class that provides a pointer to a buffer of type `T`.
///
/// This class manages an unsafe mutable pointer to a buffer, allowing for low-level memory operations.
/// Use with caution as improper use can lead to undefined behavior or memory leaks.
///
/// - Note: The buffer is allocated with the specified capacity during initialization and must be deallocated
///         when the buffer is no longer needed.
///
/// - Parameter T: The type of elements stored in the buffer.
class Buffer<T> {
    /// A pointer to a buffer of type `T`.
    ///
    /// - Note: This is an unsafe mutable pointer, which means it can be used to modify the data it points to.
    ///         Use with caution as improper use can lead to undefined behavior or memory leaks.
    let buffer: UnsafeMutablePointer<T>

    /// Initializes a new buffer with the specified capacity.
    ///
    /// - Parameter capacity: The number of elements to allocate space for. Defaults to 0.
    init(_ capacity: Int = 0) {
        buffer = UnsafeMutablePointer<T>.allocate(capacity: capacity)
    }

    /// Returns a `Data` object containing the specified number of bytes from the buffer.
    ///
    /// - Parameter count: The number of bytes to include in the `Data` object.
    /// - Returns: A `Data` object containing the specified number of bytes.
    func data(_ count: Int) -> Data {
        Data(bytes: buffer, count: count)
    }

    var data: Data {
        Data(bytes: buffer, count: strlen(buffer))
    }

    /// A computed property that returns the value pointed to by the buffer.
    /// - Returns: The value of type `T` that the buffer points to.
    var pointee: T {
        buffer.pointee
    }

    /// A computed property that returns the address of the buffer as an `UnsafeRawPointer`.
    ///
    /// This property provides access to the raw memory address of the buffer, which can be used
    /// for low-level memory operations.
    ///
    /// - Returns: An optional `UnsafeRawPointer` representing the address of the buffer.
    var address: UnsafeRawPointer {
        buffer.address
    }

    deinit {
        buffer.deallocate()
    }
}
