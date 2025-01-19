// CChar+.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import Foundation

public extension UnsafePointer<CChar> {
    /// Converts an `UnsafePointer<CChar>` to a `String`.
    var string: String {
        String(cString: self)
    }
}

public extension UnsafeMutablePointer<CChar> {
    /// Converts an `UnsafeMutablePointer<CChar>` to a `String`.
    var string: String {
        String(cString: self)
    }
}

public extension [CChar] {
    /// Converts an array of `CChar` to a `String`.
    var string: String {
        String(cString: self)
    }
}
