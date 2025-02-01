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

/// A class that provides a read-write lock using POSIX threads.
public class LockReadWrite {
    /// A pointer to the read-write lock.
    let rwlock: UnsafeMutablePointer<pthread_rwlock_t> = .allocate(capacity: 1)

    /// Initializes the LockReadWrite.
    public init() {
        pthread_rwlock_init(rwlock, nil)
    }

    /// Deinitializes the LockReadWrite, destroying the read-write lock and deallocating memory.
    deinit {
        pthread_rwlock_destroy(self.rwlock)
        self.rwlock.deallocate()
    }
}

public extension LockReadWrite {
    /// Locks the read-write lock for reading.
    func lockRead() {
        pthread_rwlock_rdlock(rwlock)
    }

    /// Locks the read-write lock for writing.
    func lockWrite() {
        pthread_rwlock_wrlock(rwlock)
    }

    /// Unlocks the read-write lock.
    func unlock() {
        pthread_rwlock_unlock(rwlock)
    }

    /// Executes a closure within a read-locked context and unlocks upon completion.
    ///
    /// - Parameter body: The closure to execute.
    /// - Returns: The result of the closure.
    func withReaderLock<T>(_ body: () -> T) -> T {
        lockRead()
        defer {
            self.unlock()
        }
        return body()
    }

    /// Executes a closure within a write-locked context and unlocks upon completion.
    ///
    /// - Parameter body: The closure to execute.
    /// - Returns: The result of the closure.
    func withWriterLock<T>(_ body: () -> T) -> T {
        lockWrite()
        defer {
            self.unlock()
        }
        return body()
    }

    /// Executes a void closure within a read-locked context and unlocks upon completion.
    ///
    /// - Parameter body: The closure to execute.
    func withReaderLockVoid(_ body: () -> Void) {
        withReaderLock(body)
    }

    /// Executes a void closure within a write-locked context and unlocks upon completion.
    ///
    /// - Parameter body: The closure to execute.
    func withWriterLockVoid(_ body: () -> Void) {
        withWriterLock(body)
    }
}
