// Proxy.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/25.

import Extension
import Foundation
import Socket

public class Proxy {
    let configuration: ProxyConfig
    public init(_ configuration: ProxyConfig) {
        self.configuration = configuration
    }
}

public extension Proxy {
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
    func connect(_ host: String, _ port: String, _ timeout: Int = 5) -> Socket {
        let socket = Socket.create(configuration.host, configuration.port, timeout)
        guard socket.isConnected else {
            return .init()
        }

        for ip in IP.resolveDomainName(host) {
            guard connect(socket, ip, port) else {
                continue
            }
            return socket
        }
        socket.close()
        return socket
    }

    func connect(_ fd: Socket, _ host: String, _ port: String) -> Bool {
        switch configuration.type {
        case .http:
            let connectString = "CONNECT \(host):\(port) HTTP/1.1\r\n" +
                (!configuration.username.isEmpty && !configuration.password.isEmpty ? "Proxy-Authorization: Basic \(Data("\(configuration.username):\(configuration.password)".utf8).base64EncodedString().trimmingCharacters(in: .whitespacesAndNewlines))\r\n" : "") +
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
            if !configuration.username.isEmpty, !configuration.password.isEmpty {
                greeting = [0x05, 0x01, 0x02]
            }
            guard fd.write(&greeting, greeting.count) == greeting.count else {
                return false
            }
            let response: Buffer<UInt8> = .init(2)
            guard fd.read(response.buffer, response.count) == response.count else {
                return false
            }
            guard response.buffer[0] == 0x05 else {
                return false
            }
            if response.buffer[1] == 0x02 {
                guard !configuration.username.isEmpty, !configuration.password.isEmpty else {
                    return false
                }
                let usernameBytes = [UInt8](configuration.username.utf8)
                let passwordBytes = [UInt8](configuration.password.utf8)
                var authRequest: [UInt8] = [0x01, UInt8(usernameBytes.count)] + usernameBytes + [UInt8(passwordBytes.count)] + passwordBytes
                guard fd.write(&authRequest, authRequest.count) == authRequest.count else {
                    return false
                }
                let response: Buffer<UInt8> = .init(2)
                guard fd.read(response.buffer, response.count) == response.count else {
                    return false
                }
                guard response.buffer[0] == 0x01 else {
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
                request.append(0x03)
                let domainBytes = [UInt8](host.utf8)
                request.append(UInt8(domainBytes.count))
                request += domainBytes
            }
            request += (UInt16(port) ?? 22).bytes.reversed()
            guard fd.write(&request, request.count) == request.count else {
                return false
            }
            let connectResponse: Buffer<UInt8> = .init(10)
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
