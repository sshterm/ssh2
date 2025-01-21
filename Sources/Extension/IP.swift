// IP.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import Darwin
import Foundation

public typealias IP = String

public extension IP {
    /// A computed property that determines if the IP address is an IPv6 LAN IP.
    ///
    /// This property checks if the IP address falls within the following ranges:
    /// - `::/127` (loopback address)
    /// - `fc00::/7` (unique local addresses)
    /// - `fe80::/10` (link-local addresses)
    /// - `ff00::/8` (multicast addresses)
    ///
    /// The method uses `inet_pton` to convert the string representation of the IP address to an `in6_addr` structure.
    /// It then checks the byte values of the address to determine if it falls within any of the specified ranges.
    ///
    /// - Returns: `true` if the IP address is an IPv6 LAN IP, `false` otherwise.
    var isIPv6LanIP: Bool {
        var addr = in6_addr()
        if inet_pton(AF_INET6, self, &addr) != 1 {
            return false
        }
        let bytes = withUnsafeBytes(of: &addr) { Array($0) }
        if (bytes[0] == 0x00 && bytes[1] == 0x00 && bytes[2] == 0x00 && bytes[3] == 0x00 && bytes[4] == 0x00 && bytes[5] == 0x00 && bytes[6] == 0x00 && bytes[7] == 0x00 && bytes[8] == 0x00 && bytes[9] == 0x00 && bytes[10] == 0x00 && bytes[11] == 0x00 && bytes[12] == 0x00 && bytes[13] == 0x00 && bytes[14] == 0x00 && bytes[15] == 0x01) || // ::/127
            (bytes[0] & 0xFE) == 0xFC || // fc00::/7
            (bytes[0] == 0xFE && (bytes[1] & 0xC0) == 0x80) || // fe80::/10
            bytes[0] == 0xFF // ff00::/8
        {
            return true
        }
        return false
    }

    /// A computed property that determines if the IP address is a local area network (LAN) IPv4 address.
    ///
    /// The property checks if the IP address falls within the following ranges:
    /// - 0.0.0.0/8
    /// - 10.0.0.0/8
    /// - 100.64.0.0/10
    /// - 127.0.0.0/8
    /// - 169.254.0.0/16
    /// - 172.16.0.0/12
    /// - 192.0.0.0/24
    /// - 192.0.2.0/24
    /// - 192.88.99.0/24
    /// - 192.168.0.0/16
    /// - 198.18.0.0/15
    /// - 198.51.100.0/24
    /// - 203.0.113.0/24
    /// - 224.0.0.0/3
    ///
    /// - Returns: `true` if the IP address is a LAN IPv4 address, `false` otherwise.
    var isIPv4LanIP: Bool {
        var addr = in_addr()
        if inet_pton(AF_INET, self, &addr) != 1 {
            return false
        }
        let ip = CFSwapInt32BigToHost(addr.s_addr)
        if (ip >= 0x0000_0000 && ip <= 0x00FF_FFFF) || // 0.0.0.0/8
            (ip >= 0x0A00_0000 && ip <= 0x0AFF_FFFF) || // 10.0.0.0/8
            (ip >= 0x6440_0000 && ip <= 0x647F_FFFF) || // 100.64.0.0/10
            (ip >= 0x7F00_0000 && ip <= 0x7FFF_FFFF) || // 127.0.0.0/8
            (ip >= 0xA9FE_0000 && ip <= 0xA9FE_FFFF) || // 169.254.0.0/16
            (ip >= 0xAC10_0000 && ip <= 0xAC1F_FFFF) || // 172.16.0.0/12
            (ip >= 0xC000_0000 && ip <= 0xC000_00FF) || // 192.0.0.0/24
            (ip >= 0xC000_0200 && ip <= 0xC000_02FF) || // 192.0.2.0/24
            (ip >= 0xC058_6300 && ip <= 0xC058_63FF) || // 192.88.99.0/24
            (ip >= 0xC0A8_0000 && ip <= 0xC0A8_FFFF) || // 192.168.0.0/16
            (ip >= 0xC612_0000 && ip <= 0xC613_FFFF) || // 198.18.0.0/15
            (ip >= 0xC633_6400 && ip <= 0xC633_64FF) || // 198.51.100.0/24
            (ip >= 0xCB00_7100 && ip <= 0xCB00_71FF) || // 203.0.113.0/24
            (ip >= 0xE000_0000 && ip <= 0xFFFF_FFFF) // 224.0.0.0/3
        {
            return true
        }
        return false
    }

    /// A computed property that checks if the IP address is a fake IP.
    ///
    /// This property converts the string representation of the IP address to a binary format
    /// and checks if it falls within the range of fake IP addresses (198.18.0.0 to 198.19.255.255).
    ///
    /// - Returns: `true` if the IP address is a fake IP, `false` otherwise.
    var isFakeIP: Bool {
        var addr = in_addr()
        if inet_pton(AF_INET, self, &addr) != 1 {
            return false
        }
        let ip = CFSwapInt32BigToHost(addr.s_addr)
        if
            ip >= 0xC612_0000 && ip <= 0xC613_FFFF
        {
            return true
        }
        return false
    }

    /// A computed property that checks if the string is a valid IPv4 address.
    ///
    /// This property uses the `inet_pton` function to determine if the string
    /// can be converted to a valid IPv4 address.
    ///
    /// - Returns: `true` if the string is a valid IPv4 address, `false` otherwise.
    var isIPv4: Bool {
        var addr = in_addr()
        return inet_pton(AF_INET, self, &addr) == 1
    }

    /// A computed property that checks if the given IP address string is an IPv6 address.
    ///
    /// This property uses the `inet_pton` function to determine if the IP address string
    /// can be successfully converted to an IPv6 address.
    ///
    /// - Returns: A Boolean value indicating whether the IP address string is an IPv6 address.
    var isIPv6: Bool {
        var addr = in6_addr()
        return inet_pton(AF_INET6, self, &addr) == 1
    }

    /// A computed property that checks if the IP address is a LAN (Local Area Network) IP address.
    /// It returns `true` if the IP address is either an IPv4 LAN IP or an IPv6 LAN IP.
    var isLanIP: Bool {
        isIPv4LanIP || isIPv6LanIP
    }

    /// A computed property that checks if the current instance is an IP address.
    /// It returns `true` if the instance is either an IPv4 or IPv6 address.
    var isIP: Bool {
        isIPv4 || isIPv6
    }

    /// A computed property that returns the size of the IP address in bytes.
    ///
    /// - Returns: The size of the IP address in bytes, which is either the size of `in_addr` for IPv4 or `in6_addr` for IPv6.
    var size: Int {
        isIPv4 ? MemoryLayout<in_addr>.size : MemoryLayout<in6_addr>.size
    }

    /// A computed property that returns the address family of the IP address.
    ///
    /// - Returns: The address family as an `Int32`, which is `AF_INET` for IPv4 or `AF_INET6` for IPv6.
    var af: Int32 {
        isIPv4 ? AF_INET : AF_INET6
    }

    /// A computed property that returns the raw byte representation of the IP address.
    ///
    /// This property uses `inet_pton` to convert the IP address string into its binary form. The resulting `Data` object contains the raw bytes of the IP address, which can be useful for low-level network operations, serialization, or other byte-wise manipulations.
    ///
    /// - Returns: A `Data` object containing the raw bytes of the IP address.
    var addr: Data {
        var bytes = [UInt8](repeating: 0, count: size)
        inet_pton(af, self, &bytes)
        return Data(bytes)
    }

    /// Resolves the given domain name to a list of IP addresses.
    ///
    /// - Parameter domain: The domain name to resolve.
    /// - Returns: An array of IP addresses associated with the given domain name.
    static func resolveDomainName(_ domain: IP) -> [IP] {
        if domain.isIP {
            return [domain]
        }
        var results = [IP]()
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
