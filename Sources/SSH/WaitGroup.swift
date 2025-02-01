// WaitGroup.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/30.

import Foundation

public class WaitGroup {
    private var count: Int = 0
    private let condition = NSCondition()
    private let lock = Lock()
    public init() {}
}

public extension WaitGroup {
    func add(_ delta: Int = 1) {
        lock.with {
            count += delta
        }
    }

    func done() {
        lock.with {
            count -= 1
        }
        if count <= 0 {
            condition.signal()
        }
    }

    func wait() {
        while count > 0 {
            condition.wait()
        }
    }

    func with<T>(_ body: () -> T) -> T {
        add()
        defer {
            self.done()
        }
        return body()
    }

    func withVoid(_ body: () -> Void) {
        with(body)
    }
}
