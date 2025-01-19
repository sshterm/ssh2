// String+.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import Darwin
import Foundation

extension String {
    var bytes: UnsafeMutablePointer<CChar> {
        Darwin.strdup(self)
    }

    var count: Int {
        utf8.count
    }

    var trim: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var lines: [String] {
        components(separatedBy: .newlines)
    }
}
