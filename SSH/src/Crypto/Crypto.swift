// Crypto.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/16.

import CSSH
import Foundation

public class Crypto {
    /// A singleton instance of the `Crypto` class.
    public static let shared: Crypto = .init()

    /// The name of the cryptographic library being used.
    public static let name = "OpenSSL"

    /// The version of the OpenSSL library being used.
    public static let version = OPENSSL_VERSION_STR
}
