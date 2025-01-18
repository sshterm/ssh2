// DNS.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/16.

import Foundation
import Network

public class DNS {
    public static let shared: DNS = .init()
}

public extension DNS {
    /// Requires encrypted HTTPS for DNS resolution using the specified provider.
    ///
    /// This function configures the default privacy context to require encrypted name resolution
    /// and uses the provided DNS provider's HTTPS resolver as a fallback.
    ///
    /// - Parameter provider: The DNS provider to use for HTTPS resolution.
    func requireEncryptedHTTPS(_ provider: DNSProvider) {
        NWParameters.PrivacyContext.default.requireEncryptedNameResolution(true, fallbackResolver: provider.https)
    }

    /// Requires encrypted TLS for DNS resolution using the specified DNS provider.
    ///
    /// This function configures the network parameters to enforce encrypted name resolution.
    /// It uses the provided DNS provider's TLS settings as a fallback resolver.
    ///
    /// - Parameter provider: The DNS provider to use for encrypted name resolution.
    func requireEncryptedTLS(_ provider: DNSProvider) {
        NWParameters.PrivacyContext.default.requireEncryptedNameResolution(true, fallbackResolver: provider.tls)
    }

    /// Requires the DNS provider to use encrypted communication based on the specified DNS provider type.
    ///
    /// - Parameters:
    ///   - provider: The DNS provider that will be required to use encrypted communication.
    ///   - type: The type of DNS provider which determines the encryption method to be used.
    ///           If the type is `.dot`, it will use TLS encryption. Otherwise, it will use HTTPS encryption.
    func requireEncrypted(_ provider: DNSProvider, type: DNSProviderType) {
        type == .dot ? requireEncryptedTLS(provider) : requireEncryptedHTTPS(provider)
    }

    /// Resolves the given domain name to a list of IP addresses.
    ///
    /// - Parameter domain: The domain name to resolve.
    /// - Returns: An array of IP addresses associated with the given domain name.
    func resolveDomainName(_ domain: String) -> [String] {
        IP.shared.resolveIP(domain)
    }
}
