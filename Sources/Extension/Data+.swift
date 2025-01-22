// Data+.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import Foundation

public extension Data {
    /// Converts the Data to an array of UInt8 bytes.
    var bytes: [UInt8] {
        [UInt8](self)
    }

    /// Converts the Data to an array of hexadecimal string representations.
    var hex: [String] {
        map { String(format: "%02hhX", $0) }
    }

    /// Generates a fingerprint of the Data. If the Data length is greater than 20, it returns a base64 encoded string. Otherwise, it returns a colon-separated hexadecimal string.
    var fingerprint: String {
        count > 20 ? base64EncodedString() : hex.joined(separator: ":")
    }

    /// A computed property that returns the hexadecimal representation of the data as a string.
    ///
    /// - Returns: A string containing the hexadecimal representation of the data.
    var hexString: String {
        hex.joined()
    }

    /// Converts the Data to a UTF-8 encoded String.
    var string: String? {
        string(encoding: .utf8)
    }

    /// Converts the Data to a String using the specified encoding.
    /// - Parameter encoding: The string encoding to use.
    /// - Returns: A String if the conversion is successful, otherwise nil.
    func string(encoding: String.Encoding) -> String? {
        String(data: self, encoding: encoding)
    }

    /// Converts the Data to a Bool. Assumes the Data contains a single byte where 1 represents true and 0 represents false.
    var bool: Bool {
        let bool: UInt8 = load()
        return bool == 1
    }

    /// Loads a value of type T from the Data.
    /// - Returns: A value of type T.
    func load<T>() -> T where T: FixedWidthInteger {
        return withUnsafeBytes { ptr in
            ptr.load(fromByteOffset: 0, as: T.self)
        }
    }

    /// Creates a Data instance from a value of type T.
    /// - Parameter v: The value to convert to Data.
    /// - Returns: A Data instance containing the value.
    static func from<T>(_ v: inout T) -> Data where T: FixedWidthInteger {
        return Data(bytes: &v, count: MemoryLayout<T>.size)
    }

    /// Creates a Data instance from a String.
    /// - Parameter value: The String to convert to Data.
    /// - Returns: A Data instance containing the UTF-8 encoded string.
    static func from(_ value: String) -> Data {
        return Data(value.utf8)
    }

    /// Creates a Data instance from a Bool.
    /// - Parameter value: The Bool to convert to Data.
    /// - Returns: A Data instance containing a single byte where 1 represents true and 0 represents false.
    static func from(_ value: Bool) -> Data {
        var bool: UInt8 = value ? 1 : 0
        return .from(&bool)
    }
}
