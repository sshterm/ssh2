// io.swift
// Copyright (c) 2025 plexterm.com
// Created by admin@plexterm.com 2025/6/8.

import Darwin
import Foundation

public class io {
    /// Copies data from an input stream to an output stream with a specified buffer size and progress callback.
    ///
    /// - Parameters:
    ///   - r: The input stream to read data from.
    ///   - w: The output stream to write data to.
    ///   - bufferSize: The size of the buffer to use for copying data.
    ///   - progress: A closure that is called with the number of bytes sent. Returns a boolean indicating whether to continue the copy operation.
    /// - Returns: The total number of bytes copied.
    public static func Copy(_ r: InputStream, _ w: OutputStream, _ bufferSize: Int = 0x4000, _ progress: @escaping (_ send: Int) -> Bool = { _ in true }) async -> Int {
        await call {
            Copy(w, r, bufferSize, progress)
        }
    }

    public static func Copy(_ r: InputStream, _ w: OutputStream, _ bufferSize: Int = 0x4000, _ progress: @escaping (_ send: Int) -> Bool = { _ in true }) -> Int {
        Copy(w, r, bufferSize, progress)
    }

    public static func Copy(_ w: OutputStream, _ r: InputStream, _ bufferSize: Int = 0x4000, _ progress: @escaping (_ send: Int) -> Bool = { _ in true }) async -> Int {
        await call {
            Copy(w, r, bufferSize, progress)
        }
    }

    /// Copies data from an `InputStream` to an `OutputStream` with a specified buffer size and progress callback.
    ///
    /// - Parameters:
    ///   - w: The `OutputStream` to write data to.
    ///   - r: The `InputStream` to read data from.
    ///   - bufferSize: The size of the buffer to use for reading and writing data.
    ///   - progress: A closure that is called with the total number of bytes sent so far.
    ///               Returns `true` to continue the operation, or `false` to stop.
    ///
    /// - Returns: The total number of bytes copied, or a negative error code if an error occurs.
    ///
    /// - Note: The streams are opened and closed within this function. The buffer is allocated and deallocated within this function.
    ///
    /// - Important: If the `progress` closure returns `false`, the function will stop copying and return the total number of bytes copied so far.
    public static func Copy(_ w: OutputStream, _ r: InputStream, _ bufferSize: Int = 0x4000, _ progress: @escaping (_ send: Int) -> Bool = { _ in true }) -> Int {
        w.open()
        r.open()
        defer {
            w.close()
            r.close()
        }
        let buffer: Buffer<UInt8> = .init(bufferSize)
        var total = 0
        while r.hasBytesAvailable {
            let nread = r.read(buffer.buffer, maxLength: buffer.count)
            guard nread > 0 else {
                if nread < 0 {
                    return nread
                }
                return total
            }
            var offset = 0
            while offset < nread, w.hasSpaceAvailable {
                let written = w.write(buffer.buffer + offset, maxLength: nread - offset)
                if written < 0 {
                    return written
                }
                offset += written
                total += written
            }
            if !progress(total) {
                return total
            }
        }
        return total
    }

    public static func call<T>(_: Bool = true, _ callback: @escaping () -> T) async -> T {
        await withUnsafeContinuation { continuation in
            let ret: T = callback()
            continuation.resume(returning: ret)
        }
    }
}
