// CPU.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/2/2.

import Extension
import Foundation

public extension SSH {
    func getCPUTimesStat() async -> [CPUTimesStat]? {
        guard let lines = await readLines(hostProc.appendingPathComponent("stat")) else {
            return nil
        }
        var ret: [CPUTimesStat] = []
        for line in lines {
            guard line.hasPrefix("cpu") else {
                continue
            }
            let fields = line.fields
            if fields.count < 8 {
                continue
            }
            guard fields[0].hasPrefix("cpu") else {
                continue
            }
            var cpu = fields[0]
            var ct = CPUTimesStat()
            ct.cpu = cpu
            ct.user = Double(fields[1]) ?? 0
            ct.nice = Double(fields[2]) ?? 0
            ct.system = Double(fields[3]) ?? 0
            ct.idle = Double(fields[4]) ?? 0
            ct.iowait = Double(fields[5]) ?? 0
            ct.irq = Double(fields[6]) ?? 0
            ct.softirq = Double(fields[7]) ?? 0
            if fields.count > 8 {
                let steal = Double(fields[8]) ?? 0
                if steal > 0.0 {
                    ct.steal = steal / 100.0
                }
            }
            if fields.count > 9 {
                let guest = Double(fields[9]) ?? 0
                if guest > 0.0 {
                    ct.guest = guest / 100.0
                }
            }
            if fields.count > 10 {
                let guestNice = Double(fields[10]) ?? 0
                if guestNice > 0.0 {
                    ct.guestNice = guestNice / 100.0
                }
            }
            ret.append(ct)
        }
        return ret
    }

    func getCPUInfoStat() async -> [CPUInfoStat]? {
        guard let lines = await readLines(hostProc.appendingPathComponent("cpuinfo")) else {
            return nil
        }
        var ret: [CPUInfoStat] = []
        var c = CPUInfoStat()
        var processorName = ""
        for line in lines {
            let fields = line.components(separatedBy: ":")
            guard fields.count > 1 else {
                continue
            }
            let key = fields[0].trim
            let value = fields[1].trim
            switch key {
            case "Processor":
                processorName = value
            case "processor", "cpu number":
                if c.cpu >= 0 {
                    // await finishCPUInfo(&c)
                    ret.append(c)
                }
                c = CPUInfoStat()
                c.modelName = processorName
                c.cpu = Int(value) ?? 0
            case "vendorId", "vendor_id":
                c.vendorID = value
                if value.contains("S390") {
                    processorName = "S390"
                }
            case "CPU implementer":
                if let v = Int(value) {
                    switch v {
                    case 0x41:
                        c.vendorID = "ARM"
                    case 0x42:
                        c.vendorID = "Broadcom"
                    case 0x43:
                        c.vendorID = "Cavium"
                    case 0x44:
                        c.vendorID = "DEC"
                    case 0x46:
                        c.vendorID = "Fujitsu"
                    case 0x48:
                        c.vendorID = "HiSilicon"
                    case 0x49:
                        c.vendorID = "Infineon"
                    case 0x4D:
                        c.vendorID = "Motorola/Freescale"
                    case 0x4E:
                        c.vendorID = "NVIDIA"
                    case 0x50:
                        c.vendorID = "APM"
                    case 0x51:
                        c.vendorID = "Qualcomm"
                    case 0x56:
                        c.vendorID = "Marvell"
                    case 0x61:
                        c.vendorID = "Apple"
                    case 0x69:
                        c.vendorID = "Intel"
                    case 0xC0:
                        c.vendorID = "Ampere"
                    default: break
                    }
                }
            case "cpu family":
                c.family = value
            case "model", "CPU part":
                c.model = value
                if c.vendorID == "ARM" {
                    if let v = UInt64(value) {
                        switch v {
                        case 0x810:
                            c.modelName = "ARM810"
                        case 0x920:
                            c.modelName = "ARM920"
                        case 0x922:
                            c.modelName = "ARM922"
                        case 0x926:
                            c.modelName = "ARM926"
                        case 0x940:
                            c.modelName = "ARM940"
                        case 0x946:
                            c.modelName = "ARM946"
                        case 0x966:
                            c.modelName = "ARM966"
                        case 0xA20:
                            c.modelName = "ARM1020"
                        case 0xA22:
                            c.modelName = "ARM1022"
                        case 0xA26:
                            c.modelName = "ARM1026"
                        case 0xB02:
                            c.modelName = "ARM11 MPCore"
                        case 0xB36:
                            c.modelName = "ARM1136"
                        case 0xB56:
                            c.modelName = "ARM1156"
                        case 0xB76:
                            c.modelName = "ARM1176"
                        case 0xC05:
                            c.modelName = "Cortex-A5"
                        case 0xC07:
                            c.modelName = "Cortex-A7"
                        case 0xC08:
                            c.modelName = "Cortex-A8"
                        case 0xC09:
                            c.modelName = "Cortex-A9"
                        case 0xC0D:
                            c.modelName = "Cortex-A17"
                        case 0xC0F:
                            c.modelName = "Cortex-A15"
                        case 0xC0E:
                            c.modelName = "Cortex-A17"
                        case 0xC14:
                            c.modelName = "Cortex-R4"
                        case 0xC15:
                            c.modelName = "Cortex-R5"
                        case 0xC17:
                            c.modelName = "Cortex-R7"
                        case 0xC18:
                            c.modelName = "Cortex-R8"
                        case 0xC20:
                            c.modelName = "Cortex-M0"
                        case 0xC21:
                            c.modelName = "Cortex-M1"
                        case 0xC23:
                            c.modelName = "Cortex-M3"
                        case 0xC24:
                            c.modelName = "Cortex-M4"
                        case 0xC27:
                            c.modelName = "Cortex-M7"
                        case 0xC60:
                            c.modelName = "Cortex-M0+"
                        case 0xD01:
                            c.modelName = "Cortex-A32"
                        case 0xD02:
                            c.modelName = "Cortex-A34"
                        case 0xD03:
                            c.modelName = "Cortex-A53"
                        case 0xD04:
                            c.modelName = "Cortex-A35"
                        case 0xD05:
                            c.modelName = "Cortex-A55"
                        case 0xD06:
                            c.modelName = "Cortex-A65"
                        case 0xD07:
                            c.modelName = "Cortex-A57"
                        case 0xD08:
                            c.modelName = "Cortex-A72"
                        case 0xD09:
                            c.modelName = "Cortex-A73"
                        case 0xD0A:
                            c.modelName = "Cortex-A75"
                        case 0xD0B:
                            c.modelName = "Cortex-A76"
                        case 0xD0C:
                            c.modelName = "Neoverse-N1"
                        case 0xD0D:
                            c.modelName = "Cortex-A77"
                        case 0xD0E:
                            c.modelName = "Cortex-A76AE"
                        case 0xD13:
                            c.modelName = "Cortex-R52"
                        case 0xD20:
                            c.modelName = "Cortex-M23"
                        case 0xD21:
                            c.modelName = "Cortex-M33"
                        case 0xD40:
                            c.modelName = "Neoverse-V1"
                        case 0xD41:
                            c.modelName = "Cortex-A78"
                        case 0xD42:
                            c.modelName = "Cortex-A78AE"
                        case 0xD43:
                            c.modelName = "Cortex-A65AE"
                        case 0xD44:
                            c.modelName = "Cortex-X1"
                        case 0xD46:
                            c.modelName = "Cortex-A510"
                        case 0xD47:
                            c.modelName = "Cortex-A710"
                        case 0xD48:
                            c.modelName = "Cortex-X2"
                        case 0xD49:
                            c.modelName = "Neoverse-N2"
                        case 0xD4A:
                            c.modelName = "Neoverse-E1"
                        case 0xD4B:
                            c.modelName = "Cortex-A78C"
                        case 0xD4C:
                            c.modelName = "Cortex-X1C"
                        case 0xD4D:
                            c.modelName = "Cortex-A715"
                        case 0xD4E:
                            c.modelName = "Cortex-X3"
                        default:
                            c.modelName = "Undefined"
                        }
                    }
                }
            case "Model Name", "model name", "cpu":
                c.modelName = value
                if value.contains("POWER") {
                    c.model = value.components(separatedBy: " ")[0]
                    c.family = "POWER"
                    c.vendorID = "IBM"
                }
            case "stepping", "revision", "CPU revision":
                var val = value
                if key == "revision" {
                    val = value.components(separatedBy: ".")[0]
                }
                c.stepping = Int(val) ?? 0
            case "cpu MHz", "clock", "cpu MHz dynamic":
                c.mhz = Double(value.replacingOccurrences(of: "MHz", with: "", options: [], range: nil).trim) ?? 0.0
            case "cache size":
                c.cacheSize = Int(value.replacingOccurrences(of: "KB", with: "", options: [], range: nil).trim) ?? 0
            case "physical id":
                c.physicalID = value
            case "core id":
                c.coreID = value
            case "flags", "Features":
                c.flags = value.fields
            case "microcode":
                c.microcode = value
            default: break
            }
        }
        if c.cpu >= 0 {
            // await finishCPUInfo(&c)
            ret.append(c)
        }
        return ret
    }

    private func finishCPUInfo(_ c: inout CPUInfoStat) async {
        if c.coreID.count == 0 {
            if let lines = await readLines(sysCPUPath(c.cpu, "topology/core_id")),!lines.isEmpty {
                c.coreID = lines[0]
            }
        }
        if let lines = await readLines(sysCPUPath(c.cpu, "cpufreq/cpuinfo_max_freq")),!lines.isEmpty, let value = Double(lines[0]) {
            c.mhz = value / 1000.0
        }
    }

    private func sysCPUPath(_ cpu: Int, _ relPath: String) -> String {
        hostSys.appendingPathComponent(String(format: "devices/system/cpu/cpu%d", cpu)).appendingPathComponent(relPath)
    }
}
