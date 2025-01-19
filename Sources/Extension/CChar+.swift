// CChar+.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/16.

import Foundation

public extension UnsafePointer<CChar> {
    var string: String {
        String(cString: self)
    }
}

public extension UnsafeMutablePointer<CChar> {
    var string: String {
        String(cString: self)
    }
}

public extension [CChar] {
    var string: String {
        String(cString: self)
    }
}
