// BufferData.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import Foundation

/// A generic structure that holds two buffers: one for length and one for data.
///
/// - Parameters:
///   - V: The type of data stored in the data buffer.
///   - L: The type of data stored in the length buffer.
struct BufferData<V, L> where L: FixedWidthInteger {
    /// Initializes a buffer with the size of the memory layout of type `L`.
    /// - Note: `Buffer` is a generic type that takes a type parameter `L`.
    let len: Buffer<L> = .init(MemoryLayout<L>.size)

    /// A buffer that holds data of type `V`.
    ///
    /// - Note: This buffer is part of the SSH Term v7 project and is located in the `Crypto` module.
    let buf: Buffer<V>

    /// Initializes a new instance of the buffer with the specified capacity.
    ///
    /// - Parameter capacity: The capacity of the buffer.
    init(_ capacity: Int) {
        buf = Buffer<V>(capacity)
    }

    /// A computed property that returns a `Data` object initialized with the bytes from the buffer.
    /// The length of the data is determined by loading the value from the `len` address.
    /// - Returns: A `Data` object containing the bytes from the buffer.
    var data: Data {
        return Data(bytes: buf.buffer, count: len.address.load())
    }
}
