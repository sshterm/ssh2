// RawPointer+.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import Foundation

/// An extension to `UnsafeRawPointer` that provides additional functionality.
///
/// This extension includes methods for loading data of a specified type and accessing SSH-related data.
public extension UnsafeRawPointer {
    /// Loads data of the specified type from the raw pointer.
    ///
    /// - Returns: The data of type `T` loaded from the raw pointer.
    func load<T>() -> T {
        load(as: T.self)
    }
}

public extension UnsafeMutablePointer {
    /// A computed property that returns an `UnsafeRawPointer` pointing to the memory address of the current instance.
    ///
    /// - Returns: An `UnsafeRawPointer` pointing to the memory address of the current instance.
    var address: UnsafeRawPointer {
        UnsafeRawPointer(self)
    }

    /// Loads a value of type `T` from the memory location pointed to by the address.
    ///
    /// - Returns: The value of type `T` loaded from the memory.
    ///
    /// - Note: This function assumes that the memory is properly aligned and initialized for type `T`.
    func load<T>() -> T {
        address.load()
    }
}
