// Process.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/2/4.

import Extension
import Foundation

public extension SSH {
    func getProcessCount() async -> Int {
        guard let lines = await readLines(hostProc.appendingPathComponent("[0-9]*/stat")) else {
            return 0
        }
        return lines.count
    }
}
