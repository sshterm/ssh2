// Lock.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/2/1.

import Foundation

public class Lock {
    let mutex: UnsafeMutablePointer<pthread_mutex_t> = .allocate(capacity: 1)

    public init() {
        var attr = pthread_mutexattr_t()
        pthread_mutexattr_init(&attr)
        pthread_mutexattr_settype(&attr, .init(PTHREAD_MUTEX_ERRORCHECK))
        pthread_mutex_init(mutex, &attr)
    }

    deinit {
        pthread_mutex_destroy(self.mutex)
        self.mutex.deallocate()
    }
}

public extension Lock {
    func lock() {
        pthread_mutex_lock(mutex)
    }

    func unlock() {
        pthread_mutex_unlock(mutex)
    }

    func with<T>(_ body: () -> T) -> T {
        lock()
        defer {
            self.unlock()
        }
        return body()
    }

    func withVoid(_ body: () -> Void) {
        with(body)
    }
}

public class LockReadWrite {
    let rwlock: UnsafeMutablePointer<pthread_rwlock_t> = .allocate(capacity: 1)

    public init() {
        pthread_rwlock_init(rwlock, nil)
    }

    deinit {
        pthread_rwlock_destroy(self.rwlock)
        self.rwlock.deallocate()
    }
}

public extension LockReadWrite {
    func lockRead() {
        pthread_rwlock_rdlock(rwlock)
    }

    func lockWrite() {
        pthread_rwlock_wrlock(rwlock)
    }

    func unlock() {
        pthread_rwlock_unlock(rwlock)
    }

    func withReaderLock<T>(_ body: () -> T) -> T {
        lockRead()
        defer {
            self.unlock()
        }
        return body()
    }

    func withWriterLock<T>(_ body: () -> T) -> T {
        lockWrite()
        defer {
            self.unlock()
        }
        return body()
    }

    func withReaderLockVoid(_ body: () -> Void) {
        withReaderLock(body)
    }

    func withWriterLockVoid(_ body: () -> Void) {
        withWriterLock(body)
    }
}
