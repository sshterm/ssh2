// Crypto.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/16.

import Foundation
#if HAVE_OPENSSL
    import OpenSSL
#else
    import wolfSSL
#endif

public class Crypto {
    /// A singleton instance of the `Crypto` class.
    public static let shared: Crypto = .init()

    /// A static property that returns the name of the cryptographic library being used.
    /// - If `HAVE_OPENSSL` is defined, the name will be "OpenSSL".
    /// - Otherwise, the name will be "wolfSSL".
    #if HAVE_OPENSSL
        public static let name = "OpenSSL"
    #else
        public static let name = "wolfSSL"
    #endif

    /// This code defines a public static constant `version` that holds the version string of the cryptographic library being used.
    ///
    /// - If the `HAVE_OPENSSL` flag is defined, `version` will be set to `OPENSSL_VERSION_STR`, indicating that OpenSSL is being used.
    /// - Otherwise, `version` will be set to `LIBWOLFSSL_VERSION_STRING`, indicating that wolfSSL is being used.
    #if HAVE_OPENSSL
        public static let version = OPENSSL_VERSION_STR
    #else
        public static let version = LIBWOLFSSL_VERSION_STRING
    #endif
}
