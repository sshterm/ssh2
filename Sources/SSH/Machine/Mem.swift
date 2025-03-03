// Mem.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/2/3.

import Foundation

public extension SSH {
    func getVirtualMemoryStat() async -> VirtualMemoryStat? {
        guard let lines = await readLines(hostProc.appendingPathComponent("meminfo")) else {
            return nil
        }
        var ret = VirtualMemoryStat()
        var memavail = false
        for line in lines {
            let fields = line.components(separatedBy: ":")
            guard fields.count == 2 else {
                continue
            }
            let key = fields[0].trim
            let value = fields[1].trim.replacingOccurrences(of: "kB", with: "", options: [], range: nil).trim
            switch key {
            case "MemTotal":
                ret.total = (Int64(value) ?? 0) * 0x400
            case "MemFree":
                ret.free = (Int64(value) ?? 0) * 0x400
            case "MemAvailable":
                memavail = true
                ret.available = (Int64(value) ?? 0) * 0x400
            case "Buffers":
                ret.buffers = (Int64(value) ?? 0) * 0x400
            case "Cached":
                ret.cached = (Int64(value) ?? 0) * 0x400
            case "Active":
                ret.active = (Int64(value) ?? 0) * 0x400
            case "Inactive":
                ret.inactive = (Int64(value) ?? 0) * 0x400
            case "Active(anon)":
                ret.activeAnon = (Int64(value) ?? 0) * 0x400
            case "Inactive(anon)":
                ret.inactiveAnon = (Int64(value) ?? 0) * 0x400
            case "Active(file)":
                ret.activeFile = (Int64(value) ?? 0) * 0x400
            case "Inactive(file)":
                ret.inactiveFile = (Int64(value) ?? 0) * 0x400
            case "Unevictable":
                ret.unevictable = (Int64(value) ?? 0) * 0x400
            case "Writeback":
                ret.writeBack = (Int64(value) ?? 0) * 0x400
            case "WritebackTmp":
                ret.writeBackTmp = (Int64(value) ?? 0) * 0x400
            case "Dirty":
                ret.dirty = (Int64(value) ?? 0) * 0x400
            case "Shmem":
                ret.shared = (Int64(value) ?? 0) * 0x400
            case "Slab":
                ret.slab = (Int64(value) ?? 0) * 0x400
            case "SReclaimable":
                ret.sreclaimable = (Int64(value) ?? 0) * 0x400
            case "SUnreclaim":
                ret.sunreclaim = (Int64(value) ?? 0) * 0x400
            case "PageTables":
                ret.pageTables = (Int64(value) ?? 0) * 0x400
            case "SwapCached":
                ret.swapCached = (Int64(value) ?? 0) * 0x400
            case "CommitLimit":
                ret.commitLimit = (Int64(value) ?? 0) * 0x400
            case "Committed_AS":
                ret.committedAS = (Int64(value) ?? 0) * 0x400
            case "HighTotal":
                ret.highTotal = (Int64(value) ?? 0) * 0x400
            case "HighFree":
                ret.highFree = (Int64(value) ?? 0) * 0x400
            case "LowTotal":
                ret.lowTotal = (Int64(value) ?? 0) * 0x400
            case "LowFree":
                ret.lowFree = (Int64(value) ?? 0) * 0x400
            case "SwapTotal":
                ret.swapTotal = (Int64(value) ?? 0) * 0x400
            case "SwapFree":
                ret.swapFree = (Int64(value) ?? 0) * 0x400
            case "Mapped":
                ret.mapped = (Int64(value) ?? 0) * 0x400
            case "VmallocTotal":
                ret.vmallocTotal = (Int64(value) ?? 0) * 0x400
            case "VmallocUsed":
                ret.vmallocUsed = (Int64(value) ?? 0) * 0x400
            case "VmallocChunk":
                ret.vmallocChunk = (Int64(value) ?? 0) * 0x400
            case "HugePages_Total":
                ret.hugePagesTotal = (Int64(value) ?? 0)
            case "HugePages_Free":
                ret.hugePagesFree = (Int64(value) ?? 0)
            case "HugePages_Rsvd":
                ret.hugePagesRsvd = (Int64(value) ?? 0)
            case "HugePages_Surp":
                ret.hugePagesSurp = (Int64(value) ?? 0)
            case "Hugepagesize":
                ret.hugePageSize = (Int64(value) ?? 0) * 0x400
            case "AnonHugePages":
                ret.anonHugePages = (Int64(value) ?? 0) * 0x400
            default: break
            }
        }
        if !memavail {
            ret.available = ret.cached + ret.free
        }
        ret.used = ret.total - ret.free - ret.buffers - ret.cached
        ret.usedPercent = Double(ret.used) / Double(ret.total)
        return ret
    }
}
