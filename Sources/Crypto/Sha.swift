// Sha.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import CSSH
import Darwin
import Extension
import Foundation

public extension Crypto {
    /// Computes the SHA hash of the given message using the specified algorithm.
    ///
    /// - Parameters:
    ///   - message: The input string to be hashed.
    ///   - algorithm: The SHA algorithm to use for hashing.
    /// - Returns: The computed hash as a `Data` object.
    func sha(_ message: String, algorithm: ShaAlgorithm) -> Data {
        sha(message.bytes, message_len: message.count, algorithm: algorithm)
    }

    /// Computes the SHA hash of the given message using the specified algorithm.
    ///
    /// - Parameters:
    ///   - message: The input data to be hashed.
    ///   - algorithm: The SHA algorithm to use for hashing.
    /// - Returns: The computed hash as a `Data` object.
    func sha(_ message: Data, algorithm: ShaAlgorithm) -> Data {
        sha(message.bytes, message_len: message.count, algorithm: algorithm)
    }

    /// Computes the SHA hash of a given message using the specified algorithm.
    ///
    /// - Parameters:
    ///   - message: A pointer to the message data to be hashed.
    ///   - message_len: The length of the message data.
    ///   - algorithm: The SHA algorithm to use for hashing.
    ///
    /// - Returns: A `Data` object containing the computed hash.
    ///
    /// This function uses the OpenSSL library to perform the hashing. It initializes
    /// the digest context, updates it with the message data, and finalizes the digest
    /// to produce the hash. The resulting hash is returned as a `Data` object.
    func sha(_ message: UnsafeRawPointer, message_len: Int, algorithm: ShaAlgorithm) -> Data {
        let evp = algorithm.EVP
        let buf: BufferData<Int8, UInt32> = .init(algorithm.digest)
        #if HAVE_OPENSSL
            let mdctx = EVP_MD_CTX_new()
            EVP_DigestInit(mdctx, evp)
            EVP_DigestUpdate(mdctx, message, message_len)
            EVP_DigestFinal_ex(mdctx, buf.buf.buffer, buf.len.buffer)
            EVP_MD_CTX_free(mdctx)
        #else
            let mdctx = wolfSSL_EVP_MD_CTX_new()
            wolfSSL_EVP_DigestInit(mdctx, evp)
            wolfSSL_EVP_DigestUpdate(mdctx, message, message_len)
            wolfSSL_EVP_DigestFinal_ex(mdctx, buf.buf.buffer, buf.len.buffer)
            wolfSSL_EVP_MD_CTX_free(mdctx)
        #endif
        return buf.data
    }

    func sha(file: String, algorithm: ShaAlgorithm) -> Data? {
        guard let fp = Darwin.fopen(file, "rb") else {
            return nil
        }
        defer {
            Darwin.fclose(fp)
        }
        let evp = algorithm.EVP
        let buf: BufferData<Int8, UInt32> = .init(algorithm.digest)
        let buff: Buffer<CChar> = .init(0x400)
        var len: Int
        #if HAVE_OPENSSL
            let mdctx = EVP_MD_CTX_new()
            EVP_DigestInit(mdctx, evp)
        #else
            let mdctx = wolfSSL_EVP_MD_CTX_new()
            wolfSSL_EVP_DigestInit(mdctx, evp)
        #endif
        while true {
            len = Darwin.fread(buff.buffer, 1, buff.count, fp)
            guard len > 0 else {
                break
            }
            #if HAVE_OPENSSL
                EVP_DigestUpdate(mdctx, buff.buffer, len)
            #else
                wolfSSL_EVP_DigestUpdate(mdctx, buff.buffer, len)
            #endif
        }
        #if HAVE_OPENSSL
            EVP_DigestFinal_ex(mdctx, buf.buf.buffer, buf.len.buffer)
            EVP_MD_CTX_free(mdctx)
        #else
            wolfSSL_EVP_DigestFinal_ex(mdctx, buf.buf.buffer, buf.len.buffer)
            wolfSSL_EVP_MD_CTX_free(mdctx)
        #endif
        return buf.data
    }
}
