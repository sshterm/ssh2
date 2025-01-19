// Crypto.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import Foundation
#if HAVE_OPENSSL
    import OpenSSL
#else
    import wolfSSL
#endif

public class Crypto {
    /// A singleton instance of the `Crypto` class.
    public static let shared: Crypto = .init()

    #if HAVE_OPENSSL
        public static let name = "OpenSSL"
    #else
        public static let name = "wolfSSL"
    #endif

    #if HAVE_OPENSSL
        public static let version = OPENSSL_VERSION_STR
    #else
        public static let version = LIBWOLFSSL_VERSION_STRING
    #endif
}
