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

    /// Adds a specified prefix to the current string if it doesn't already have that prefix.
    ///
    /// - Parameter prefix: The prefix to add to the string.
    /// - Returns: A new string with the prefix added, or the original string if it already starts with the prefix.
    ///
    /// This function checks whether the current string starts with the specified prefix. If it does, the original string is returned
    /// unchanged. Otherwise, the prefix is concatenated with the current string, and the resulting string is returned.
    func withPrefix(_ prefix: String) -> String {
        guard !hasPrefix(prefix) else { return self }
        return prefix + self
    }
}
