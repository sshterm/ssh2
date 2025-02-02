// Load.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/2/2.

import Extension
import Foundation

public extension SSH {
    func getAvgStat() async -> AvgStat? {
        guard let out = await readFile(hostProc.appendingPathComponent("loadavg")) else {
            return nil
        }
        let fields = out.fields
        guard fields.count > 2 else {
            return nil
        }
        var ret = AvgStat()
        ret.load1 = Double(fields[0]) ?? 0.0
        ret.load5 = Double(fields[1]) ?? 0.0
        ret.load15 = Double(fields[2]) ?? 0.0
        return ret
    }

    func getSystemStat() async -> SystemStat? {
        guard let lines = await readLines(hostProc.appendingPathComponent("stat")) else {
            return nil
        }
        var stat = SystemStat()
        for line in lines {
            let fields = line.fields.filter { !$0.isEmpty }
            guard fields.count == 2 else {
                continue
            }
            let key = fields[0].trim
            let value = fields[1].trim
            switch key {
            case "btime":
                stat.bootTime = Int(value) ?? 0
            case "ctxt":
                stat.context = Int(value) ?? 0
            case "processes":
                stat.processes = Int(value) ?? 0
            case "procs_running":
                stat.processesRunning = Int(value) ?? 0
            case "procs_blocked":
                stat.processesBlocked = Int(value) ?? 0
            default:
                break
            }
        }
        return stat
    }
}
