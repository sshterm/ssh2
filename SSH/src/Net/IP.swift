// IP.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/17.

import Darwin
import Foundation

public class IP {
    public static let shared: IP = .init()
}

public extension IP {
    /// Checks if the given IPv6 address is a local network address (LAN).
    ///
    /// This function takes an IPv6 address in string format and determines if it is a local network address
    /// by checking if it falls within the unique local address (ULA) range, specifically the `fc00::/7` range.
    ///
    /// - Parameter ipStr: The IPv6 address in string format to be checked.
    /// - Returns: `true` if the IPv6 address is a local network address, `false` otherwise.
    func isIPv6LanIP(_ ipStr: String) -> Bool {
        var addr = in6_addr()
        if inet_pton(AF_INET6, ipStr, &addr) != 1 {
            return false
        }
        let bytes = withUnsafeBytes(of: &addr) { Array($0) }
        if bytes[0] == 0xFC && (bytes[1] & 0x80) == 0x80 {
            return true
        }
        return false
    }

    /// Checks if the given IP address string is a private IPv4 LAN IP address.
    ///
    /// This function verifies if the provided IP address string is a private IPv4 address
    /// within the following ranges:
    /// - 10.0.0.0 to 10.255.255.255
    /// - 172.16.0.0 to 172.31.255.255
    /// - 192.168.0.0 to 192.168.255.255
    ///
    /// - Parameter ipStr: The IP address string to check.
    /// - Returns: `true` if the IP address is a private IPv4 LAN IP address, `false` otherwise.
    func isIPv4LanIP(_ ipStr: String) -> Bool {
        var addr = in_addr()
        if inet_pton(AF_INET, ipStr, &addr) != 1 {
            return false
        }
        let ip = CFSwapInt32BigToHost(addr.s_addr)
        if (ip >= 0x0A00_0000 && ip <= 0x0AFF_FFFF) ||
            (ip >= 0xAC10_0000 && ip <= 0xAC1F_255F) ||
            (ip >= 0xAC10_0000 && ip <= 0xAC3F_FFFF) ||
            (ip >= 0xC0A8_0000 && ip <= 0xC0A8_FFFF)
        {
            return true
        }
        return false
    }

    /// Checks if the given string is a valid IPv4 address.
    ///
    /// - Parameter ipStr: The string representation of the IP address to check.
    /// - Returns: `true` if the string is a valid IPv4 address, `false` otherwise.
    func isIPv4(_ ipStr: String) -> Bool {
        var addr = in_addr()
        return inet_pton(AF_INET, ipStr, &addr) == 1
    }

    /// Checks if the given IP address string is a valid IPv6 address.
    ///
    /// - Parameter ipStr: The IP address string to be checked.
    /// - Returns: `true` if the IP address string is a valid IPv6 address, `false` otherwise.
    func isIPv6(_ ipStr: String) -> Bool {
        var addr = in6_addr()
        return inet_pton(AF_INET6, ipStr, &addr) == 1
    }

    /// Checks if the given IP address is a LAN (Local Area Network) IP address.
    ///
    /// This function determines if the provided IP address string is either an IPv4 or IPv6 LAN IP address.
    ///
    /// - Parameter ipStr: The IP address string to check.
    /// - Returns: A Boolean value indicating whether the IP address is a LAN IP address.
    func isLanIP(_ ipStr: String) -> Bool {
        isIPv4LanIP(ipStr) || isIPv6LanIP(ipStr)
    }

    /// Checks if the given string is a valid IP address (either IPv4 or IPv6).
    ///
    /// - Parameter ipStr: The string to be checked.
    /// - Returns: `true` if the string is a valid IP address, `false` otherwise.
    func isIP(_ ipStr: String) -> Bool {
        isIPv4(ipStr) || isIPv6(ipStr)
    }

    /// Resolves the given domain name to a list of IP addresses.
    ///
    /// This function uses the `getaddrinfo` system call to perform DNS resolution
    /// and returns a list of IP addresses associated with the given domain name.
    ///
    /// - Parameter domain: The domain name to resolve.
    /// - Returns: An array of IP addresses as strings. If the domain name cannot be resolved,
    ///            an empty array is returned.
    func resolveIP(_ domain: String) -> [String] {
        if isIP(domain) {
            return [domain]
        }
        var results = [String]()
        var hints = addrinfo()
        hints.ai_family = AF_UNSPEC
        hints.ai_socktype = SOCK_STREAM
        hints.ai_flags = AI_PASSIVE
        hints.ai_protocol = IPPROTO_TCP

        var infoPointer: UnsafeMutablePointer<addrinfo>?

        let status = getaddrinfo(domain, nil, &hints, &infoPointer)
        if status == 0 {
            var pointer = infoPointer
            while pointer != nil {
                if let addr = pointer?.pointee.ai_addr {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if getnameinfo(addr, socklen_t(addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                        results.append(hostname.string)
                    }
                }
                pointer = pointer?.pointee.ai_next
            }
            freeaddrinfo(infoPointer)
        }

        return results
    }
}
