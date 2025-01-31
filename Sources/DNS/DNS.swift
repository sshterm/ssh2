// DNS.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/20.

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

    func requireDisable() {
        NWParameters.PrivacyContext.default.requireEncryptedNameResolution(false, fallbackResolver: nil)
    }

    /// Resolves the given domain name to a list of IP addresses.
    ///
    /// - Parameter domain: The domain name to resolve.
    /// - Returns: An array of IP addresses associated with the given domain name.
    func resolveDomainName(_ domain: IP) -> [IP] {
        IP.resolveDomainName(domain)
    }
}
