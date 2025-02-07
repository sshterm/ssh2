// Host.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/2/3.

import Foundation

public extension SSH {
    func getHostPlatform() async -> HostPlatform? {
        guard let lines = await readLines(hostEtc.appendingPathComponent("*-release")) else {
            return nil
        }
        var platform = ""
        var version = ""
        for line in lines {
            let field = line.components(separatedBy: "=")
            guard field.count == 2 else {
                continue
            }
            switch field[0] {
            case "ID":
                platform = field[1].trimQuotes
            case "VERSION_ID":
                version = field[1].trimQuotes
            default: break
            }
        }
        guard !platform.isEmpty,!version.isEmpty else {
            return nil
        }
        return .init(platform: platform, version: version)
    }

    func isLinux() async -> Bool {
        return await getHostPlatform() != nil
    }
}
