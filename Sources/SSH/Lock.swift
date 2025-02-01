// Lock.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/2/1.

import Foundation

/// A class that provides a mutual exclusion lock using POSIX threads.
public class Lock {
    /// A pointer to the mutex.
    let mutex: UnsafeMutablePointer<pthread_mutex_t> = .allocate(capacity: 1)

    /// Initializes the Lock with an error-checking mutex.
    public init() {
        var attr = pthread_mutexattr_t()
        pthread_mutexattr_init(&attr)
        pthread_mutexattr_settype(&attr, .init(PTHREAD_MUTEX_ERRORCHECK))
        pthread_mutex_init(mutex, &attr)
    }

    /// Deinitializes the Lock, destroying the mutex and deallocating memory.
    deinit {
        pthread_mutex_destroy(self.mutex)
        self.mutex.deallocate()
    }
}

public extension Lock {
    /// Locks the mutex.
    func lock() {
        pthread_mutex_lock(mutex)
    }

    /// Unlocks the mutex.
    func unlock() {
        pthread_mutex_unlock(mutex)
    }

    /// Executes a closure within a locked context and unlocks upon completion.
    ///
    /// - Parameter body: The closure to execute.
    /// - Returns: The result of the closure.
    func with<T>(_ body: () -> T) -> T {
        lock()
        defer {
            self.unlock()
        }
        return body()
    }

    /// Executes a void closure within a locked context and unlocks upon completion.
    ///
    /// - Parameter body: The closure to execute.
    func withVoid(_ body: () -> Void) {
        with(body)
    }
}
