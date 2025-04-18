// Load.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/2/3.

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
        let cpu = Double(await getCPUCount())
        var ret = AvgStat()
        ret.load1 = (Double(fields[0]) ?? 0.0) / cpu
        ret.load5 = (Double(fields[1]) ?? 0.0) / cpu
        ret.load15 = (Double(fields[2]) ?? 0.0) / cpu
        if ret.load1 < 0 {
            ret.load1 = 0
        }
        if ret.load5 < 0 {
            ret.load5 = 0
        }
        if ret.load15 < 0 {
            ret.load15 = 0
        }
        return ret
    }

    func getSystemStat() async -> SystemStat? {
        guard let lines = await readLines(hostProc.appendingPathComponent("stat")) else {
            return nil
        }
        var stat = SystemStat()
        stat.clkTck = await getClocksPerSec()
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
                stat.processes = Int64(value) ?? 0
            case "procs_running":
                stat.processesRunning = Int64(value) ?? 0
            case "procs_blocked":
                stat.processesBlocked = Int64(value) ?? 0
            default:
                break
            }
        }
        return stat
    }

    func getClocksPerSec() async -> Double {
        guard let clkTck = await exec("getconf CLK_TCK")?.string?.trim,!clkTck.isEmpty, let sec = Double(clkTck), sec > 0 else {
            return 0x64
        }
        return sec
    }
}
