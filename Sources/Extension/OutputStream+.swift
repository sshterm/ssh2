// OutputStream+.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import Foundation

public extension OutputStream {
    var data: Data? {
        guard let data = property(forKey: Stream.PropertyKey.dataWrittenToMemoryStreamKey) as? Data else {
            return nil
        }
        return data
    }
}
