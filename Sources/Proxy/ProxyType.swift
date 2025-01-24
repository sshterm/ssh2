// ProxyType.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/25.

import Foundation

/// An enumeration representing the types of proxy servers that can be used.
///
/// - http: Represents an HTTP proxy server.
/// - https: Represents an HTTPS proxy server.
/// - socks5: Represents a SOCKS5 proxy server.
public enum ProxyType: String, CaseIterable {
    case http
    // case https
    case socks5

    public var port: String {
        switch self {
        case .http:
            "8080"
        case .socks5:
            "1080"
        }
    }
}
