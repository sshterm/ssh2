// Process.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/2/7.

import Extension
import Foundation

public extension SSH {
    func getSystemProcess(bootTime: Double, clkTck: Double = 0x64) async -> [SystemProcess] {
        let ret1: [SystemProcess] = await findSystemProcess(bootTime: bootTime, clkTck: clkTck)
//        await Task.sleep(seconds: 1)
//        var ret2: [SystemProcess] = await findSystemProcess(bootTime: bootTime,clkTck: clkTck)
//        let cout = ret2.count - 1
//        guard cout > 0 else {
//            return []
//        }
//        for i in 0 ... cout {
//            guard let t1 = ret1.first(where: { $0.pid == ret2[i].pid }) else {
//                continue
//            }
//            ret2[i].percent = SystemProcess.calculatePercent(t1: t1, t2: ret2[i], delta: 1)
//        }
        return ret1
    }

    func findSystemProcess(bootTime: Double, clkTck: Double = 0x64) async -> [SystemProcess] {
        guard let lines = await readLines(hostProc.appendingPathComponent("[0-9]*/stat")) else {
            return []
        }
        var ret: [SystemProcess] = []
        for line in lines {
            let fields = line.fields
            guard fields.count > 40 else {
                continue
            }
            var v = SystemProcess()
            v.pid = Int(fields[0]) ?? 0
            v.name = String(fields[1].dropFirst().dropLast())
            v.status = .init(rawValue: fields[2])
            v.cpuNum = Int(fields[38]) ?? 0
            v.user = (Double(fields[13]) ?? 0.0) / clkTck
            v.system = (Double(fields[14]) ?? 0.0) / clkTck
            v.childrenUser = (Double(fields[15]) ?? 0.0) / clkTck
            v.childrenSystem = (Double(fields[16]) ?? 0.0) / clkTck
            v.iowait = (Double(fields[41]) ?? 0.0) / clkTck
            v.createTime = ((Double(fields[21]) ?? 0.0) / clkTck) + bootTime
            ret.append(v)
        }

        return ret
    }
}
