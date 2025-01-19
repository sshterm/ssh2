// HMAC.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import OpenSSL
import Foundation

public extension Crypto {
    /// Generates an HMAC (Hash-based Message Authentication Code) for a given message using the specified key and algorithm.
    ///
    /// - Parameters:
    ///   - message: The input message to be hashed.
    ///   - key: The secret key used for hashing.
    ///   - algorithm: The SHA algorithm to be used for hashing (e.g., SHA-1, SHA-256).
    /// - Returns: The generated HMAC as a `Data` object.
    func hmac(_ message: String, key: String, algorithm: ShaAlgorithm) -> Data {
        hmac(message.bytes, message_len: message.count, key: key.bytes, key_len: key.count.load(), algorithm: algorithm)
    }

    /// Generates an HMAC (Hash-based Message Authentication Code) for the given message using the specified key and algorithm.
    ///
    /// - Parameters:
    ///   - message: The input data for which the HMAC is to be generated.
    ///   - key: The secret key used for the HMAC generation.
    ///   - algorithm: The hashing algorithm to be used (e.g., SHA-1, SHA-256).
    /// - Returns: The generated HMAC as a `Data` object.
    func hmac(_ message: Data, key: Data, algorithm: ShaAlgorithm) -> Data {
        hmac(message.bytes, message_len: message.count, key: key.bytes, key_len: key.count.load(), algorithm: algorithm)
    }

    /// Computes the HMAC (Hash-based Message Authentication Code) for a given message using the specified algorithm.
    ///
    /// - Parameters:
    ///   - message: A pointer to the message data.
    ///   - message_len: The length of the message data.
    ///   - key: A pointer to the key data.
    ///   - key_len: The length of the key data.
    ///   - algorithm: The SHA algorithm to use for HMAC computation.
    /// - Returns: A `Data` object containing the computed HMAC.
    func hmac(_ message: UnsafeRawPointer, message_len: Int, key: UnsafeRawPointer, key_len: Int32, algorithm: ShaAlgorithm) -> Data {
        let evp = algorithm.EVP
        let digest = EVP_MD_get_size(evp)
        let buf: BufferData<Int8, UInt32> = .init(algorithm.digest)
        HMAC(evp, key, key_len, message, message_len, buf.buf.buffer, buf.len.buffer)
        return buf.data
    }
}
