// Error.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/16.

import CSSH
import Foundation

public extension SSH {
    /// A computed property that retrieves the last error encountered by the SSH session.
    ///
    /// This property attempts to fetch the last error from the `rawSession` using the `libssh2_session_last_error` function.
    /// If no error is found or if the error string is `nil`, it returns `nil`.
    /// Otherwise, it returns an `NSError` object with the error code and description.
    ///
    /// - Returns: An `Error` object representing the last error, or `nil` if no error is found.
    var lastError: Error? {
        guard let rawSession else {
            return nil
        }
        var cstr: UnsafeMutablePointer<CChar>?
        let code = libssh2_session_last_error(rawSession, &cstr, nil, 0)
        guard code != LIBSSH2_ERROR_NONE else {
            return nil
        }
        guard let cstr else {
            return nil
        }
        return NSError(domain: "libssh2", code: Int(code), userInfo: [NSLocalizedDescriptionKey: cstr.string])
    }
}
