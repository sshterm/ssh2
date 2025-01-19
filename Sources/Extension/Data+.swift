// Data+.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/16.

import Foundation

public extension Data {
    var bytes: [UInt8] {
        [UInt8](self)
    }

    var hex: [String] {
        map { String(format: "%02hhX", $0) }
    }

    var fingerprint: String {
        count > 20 ? base64EncodedString() : hex.joined(separator: ":")
    }

    var string: String? {
        string(encoding: .utf8)
    }

    func string(encoding: String.Encoding) -> String? {
        String(data: self, encoding: encoding)
    }

    var bool: Bool {
        let bool: UInt8 = load()
        return bool == 1
    }

    func load<T>() -> T where T: FixedWidthInteger {
        return withUnsafeBytes { ptr in
            ptr.load(fromByteOffset: 0, as: T.self)
        }
    }

    static func from<T>(_ v: inout T) -> Data where T: FixedWidthInteger {
        return Data(bytes: &v, count: MemoryLayout<T>.size)
    }

    static func from(_ value: String) -> Data {
        return Data(value.utf8)
    }

    static func from(_ value: Bool) -> Data {
        var bool: UInt8 = value ? 1 : 0
        return .from(&bool)
    }
}
