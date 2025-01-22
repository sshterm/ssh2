// String+.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/23.

public extension String {
    var flag: String {
        let base = 127_397
        let usv = utf16
            .map { base + Int($0) }
            .compactMap(UnicodeScalar.init)
            .reduce(String.UnicodeScalarView()) { $0 + [$1] }

        return String(usv)
    }
}
