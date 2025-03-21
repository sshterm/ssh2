// Docker.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/2/3.

import Foundation

public extension SSH {
    func getDockerStat() async -> [DockerStat]? {
        guard let data = await exec(["docker", "ps", "-a", "--no-trunc", "--format", "\"{{.ID}}|{{.Image}}|{{.Names}}|{{.Status}}\""]) else {
            return nil
        }
        guard let text = data.string?.trim,!text.isEmpty else {
            return nil
        }
        let lines = text.lines
        var ret: [DockerStat] = []
        for line in lines {
            let cols = line.components(separatedBy: "|")
            guard cols.count == 4 else {
                continue
            }
            let names = cols[2].components(separatedBy: ",")
            ret.append(DockerStat(containerID: cols[0], name: names[0], image: cols[1], status: cols[3], running: cols[3].contains("Up")))
        }
        return ret
    }

    func dockerStart(_ id: String) async {
        await exec(["docker", "start", id])
    }

    func dockerStop(_ id: String) async {
        await exec(["docker", "stop", id])
    }

    func dockerRestart(_ id: String) async {
        await exec(["docker", "restart", id])
    }

    func dockerInspect(_ id: String) async -> String? {
        guard let data = await exec(["docker", "inspect", id]) else {
            return nil
        }
        guard let text = data.string?.trim,!text.isEmpty else {
            return nil
        }
        return text
    }

    func dockerLogs(_ id: String) async -> String? {
        guard let data = await exec(["docker", "logs", "--tail", "1000", id]) else {
            return nil
        }
        guard let text = data.string?.trim,!text.isEmpty else {
            return nil
        }
        return text
    }

    func getDockerStats() async -> [DockerStats]? {
        guard let data = await exec(["docker", "stats", "--no-trunc", "--no-stream", "--format", "\"{{.ID}}|{{.Name}}|{{.CPUPerc}}|{{.MemPerc}}|{{.NetIO}}|{{.BlockIO}}\""]) else {
            return nil
        }
        guard let text = data.string?.trim,!text.isEmpty else {
            return nil
        }
        let lines = text.lines
        var ret: [DockerStats] = []
        for line in lines {
            let cols = line.components(separatedBy: "|")
            guard cols.count == 6 else {
                continue
            }
            let names = cols[1].components(separatedBy: ",")
            ret.append(DockerStats(containerID: cols[0], name: names[0], CPUPerc: cols[2], memPerc: cols[3], netIO: cols[4], blockIO: cols[5]))
        }
        return ret
    }
}
