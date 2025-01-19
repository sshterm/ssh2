// Darwin+.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/18.

import Darwin
import Foundation

// 定义每个fd_set可以容纳的文件描述符数量
let __fd_set_count = Int(__DARWIN_FD_SETSIZE) / 32

public extension Darwin.fd_set {
    // 内联函数，用于计算文件描述符在fd_set中的位置和掩码
    @inline(__always)
    private static func address(for fd: Int32) -> (Int, Int32) {
        let intOffset = Int(fd) / __fd_set_count
        let bitOffset = Int(fd) % __fd_set_count
        let mask = Int32(bitPattern: UInt32(1 << bitOffset))
        return (intOffset, mask)
    }

    /// 将fd_set中的所有位设置为0
    mutating func zero() {
        withCArrayAccess { $0.initialize(repeating: 0, count: __fd_set_count) }
    }

    /// 在fd_set中设置一个文件描述符
    /// - Parameter fd: 要添加到fd_set的文件描述符
    mutating func set(_ fd: Int32) {
        let (index, mask) = fd_set.address(for: fd)
        withCArrayAccess { $0[index] |= mask }
    }

    /// 从fd_set中清除一个文件描述符
    /// - Parameter fd: 要从fd_set中清除的文件描述符
    mutating func clear(_ fd: Int32) {
        let (index, mask) = fd_set.address(for: fd)
        withCArrayAccess { $0[index] &= ~mask }
    }

    /// 检查fd_set中是否存在一个文件描述符
    /// - Parameter fd: 要检查的文件描述符
    /// - Returns: 如果存在返回`True`，否则返回`false`
    mutating func isSet(_ fd: Int32) -> Bool {
        let (index, mask) = fd_set.address(for: fd)
        return withCArrayAccess { $0[index] & mask != 0 }
    }

    // 内联函数，用于获取对fd_set内部数组的安全访问
    @inline(__always)
    internal mutating func withCArrayAccess<T>(block: (UnsafeMutablePointer<Int32>) throws -> T) rethrows -> T {
        return try withUnsafeMutablePointer(to: &fds_bits) {
            try block(UnsafeMutableRawPointer($0).assumingMemoryBound(to: Int32.self))
        }
    }
}
