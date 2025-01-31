// WaitGroup.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/30.

import Foundation

public class WaitGroup {
    private var count: Int = 0
    private let condition = NSCondition()
    private let lock = NSLock()
    public init() {}
}

public extension WaitGroup {
    func add(_ delta: Int = 1) {
        lock.lock()
        count += delta
        lock.unlock()
    }

    func done() {
        lock.lock()
        count -= 1
        lock.unlock()
        if count <= 0 {
            condition.signal()
        }
    }

    func wait() {
        while count > 0 {
            condition.wait()
        }
    }
}
