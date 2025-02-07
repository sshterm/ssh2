// Machine.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/2/2.

import Foundation

public struct PlatformInfo: Identifiable, Equatable {
    public let id = UUID()
    public var platform: String
    public var family: String
    public var version: String
}

public struct CPUTimesStat: Identifiable, Equatable {
    public let id = UUID()
    public var cpu: String = ""
    public var user: Double = 0.0
    public var system: Double = 0.0
    public var idle: Double = 0.0
    public var nice: Double = 0.0
    public var iowait: Double = 0.0
    public var irq: Double = 0.0
    public var softirq: Double = 0.0
    public var steal: Double = 0.0
    public var guest: Double = 0.0
    public var guestNice: Double = 0.0
    public var percent: Double = 0.0
}

public extension CPUTimesStat {
    static func calculateCPUBusy(t1: CPUTimesStat, t2: CPUTimesStat) -> Double {
        var t1All, t1Busy, t2All, t2Busy: Double
        t1All = t1.total
        t2All = t2.total
        t1Busy = t1.busy
        t2Busy = t2.busy
        if t2Busy <= t1Busy {
            return 0
        }
        if t2All <= t1All {
            return 1
        }
        let cpuUsage = (t2Busy - t1Busy) / (t2All - t1All)
        return min(1, max(0, cpuUsage))
    }

    var busy: Double {
        total - idle - iowait
    }

    var total: Double {
        user + system + idle + nice + iowait + irq + softirq + steal + guest + guestNice
    }
}

public struct CPUInfoStat: Identifiable, Equatable {
    public var id: Int {
        cpu
    }

    public var cpu: Int = -1
    public var vendorID: String = ""
    public var family: String = ""
    public var model: String = ""
    public var stepping: Int = 0
    public var physicalID: String = ""
    public var coreID: String = ""
    public var modelName: String = ""
    public var mhz: Double = 0.0
//    public var mhzMax: Double = 0.0
//    public var mhzMin: Double = 0.0
    public var cacheSize: Int = 0
    public var flags: [String] = []
    public var microcode: String = ""
}

public struct AvgStat: Identifiable, Equatable {
    public let id = UUID()
    public var load1: Double = 0.0
    public var load5: Double = 0.0
    public var load15: Double = 0.0
}

public struct VirtualMemoryStat: Identifiable, Equatable {
    public let id = UUID()
    public var total: Int64 = 0
    public var available: Int64 = 0
    public var used: Int64 = 0
    public var usedPercent: Double = 0.0
    public var free: Int64 = 0
    public var active: Int64 = 0
    public var inactive: Int64 = 0
    public var wired: Int64 = 0
    public var laundry: Int64 = 0
    public var buffers: Int64 = 0
    public var cached: Int64 = 0
    public var writeBack: Int64 = 0
    public var dirty: Int64 = 0
    public var writeBackTmp: Int64 = 0
    public var shared: Int64 = 0
    public var slab: Int64 = 0
    public var sreclaimable: Int64 = 0
    public var sunreclaim: Int64 = 0
    public var pageTables: Int64 = 0
    public var swapCached: Int64 = 0
    public var commitLimit: Int64 = 0
    public var committedAS: Int64 = 0
    public var highTotal: Int64 = 0
    public var highFree: Int64 = 0
    public var lowTotal: Int64 = 0
    public var lowFree: Int64 = 0
    public var swapTotal: Int64 = 0
    public var swapFree: Int64 = 0
    public var mapped: Int64 = 0
    public var vmallocTotal: Int64 = 0
    public var vmallocUsed: Int64 = 0
    public var vmallocChunk: Int64 = 0
    public var hugePagesTotal: Int64 = 0
    public var hugePagesFree: Int64 = 0
    public var hugePagesRsvd: Int64 = 0
    public var hugePagesSurp: Int64 = 0
    public var hugePageSize: Int64 = 0
    public var anonHugePages: Int64 = 0

    public var activeFile: Int64 = 0
    public var inactiveFile: Int64 = 0
    public var activeAnon: Int64 = 0
    public var inactiveAnon: Int64 = 0
    public var unevictable: Int64 = 0
}

public struct SystemStat: Identifiable, Equatable {
    public let id = UUID()
    public var context: Int = 0
    public var bootTime: Int = 0
    public var processes: Int64 = 0
    public var processesRunning: Int64 = 0
    public var processesBlocked: Int64 = 0
    public var clkTck: Double = 0.0
}

public struct NetIOCountersStat: Identifiable, Equatable {
    public var id: String {
        name
    }

    public var name: String = ""
    public var bytesSent: Int64 = 0
    public var bytesRecv: Int64 = 0
    public var packetsSent: Int64 = 0
    public var packetsRecv: Int64 = 0
    public var errin: Int64 = 0
    public var errout: Int64 = 0
    public var dropin: Int64 = 0
    public var dropout: Int64 = 0
    public var fifoin: Int64 = 0
    public var fifoout: Int64 = 0
}

public struct DiskIOCountersStat: Identifiable, Equatable {
    public var id: String {
        name
    }

    public var readCount: Int64 = 0
    public var mergedReadCount: Int64 = 0
    public var writeCount: Int64 = 0
    public var mergedWriteCount: Int64 = 0
    public var readBytes: Int64 = 0
    public var writeBytes: Int64 = 0
    public var readTime: Int64 = 0
    public var writeTime: Int64 = 0
    public var iopsInProgress: Int64 = 0
    public var ioTime: Int64 = 0
    public var weightedIO: Int64 = 0
    public var name: String = ""
}

public struct TemperatureStat: Identifiable, Equatable {
    public let id = UUID()
    public var name: String = ""
    public var label: String = ""
    public var temperature: Double = 0.0
    public var sensorHigh: Double = 0.0
    public var sensorCritical: Double = 0.0
}

public struct SystemProcess: Identifiable, Equatable {
    public var id: Int {
        pid
    }

    public var pid: Int = 0
    public var name: String = ""
    public var status: ProcessStatus = .UnknownState
    public var user: Double = 0.0
    public var system: Double = 0.0
    public var childrenUser: Double = 0.0
    public var childrenSystem: Double = 0.0
    public var iowait: Double = 0.0
    public var cpuNum: Int = 0
    public var createTime: Double = 0
    public var percent: Double = 0.0

    public static func calculatePercent(t1: SystemProcess, t2: SystemProcess, delta: Double) -> Double {
        let delta_proc = (t2.user - t1.user) + (t2.system - t1.system)
        return ((delta_proc / delta) * 100) * Double(t1.cpuNum)
    }
}

public struct HostPlatform: Identifiable, Equatable {
    public let id = UUID()
    public var platform: String = ""
    public var version: String = ""
}

public enum ProcessStatus: String, CaseIterable {
    case Daemon, Blocked, Detached, Idle, Lock, Orphan, Running, Sleep, Stop, Wait, System, Zombie, UnknownState

    public init(rawValue: String) {
        switch rawValue {
        case "A":
            self = .Daemon
        case "D", "U":
            self = .Blocked
        case "E":
            self = .Detached
        case "I":
            self = .Idle
        case "L":
            self = .Lock
        case "O":
            self = .Orphan
        case "R":
            self = .Running
        case "S":
            self = .Sleep
        case "T", "t":
            self = .Stop
        case "W":
            self = .Wait
        case "Y":
            self = .System
        case "Z":
            self = .Zombie
        default:
            self = .UnknownState
        }
    }
}
