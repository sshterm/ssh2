// DNS.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/16.

import Extension
import Foundation
import Network

public class DNS {
    public static let shared: DNS = .init()
}

public extension DNS {
    /// Requires encrypted DNS name resolution using the specified DNS configuration provider.
    ///
    /// This function configures the network parameters to enforce encrypted DNS name resolution.
    /// If the encrypted resolution fails, it falls back to the provided DNS configuration.
    ///
    /// - Parameter provider: The DNS configuration provider to use for fallback resolution.
    func requireEncrypted(_ provider: DNSConfiguration) {
        NWParameters.PrivacyContext.default.requireEncryptedNameResolution(true, fallbackResolver: provider.configuration)
    }

    /// Resolves the given domain name to a list of IP addresses.
    ///
    /// - Parameter domain: The domain name to resolve.
    /// - Returns: An array of IP addresses associated with the given domain name.
    func resolveDomainName(_ domain: IP) -> [IP] {
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
