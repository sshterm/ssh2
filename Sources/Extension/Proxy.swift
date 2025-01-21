// Proxy.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/21.

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
    let username: String?
    let password: String?
    let type: ProxyType
    public init(host: String, port: String, type: ProxyType, username: String? = nil, password: String? = nil) {
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        self.type = type
    }

    /// Connects to a remote server through a proxy.
    ///
    /// This method attempts to establish a connection to the specified `host` and `port` through a proxy. The type of proxy (HTTP/HTTPS or SOCKS5) is determined by the `type` property of the proxy.
    ///
    /// - Parameters:
    ///   - fd: The file descriptor of the socket to use for the connection.
    ///   - host: The hostname or IP address of the remote server to connect to.
    ///   - port: The port number of the remote server to connect to.
    /// - Returns: A `Bool` indicating whether the connection was successful.
    ///
    /// - Throws: This method does not throw exceptions but returns `false` if any step of the connection process fails.
    func connect(fd: Socket, host: String, port: String) -> Bool {
        guard host.isIP else {
            return false
        }
        switch type {
        case .http, .https:
            let connectString = "CONNECT \(host):\(port) HTTP/1.1\r\n" +
                (username != nil && password != nil ? "Proxy-Authorization: Basic \(Data("\(username!):\(password!)".utf8).base64EncodedString().trimmingCharacters(in: .whitespacesAndNewlines))\r\n" : "") +
                "Host: \(host):\(port)\r\n" +
                "\r\n"
            guard fd.write(connectString.bytes, connectString.count) == connectString.count else {
                return false
            }
            let buffer: Buffer<UInt8> = .init(0x400)
            let rc = fd.read(buffer.buffer, buffer.count)
            guard rc > 0, let response = buffer.data(rc).string else {
                return false
            }
            if !response.contains("200 Connection established") {
                return false
            }
        case .socks5:
            var greeting: [UInt8] = [0x05, 0x01, 0x00]
            if username != nil && password != nil {
                greeting = [0x05, 0x01, 0x02]
            }
            guard fd.write(&greeting, greeting.count) == greeting.count else {
                return false
            }
            var response: Buffer<UInt8> = .init(2)
            guard fd.read(response.buffer, response.count) == response.count else {
                return false
            }
            guard response.buffer[0] == 0x05 else {
                return false
            }
            if response.buffer[1] == 0x02 {
                guard let username, let password else {
                    return false
                }
                let usernameBytes = [UInt8](username.utf8)
                let passwordBytes = [UInt8](password.utf8)
                var authRequest: [UInt8] = [0x01, UInt8(usernameBytes.count)] + usernameBytes + [UInt8(passwordBytes.count)] + passwordBytes
                guard fd.write(&authRequest, authRequest.count) == authRequest.count else {
                    return false
                }
                var response: Buffer<UInt8> = .init(2)
                guard fd.read(response.buffer, response.count) == response.count else {
                    return false
                }
                guard response.buffer[0] == 0x05 else {
                    return false
                }
                guard response.buffer[1] == 0x00 else {
                    return false
                }
            }

            var request: [UInt8] = [0x05, 0x01, 0x00]
            if host.isIPv4 {
                request.append(0x01)
                guard let addr = host.addr else {
                    return false
                }
                request += addr
            } else if host.isIPv6 {
                request.append(0x04)
                guard let addr = host.addr else {
                    return false
                }
                request += addr
            } else {
                return false
//                request.append(0x03)
//                let domainBytes = host.utf8
//                request.append(UInt8(domainBytes.count))
//                request += domainBytes
            }
            request += (UInt16(port) ?? 22).bytes.reversed()
            guard fd.write(&request, request.count) == request.count else {
                return false
            }
            var connectResponse: Buffer<UInt8> = .init(10)
            guard fd.read(connectResponse.buffer, connectResponse.count) == connectResponse.count else {
                return false
            }
            guard connectResponse.buffer[0] == 0x05 else {
                return false
            }
            guard connectResponse.buffer[1] == 0x00 else {
                return false
            }
        }
        return true
    }
}

/// An enumeration representing the types of proxy servers that can be used.
///
/// - http: Represents an HTTP proxy server.
/// - https: Represents an HTTPS proxy server.
/// - socks5: Represents a SOCKS5 proxy server.
public enum ProxyType {
    case http
    case https
    case socks5
}
