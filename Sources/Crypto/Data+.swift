// Data+.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/20.

import Extension
import Foundation

public extension Data {
    #if HAVE_OPENSSL

        /// Computes the MD4 hash of the data.
        var md4: Data {
            Crypto.shared.sha(self, algorithm: .md4)
        }

        /// Computes the MD5 hash of the data.
        var md5: Data {
            Crypto.shared.sha(self, algorithm: .md5)
        }

        /// Computes the MD5-SHA1 hash of the data.
        var md5_sha1: Data {
            Crypto.shared.sha(self, algorithm: .md5_sha1)
        }

        /// Computes the SHA-1 hash of the data.
        var sha1: Data {
            Crypto.shared.sha(self, algorithm: .sha1)
        }

        /// Computes the SHA-224 hash of the data.
        var sha224: Data {
            Crypto.shared.sha(self, algorithm: .sha224)
        }

        /// Computes the SHA-256 hash of the data.
        var sha256: Data {
            Crypto.shared.sha(self, algorithm: .sha256)
        }

        /// Computes the SHA-384 hash of the data.
        var sha384: Data {
            Crypto.shared.sha(self, algorithm: .sha384)
        }

        /// Computes the SHA-512 hash of the data.
        var sha512: Data {
            Crypto.shared.sha(self, algorithm: .sha512)
        }

        /// Computes the SHA-512/224 hash of the data.
        var sha512_224: Data {
            Crypto.shared.sha(self, algorithm: .sha512_224)
        }

        /// Computes the SHA-512/256 hash of the data.
        var sha512_256: Data {
            Crypto.shared.sha(self, algorithm: .sha512_256)
        }

        /// Computes the SHA3-224 hash of the data.
        var sha3_224: Data {
            Crypto.shared.sha(self, algorithm: .sha3_224)
        }

        /// Computes the SHA3-256 hash of the data.
        var sha3_256: Data {
            Crypto.shared.sha(self, algorithm: .sha3_256)
        }

        /// Computes the SHA3-384 hash of the data.
        var sha3_384: Data {
            Crypto.shared.sha(self, algorithm: .sha3_384)
        }

        /// Computes the SHA3-512 hash of the data.
        var sha3_512: Data {
            Crypto.shared.sha(self, algorithm: .sha3_512)
        }

        /// Computes the HMAC-MD4 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-MD4 hash of the data.
        func md4(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .md4)
        }

        /// Computes the HMAC-MD5 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-MD5 hash of the data.
        func md5(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .md5)
        }

        /// Computes the HMAC-MD5-SHA1 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-MD5-SHA1 hash of the data.
        func md5_sha1(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .md5_sha1)
        }

        /// Computes the HMAC-SHA1 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA1 hash of the data.
        func sha1(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha1)
        }

        /// Computes the HMAC-SHA224 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA224 hash of the data.
        func sha224(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha224)
        }

        /// Computes the HMAC-SHA256 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA256 hash of the data.
        func sha256(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha256)
        }

        /// Computes the HMAC-SHA384 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA384 hash of the data.
        func sha384(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha384)
        }

        /// Computes the HMAC-SHA512 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA512 hash of the data.
        func sha512(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha512)
        }

        /// Computes the HMAC-SHA512/224 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA512/224 hash of the data.
        func sha512_224(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha512_224)
        }

        /// Computes the HMAC-SHA512/256 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA512/256 hash of the data.
        func sha512_256(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha512_256)
        }

        /// Computes the HMAC-SHA3-224 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA3-224 hash of the data.
        func sha3_224(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha3_224)
        }

        /// Computes the HMAC-SHA3-256 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA3-256 hash of the data.
        func sha3_256(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha3_256)
        }

        /// Computes the HMAC-SHA3-384 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA3-384 hash of the data.
        func sha3_384(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha3_384)
        }

        /// Computes the HMAC-SHA3-512 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA3-512 hash of the data.
        func sha3_512(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha3_512)
        }

        /// Computes the HMAC-MD4 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-MD4 hash of the data.
        func md4(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .md4)
        }

        /// Computes the HMAC-MD5 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-MD5 hash of the data.
        func md5(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .md5)
        }

        /// Computes the HMAC-MD5-SHA1 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-MD5-SHA1 hash of the data.
        func md5_sha1(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .md5_sha1)
        }

        /// Computes the HMAC-SHA1 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA1 hash of the data.
        func sha1(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha1)
        }

        /// Computes the HMAC-SHA224 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA224 hash of the data.
        func sha224(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha224)
        }

        /// Computes the HMAC-SHA256 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA256 hash of the data.
        func sha256(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha256)
        }

        /// Computes the HMAC-SHA384 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA384 hash of the data.
        func sha384(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha384)
        }

        /// Computes the HMAC-SHA512 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA512 hash of the data.
        func sha512(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha512)
        }

        /// Computes the HMAC-SHA512/224 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA512/224 hash of the data.
        func sha512_224(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha512_224)
        }

        /// Computes the HMAC-SHA512/256 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA512/256 hash of the data.
        func sha512_256(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha512_256)
        }

        /// Computes the HMAC-SHA3-224 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA3-224 hash of the data.
        func sha3_224(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha3_224)
        }

        /// Computes the HMAC-SHA3-256 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA3-256 hash of the data.
        func sha3_256(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha3_256)
        }

        /// Computes the HMAC-SHA3-384 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA3-384 hash of the data.
        func sha3_384(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha3_384)
        }

        /// Computes the HMAC-SHA3-512 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA3-512 hash of the data.
        func sha3_512(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha3_512)
        }

    #else

        /// Computes the MD4 hash of the data.
        var md4: Data {
            Crypto.shared.sha(self, algorithm: .md4)
        }

        /// Computes the MD5 hash of the data.
        var md5: Data {
            Crypto.shared.sha(self, algorithm: .md5)
        }

        /// Computes the SHA-1 hash of the data.
        var sha1: Data {
            Crypto.shared.sha(self, algorithm: .sha1)
        }

        /// Computes the SHA-224 hash of the data.
        var sha224: Data {
            Crypto.shared.sha(self, algorithm: .sha224)
        }

        /// Computes the SHA-256 hash of the data.
        var sha256: Data {
            Crypto.shared.sha(self, algorithm: .sha256)
        }

        /// Computes the SHA-384 hash of the data.
        var sha384: Data {
            Crypto.shared.sha(self, algorithm: .sha384)
        }

        /// Computes the SHA-512 hash of the data.
        var sha512: Data {
            Crypto.shared.sha(self, algorithm: .sha512)
        }

        /// Computes the SHA-512/224 hash of the data.
        var sha512_224: Data {
            Crypto.shared.sha(self, algorithm: .sha512_224)
        }

        /// Computes the SHA-512/256 hash of the data.
        var sha512_256: Data {
            Crypto.shared.sha(self, algorithm: .sha512_256)
        }

        /// Computes the SHA3-224 hash of the data.
        var sha3_224: Data {
            Crypto.shared.sha(self, algorithm: .sha3_224)
        }

        /// Computes the SHA3-256 hash of the data.
        var sha3_256: Data {
            Crypto.shared.sha(self, algorithm: .sha3_256)
        }

        /// Computes the SHA3-384 hash of the data.
        var sha3_384: Data {
            Crypto.shared.sha(self, algorithm: .sha3_384)
        }

        /// Computes the SHA3-512 hash of the data.
        var sha3_512: Data {
            Crypto.shared.sha(self, algorithm: .sha3_512)
        }

        /// Computes the HMAC-MD4 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-MD4 hash of the data.
        func md4(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .md4)
        }

        /// Computes the HMAC-MD5 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-MD5 hash of the data.
        func md5(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .md5)
        }

        /// Computes the HMAC-SHA1 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA1 hash of the data.
        func sha1(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha1)
        }

        /// Computes the HMAC-SHA224 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA224 hash of the data.
        func sha224(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha224)
        }

        /// Computes the HMAC-SHA256 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA256 hash of the data.
        func sha256(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha256)
        }

        /// Computes the HMAC-SHA384 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA384 hash of the data.
        func sha384(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha384)
        }

        /// Computes the HMAC-SHA512 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA512 hash of the data.
        func sha512(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha512)
        }

        /// Computes the HMAC-SHA512/224 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA512/224 hash of the data.
        func sha512_224(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha512_224)
        }

        /// Computes the HMAC-SHA512/256 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA512/256 hash of the data.
        func sha512_256(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha512_256)
        }

        /// Computes the HMAC-SHA3-224 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA3-224 hash of the data.
        func sha3_224(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha3_224)
        }

        /// Computes the HMAC-SHA3-256 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA3-256 hash of the data.
        func sha3_256(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha3_256)
        }

        /// Computes the HMAC-SHA3-384 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA3-384 hash of the data.
        func sha3_384(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha3_384)
        }

        /// Computes the HMAC-SHA3-512 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA3-512 hash of the data.
        func sha3_512(key: Data) -> Data {
            Crypto.shared.hmac(self, key: key, algorithm: .sha3_512)
        }

        /// Computes the HMAC-MD4 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-MD4 hash of the data.
        func md4(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .md4)
        }

        /// Computes the HMAC-MD5 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-MD5 hash of the data.
        func md5(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .md5)
        }

        /// Computes the HMAC-SHA1 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA1 hash of the data.
        func sha1(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha1)
        }

        /// Computes the HMAC-SHA224 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA224 hash of the data.
        func sha224(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha224)
        }

        /// Computes the HMAC-SHA256 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA256 hash of the data.
        func sha256(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha256)
        }

        /// Computes the HMAC-SHA384 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA384 hash of the data.
        func sha384(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha384)
        }

        /// Computes the HMAC-SHA512 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA512 hash of the data.
        func sha512(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha512)
        }

        /// Computes the HMAC-SHA512/224 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA512/224 hash of the data.
        func sha512_224(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha512_224)
        }

        /// Computes the HMAC-SHA512/256 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA512/256 hash of the data.
        func sha512_256(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha512_256)
        }

        /// Computes the HMAC-SHA3-224 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA3-224 hash of the data.
        func sha3_224(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha3_224)
        }

        /// Computes the HMAC-SHA3-256 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA3-256 hash of the data.
        func sha3_256(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha3_256)
        }

        /// Computes the HMAC-SHA3-384 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA3-384 hash of the data.
        func sha3_384(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha3_384)
        }

        /// Computes the HMAC-SHA3-512 hash of the data using the provided key.
        ///
        /// - Parameter key: The key to use for the HMAC computation.
        /// - Returns: The HMAC-SHA3-512 hash of the data.
        func sha3_512(key: String) -> Data {
            Crypto.shared.hmac(self, key: .from(key), algorithm: .sha3_512)
        }

    #endif
}
