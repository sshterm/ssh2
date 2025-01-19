// PrivKey.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import Foundation
import OpenSSL
import SSHKey

public class PrivKey {
    var privKey: OpaquePointer
    let id: keyAlgorithm

    /// Initializes a new private key with the given key algorithm.
    ///
    /// - Parameters:
    ///   - privKey: An inout parameter of type `OpaquePointer` representing the private key.
    ///   - id: A `keyAlgorithm` value representing the key algorithm.
    init(privKey: inout OpaquePointer, id: keyAlgorithm) {
        self.privKey = privKey
        self.id = id
    }

    deinit {
        freeKey()
    }
}

public extension PrivKey {
    /// Frees the memory associated with the private key.
    ///
    /// This function calls `EVP_PKEY_free` to release the resources
    /// allocated for the `privKey` object, ensuring that there are no
    /// memory leaks.
    func freeKey() {
        EVP_PKEY_free(privKey)
    }

    /// A computed property that returns the public key in PEM format as a `String`.
    ///
    /// This property uses OpenSSL functions to write the public key associated with
    /// the private key (`privKey`) to a memory BIO (Basic Input/Output) and then
    /// converts the contents of the BIO to a `String`.
    ///
    /// - Returns: A `String` containing the public key in PEM format.
    var pubPEM: String {
        let out = BIO_new(BIO_s_mem())!
        defer { BIO_free(out) }

        PEM_write_bio_PUBKEY(out, privKey)
        let str = bioToString(bio: out)
        return str
    }

    /// A computed property that returns the private key in PEM format.
    ///
    /// - Returns: A `String` containing the private key in PEM format.
    /// - Note: This method calls `privKeyPEM(password:)` with an empty password.
    var privKeyPEM: String {
        privKeyPEM(password: "")
    }

    /// A computed property that returns the public key in SSH format as a `String`.
    ///
    /// This property attempts to generate the public key from the private key and method.
    /// If the public key cannot be generated, it returns `nil`.
    /// The generated key is deallocated after use.
    ///
    /// - Returns: A `String` containing the public key in SSH format, or `nil` if the key cannot be generated.
    var pubKeySSH: String? {
        guard let key = sshkey_pub(privKey, id.method) else {
            return nil
        }
        defer {
            key.deallocate()
        }
        return key.string
    }

    /// Converts the private key to a PEM formatted string.
    ///
    /// - Parameter password: An optional password to encrypt the PEM. If empty, the PEM will not be encrypted.
    /// - Returns: A PEM formatted string of the private key.
    ///
    /// This function uses OpenSSL to write the private key to a memory BIO. If a password is provided,
    /// the private key will be encrypted using AES-256-CBC. The resulting PEM string is then returned.
    func privKeyPEM(password: String = "") -> String {
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

    /// Converts a BIO object to a String representation.
    ///
    /// This function reads the contents of a BIO object into a buffer and then
    /// converts that buffer into a Swift String.
    ///
    /// - Parameter bio: An `OpaquePointer` to the BIO object to be converted.
    /// - Returns: A `String` representation of the BIO object's contents.
    private func bioToString(bio: OpaquePointer) -> String {
        let len = BIO_ctrl(bio, BIO_CTRL_PENDING, 0, nil)
        var buffer = [CChar](repeating: 0, count: len + 1)
        BIO_read(bio, &buffer, Int32(len))

        buffer[len] = 0
        return buffer.string
    }
}
