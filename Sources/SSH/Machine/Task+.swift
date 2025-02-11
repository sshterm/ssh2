// Task+.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/2/11.

import Foundation

public extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async {
        try? await Task.sleep(for: .seconds(seconds))
    }
}
