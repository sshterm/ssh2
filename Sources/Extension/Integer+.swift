// Integer+.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/21.

import Foundation

public extension FixedWidthInteger {
    /// A computed property that returns the raw byte representation of the integer.
    ///
    /// This property uses `withUnsafeBytes` to access the underlying memory of the integer and converts it into an array of `UInt8` values.
    /// The resulting array represents the integer in its binary form, which can be useful for low-level network operations, serialization, or other byte-wise manipulations.
    ///
    /// - Returns: An array of `UInt8` values representing the raw bytes of the integer.
    var bytes: [UInt8] {
        withUnsafeBytes(of: self) { Array($0) }
    }

    /// A computed property that returns the memory address of the current instance as an `UnsafeRawPointer`.
    ///
    /// This property uses the `withUnsafePointer(to:)` function to obtain a pointer to the current instance,
    /// and then converts it to an `UnsafeRawPointer`.
    ///
    /// - Returns: An `UnsafeRawPointer` pointing to the memory address of the current instance.
    var address: UnsafeRawPointer {
        withUnsafePointer(to: self) {
            UnsafeRawPointer($0)
        }
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

public extension Int64 {
    var formatNetworkSpeed: String {
        let units = ["bps", "Kbps", "Mbps", "Gbps", "Tbps"]
        var speed = Double(self)
        var unitIndex = 0

        while speed >= 1000 && unitIndex < units.count - 1 {
            speed /= 1000
            unitIndex += 1
        }
        return String(format: "%.1f %@", speed, units[unitIndex])
    }
}
