// io.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2024/9/3.

import CSSH
import Darwin
import Foundation

public class io {
    /// Copies data from the given input stream to the given output stream using a buffer of the specified size.
    /// - Parameters:
    ///   - w: The output stream to write data to.
    ///   - r: The input stream to read data from.
    ///   - bufferSize: The size of the buffer to use for copying data.
    /// - Returns: The total number of bytes copied.
    public static func Copy(_ w: OutputStream, _ r: InputStream, _ bufferSize: Int) -> Int {
        io.Copy(w, r, bufferSize) { _ in
            true
        }
    }

    /// Copies data from an InputStream to an OutputStream using a specified buffer size.
    ///
    /// - Parameters:
    ///   - r: The InputStream to read data from.
    ///   - w: The OutputStream to write data to.
    ///   - bufferSize: The size of the buffer to use for copying data.
    /// - Returns: The number of bytes copied.
    public static func Copy(_ r: InputStream, _ w: OutputStream, _ bufferSize: Int) -> Int {
        io.Copy(w, r, bufferSize)
    }

    /// Copies data from an input stream to an output stream with a specified buffer size and progress callback.
    ///
    /// - Parameters:
    ///   - r: The input stream to read data from.
    ///   - w: The output stream to write data to.
    ///   - bufferSize: The size of the buffer to use for copying data.
    ///   - progress: A closure that is called with the number of bytes sent. Returns a boolean indicating whether to continue the copy operation.
    /// - Returns: The total number of bytes copied.
    public static func Copy(_ r: InputStream, _ w: OutputStream, _ bufferSize: Int, _ progress: @escaping (_ send: Int) -> Bool) -> Int {
        io.Copy(w, r, bufferSize, progress)
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
    public static func Copy(_ w: OutputStream, _ r: InputStream, _ bufferSize: Int, _ progress: @escaping (_ send: Int) -> Bool) -> Int {
        w.open()
        r.open()
        defer {
            w.close()
            r.close()
        }
        let buffer: Buffer<CChar> = .init(bufferSize)
        var total = 0
        var nread, rc: Int
        while r.hasBytesAvailable {
            nread = r.read(buffer.buffer, maxLength: bufferSize)
            guard nread >= 0 else {
                return nread
            }
            while nread > 0 && w.hasSpaceAvailable {
                rc = w.write(buffer.buffer, maxLength: nread)
                if rc < 0 {
                    return rc
                }
                total += rc
                nread -= rc
                if !progress(total) {
                    return total
                }
            }
        }
        return total
    }
}
