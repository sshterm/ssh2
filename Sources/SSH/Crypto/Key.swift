// Key.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import OpenSSL
import Foundation
import SSHKey

public extension Crypto {
    /// Generates an RSA key pair with the specified number of bits.
    /// - Parameter bits: The number of bits for the RSA key. Defaults to 2048.
    /// - Returns: An `OpaquePointer` to the generated RSA key pair, or `nil` if the generation fails.
    func keygenRSA(_ bits: Int32 = 2048) -> OpaquePointer? {
        keygen(bits, id: .rsa)
    }

    /// Generates an ED25519 key pair.
    /// - Returns: An `OpaquePointer` to the generated ED25519 key pair, or `nil` if the generation fails.
    func generateED25519() -> OpaquePointer? {
        keygen(id: .ed25519)
    }

    /// Generates a cryptographic key of the specified algorithm and bit length.
    ///
    /// - Parameters:
    ///   - bits: The length of the key in bits. Defaults to 2048.
    ///   - id: The algorithm to use for key generation. Defaults to RSA.
    ///
    /// - Returns: An optional `OpaquePointer` to the generated key, or `nil` if key generation fails.
    func keygen(_ bits: Int32 = 2048, id: keyAlgorithm = .rsa) -> OpaquePointer? {
        let genctx = EVP_PKEY_CTX_new_id(id.id, nil)
        defer {
            EVP_PKEY_CTX_free(genctx)
        }

        switch id {
        case .rsa:
            EVP_PKEY_keygen_init(genctx)
            EVP_PKEY_CTX_set_rsa_keygen_bits(genctx, bits)
        case .ed25519:
            EVP_PKEY_keygen_init(genctx)
        }

        var pkey = EVP_PKEY_new()
        EVP_PKEY_keygen(genctx, &pkey)
        return pkey
    }

    /// Frees the memory associated with the given EVP_PKEY object.
    ///
    /// This function releases the resources allocated for the provided
    /// EVP_PKEY object, ensuring that there are no memory leaks.
    ///
    /// - Parameter pkey: An optional `OpaquePointer` to the EVP_PKEY object
    ///   that needs to be freed. If `nil` is passed, the function does nothing.
    func freeKey(_ pkey: OpaquePointer?) {
        EVP_PKEY_free(pkey)
    }

    /// Converts a BIO object to a String.
    ///
    /// This function reads the contents of a BIO object and converts it to a Swift String.
    ///
    /// - Parameter bio: An `OpaquePointer` to the BIO object.
    /// - Returns: A `String` representation of the BIO contents.
    /// - Note: This function assumes that the BIO object contains valid UTF-8 encoded data.
    func bioToString(bio: OpaquePointer) -> String {
        let len = BIO_ctrl(bio, BIO_CTRL_PENDING, 0, nil)
        var buffer = [CChar](repeating: 0, count: len + 1)
        BIO_read(bio, &buffer, Int32(len))

        buffer[len] = 0
        let ret = String(cString: buffer)
        return ret
    }

    /// Converts a given private key to a PEM formatted public key string.
    ///
    /// This function takes an `OpaquePointer` to a private key, converts it to a
    /// public key in PEM format, and returns the resulting string.
    ///
    /// - Parameter privKey: An `OpaquePointer` to the private key.
    /// - Returns: A `String` containing the PEM formatted public key.
    func pubKeyToPEM(privKey: OpaquePointer) -> String {
        let out = BIO_new(BIO_s_mem())!
        defer { BIO_free(out) }

        PEM_write_bio_PUBKEY(out, privKey)
        let str = bioToString(bio: out)
        return str
    }

    /// Converts a private key to PEM format.
    ///
    /// - Parameters:
    ///   - privKey: The private key to be converted, represented as an `OpaquePointer`.
    ///   - password: An optional password for encrypting the PEM. Defaults to an empty string, meaning no encryption.
    /// - Returns: A `String` containing the PEM representation of the private key.
    ///
    /// This function uses OpenSSL to write the private key to a memory BIO in PEM format. If a password is provided,
    /// the private key is encrypted using AES-256-CBC. The resulting PEM string is then returned.
    func privKeyToPEM(privKey: OpaquePointer, password: String = "") -> String {
        let out = BIO_new(BIO_s_mem())!
        defer { BIO_free(out) }
        if password.isEmpty {
            PEM_write_bio_PrivateKey(out, privKey, nil, nil, 0, nil, nil)
        } else {
            PEM_write_bio_PrivateKey(out, privKey, EVP_aes_256_cbc(), password, password.count.load(), nil, nil)
        }
        let str = bioToString(bio: out)

        return str
    }

    /// Converts a private key to its corresponding SSH public key representation.
    ///
    /// - Parameters:
    ///   - privKey: The private key as an `OpaquePointer`.
    ///   - id: The key algorithm identifier of type `keyAlgorithm`.
    /// - Returns: A `String` containing the SSH public key representation, or `nil` if the conversion fails.
    func pubKeyToSSH(privKey: OpaquePointer, id: keyAlgorithm) -> String? {
        guard let key = sshkey_pub(privKey, id.method) else {
            return nil
        }
        return String(cString: key)
    }
}
