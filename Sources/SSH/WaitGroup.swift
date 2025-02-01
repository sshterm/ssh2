// WaitGroup.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/30.

/// A class that provides a synchronization mechanism for waiting for multiple tasks to complete.
public class WaitGroup {
    /// The current count of tasks.
    private var count: Int = 0

    /// A condition variable used for signaling when tasks are done.
    private let condition = NSCondition()

    /// A lock to protect access to the count variable.
    private let lock = Lock()

    /// Initializes the WaitGroup.
    public init() {}
}

public extension WaitGroup {
    /// Increments the count by the given delta (default is 1).
    ///
    /// - Parameter delta: The amount to increment the count by.
    func add(_ delta: Int = 1) {
        lock.with {
            count += delta
        }
    }

    /// Decrements the count by 1 and signals the condition if count reaches 0.
    func done() {
        lock.with {
            count -= 1
        }
        if count <= 0 {
            condition.signal()
        }
    }

    /// Blocks the current thread until the count reaches 0.
    func wait() {
        while count > 0 {
            condition.wait()
        }
    }

    /// Executes a closure within the context of the WaitGroup, automatically adding and done when finished.
    ///
    /// - Parameter body: The closure to execute.
    /// - Returns: The result of the closure.
    func with<T>(_ body: () -> T) -> T {
        add()
        defer {
            self.done()
        }
        return body()
    }

    /// Executes a void closure within the context of the WaitGroup, automatically adding and done when finished.
    ///
    /// - Parameter body: The closure to execute.
    func withVoid(_ body: () -> Void) {
        with(body)
    }
}
