// String+.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import Darwin
import Foundation

public extension String {
    var bytes: UnsafeMutablePointer<CChar> {
        Darwin.strdup(self)
    }

    /// Returns the number of UTF-8 encoded bytes in the String.
    var count: Int {
        utf8.count
    }

    /// Trims whitespace and newline characters from both ends of the String.
    var trim: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Splits the String into an array of substrings at each newline character.
    var lines: [String] {
        components(separatedBy: .newlines)
    }
}
