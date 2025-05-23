// Key.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

#if HAVE_OPENSSL
    import CSSH
    import Foundation

    public extension Crypto {
        /// Generates an RSA private key with the specified number of bits.
        ///
        /// - Parameter bits: The number of bits for the RSA key. The default value is 2048.
        /// - Returns: An optional `PrivKey` object representing the generated RSA private key.
        func generateRSA(_ bits: Int32 = 2048) async -> PrivKey? {
            await keygen(bits, id: .rsa)
        }

        /// Generates an ED25519 private key.
        ///
        /// - Returns: An optional `PrivKey` object representing the generated ED25519 private key.
        ///            Returns `nil` if the key generation fails.
        func generateED25519() async -> PrivKey? {
            await keygen(id: .ed25519)
        }

        /// Generates a private key based on the specified algorithm and bit length.
        ///
        /// - Parameters:
        ///   - bits: The bit length of the key to generate. Defaults to 2048.
        ///   - id: The algorithm to use for key generation. Defaults to RSA.
        ///
        /// - Returns: A `PrivKey` object containing the generated private key, or `nil` if key generation fails.
        func keygen(_ bits: Int32 = 2048, id: keyAlgorithm = .rsa) async -> PrivKey? {
            await withUnsafeContinuation { continuation in
                let genctx = EVP_PKEY_CTX_new_id(id.id, nil)
                defer {
                    EVP_PKEY_CTX_free(genctx)
                }
                EVP_PKEY_keygen_init(genctx)
                switch id {
                case .rsa:
                    EVP_PKEY_CTX_set_rsa_keygen_bits(genctx, bits)
                case .ed25519:
                    break
                }
                var pkey = EVP_PKEY_new()
                EVP_PKEY_keygen(genctx, &pkey)
                continuation.resume(returning: .init(privKey: &pkey!, id: id))
            }
        }
    }
#endif
