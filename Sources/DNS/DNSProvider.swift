// DNSProvider.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import Foundation
import Network

public struct DNSConfiguration {
    public let resolver: DNSProviderType
    public let ips: [String]
    public let host: String
    public let port: NWEndpoint.Port

    public init(resolver: DNSProviderType, ips: [String], host: String, port: NWEndpoint.Port) {
        self.resolver = resolver
        self.ips = ips
        self.host = host
        self.port = port
    }

    var configuration: NWParameters.PrivacyContext.ResolverConfiguration? {
        switch resolver {
        case .doh:
            guard let url = URL(string: host) else {
                return nil
            }
            return .https(url, serverAddresses: ips.map { NWEndpoint.hostPort(host: NWEndpoint.Host($0), port: port) })
        case .dot:
            return .tls(NWEndpoint.hostPort(host: NWEndpoint.Host(host), port: port), serverAddresses: ips.map { NWEndpoint.hostPort(host: NWEndpoint.Host($0), port: port) })
        }
    }
}

public enum DNSProviderType: String, CaseIterable {
    case doh, dot
}

public enum PubDNS: String, CaseIterable {
    case alidns, adguard, google, cloudflare, quad9, s360 = "360", dnspod

    public var name: String {
        switch self {
        case .cloudflare:
            "Cloudflare"
        case .google:
            "Google"
        case .quad9:
            "Quad9"
        case .alidns:
            "AliDNS"
        case .s360:
            "360"
        case .adguard:
            "AdGuard"
        case .dnspod:
            "DNSPod"
        }
    }

    public var ips: [String] {
        switch self {
        case .alidns:
            [
                "2400:3200::1",
                "2400:3200:baba::1",
                "223.5.5.5",
                "223.6.6.6",
            ]
        case .google:
            [
                "2001:4860:4860::8888",
                "2001:4860:4860::8844",
                "8.8.8.8",
                "8.8.4.4",
            ]
        case .cloudflare:
            [
                "2606:4700:4700::1111",
                "2606:4700:4700::1001",
                "1.1.1.1",
                "1.0.0.1",
            ]
        case .quad9:
            [
                "2620:fe::fe",
                "2620:fe::9",
                "9.9.9.9",
                "149.112.112.112",
            ]
        case .s360:
            [
                "101.226.4.6",
                "218.30.118.6",
                "123.125.81.6",
                "140.207.198.6",
            ]
        case .adguard:
            [
                "2a10:50c0::ad1:ff",
                "2a10:50c0::ad2:ff",
                "94.140.14.14",
                "94.140.15.15",
            ]
        case .dnspod:
            [
                "1.12.12.12",
                "120.53.53.53",
            ]
        }
    }

    public var url: String {
        switch self {
        case .alidns:
            "https://dns.alidns.com/dns-query"
        case .google:
            "https://dns.google/dns-query"
        case .cloudflare:
            "https://cloudflare-dns.com/dns-query"
        case .quad9:
            "https://dns.quad9.net/dns-query"
        case .s360:
            "https://doh.360.cn/dns-query"
        case .adguard:
            "https://dns.adguard.com/dns-query"
        case .dnspod:
            "https://doh.pub/dns-query"
        }
    }

    public var host: String {
        switch self {
        case .alidns:
            "dns.alidns.com"
        case .google:
            "dns.google"
        case .cloudflare:
            "one.one.one.one"
        case .quad9:
            "dns.quad9.net"
        case .s360:
            "dot.360.cn"
        case .adguard:
            "dns.adguard.com"
        case .dnspod:
            "dot.pub"
        }
    }

    public var dohConfiguration: DNSConfiguration {
        .init(resolver: .doh, ips: ips, host: url, port: .https)
    }

    public var dotConfiguration: DNSConfiguration {
        .init(resolver: .doh, ips: ips, host: host, port: 853)
    }
}
