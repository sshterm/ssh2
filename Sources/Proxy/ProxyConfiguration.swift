// ProxyConfiguration.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/25.

import Foundation

/// A structure representing the configuration for a proxy connection.
///
/// `ProxyConfiguration` contains the necessary details to establish a connection
/// through a proxy server, including the host, port, optional username and password,
/// and the type of proxy.
///
/// - Parameters:
///   - host: The hostname or IP address of the proxy server.
///   - port: The port number of the proxy server.
///   - username: An optional username for proxy authentication.
///   - password: An optional password for proxy authentication.
///   - type: The type of proxy server (e.g., HTTP, SOCKS5).
public struct ProxyConfiguration {
    let host: String
    let port: String
    let username: String
    let password: String
    let type: ProxyType
    public init(host: String, port: String, type: ProxyType, username: String = "", password: String = "") {
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        self.type = type
    }
}
