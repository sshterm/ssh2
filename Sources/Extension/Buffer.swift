// Buffer.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/18.

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
public class Buffer<T> {
    /// A pointer to a buffer of type `T`.
    ///
    /// - Note: This is an unsafe mutable pointer, which means it can be used to modify the data it points to.
    ///         Use with caution as improper use can lead to undefined behavior or memory leaks.
    public let buffer: UnsafeMutablePointer<T>

    /// The capacity of the buffer.
    /// This property represents the maximum number of elements that the buffer can hold.
    public var capacity: Int

    /// Initializes a buffer with the specified capacity.
    ///
    /// - Parameter capacity: The number of elements to allocate space for.
    ///   Defaults to the size of the type `T`.
    ///
    /// - Note: The buffer is allocated using `UnsafeMutablePointer<T>.allocate`.
    public init(_ capacity: Int = MemoryLayout<T>.size) {
        buffer = UnsafeMutablePointer<T>.allocate(capacity: capacity)
        self.capacity = capacity
    }

    deinit {
        buffer.deallocate()
    }
}

public extension Buffer {
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
}

/// A generic structure that holds two buffers: one for length and one for data.
///
/// - Parameters:
///   - V: The type of data stored in the data buffer.
///   - L: The type of data stored in the length buffer.
public struct BufferData<V, L> where L: FixedWidthInteger {
    /// A buffer of type `Buffer<L>` initialized with default values.
    /// This buffer is used to store data of type `L`.
    public let len: Buffer<L> = .init()

    /// A buffer that holds data of type `V`.
    ///
    /// - Note: This buffer is part of the SSH Term v7 project and is located in the `Crypto` module.
    public let buf: Buffer<V>

    /// Initializes a new instance of the buffer with the specified capacity.
    ///
    /// - Parameter capacity: The capacity of the buffer.
    public init(_ capacity: Int) {
        buf = Buffer<V>(capacity)
    }
}

public extension BufferData {
    /// A computed property that returns a `Data` object initialized with the bytes from the buffer.
    /// The length of the data is determined by loading the value from the `len` address.
    /// - Returns: A `Data` object containing the bytes from the buffer.
    var data: Data {
        return Data(bytes: buf.buffer, count: len.address.load())
    }
}
