// CChar+.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import Foundation

extension UnsafePointer<CChar> {
    var string: String {
        String(cString: self)
    }
}

extension UnsafeMutablePointer<CChar> {
    var string: String {
        String(cString: self)
    }
}

extension [CChar] {
    var string: String {
        String(cString: self)
    }
}
