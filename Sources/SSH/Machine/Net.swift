// Net.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/2/2.

import Foundation

public extension SSH {
    func getNetIOCountersStat() async -> [NetIOCountersStat] {
        let ret1: [NetIOCountersStat] = await findNetIOCountersStat()
        sleep(1)
        var ret2: [NetIOCountersStat] = await findNetIOCountersStat()
        let cout = ret2.count - 1
        guard cout > 0 else{
            return []
        }
        for i in 0...cout {
            guard let t1 = ret1.first(where: {$0.name == ret2[i].name})  else{
                continue
            }
            ret2[i].bytesRecv = ret2[i].bytesRecv - ret1[i].bytesRecv
            ret2[i].bytesSent = ret2[i].bytesSent - ret1[i].bytesSent
        }
        return ret2
    }
    func findNetIOCountersStat() async -> [NetIOCountersStat] {
        guard let lines = await readLines(hostProc.appendingPathComponent("net/dev")) else {
            return []
        }
        guard lines.count > 1 else {
            return []
        }
        var ret: [NetIOCountersStat] = []
        for line in lines[0...] {
            let fields = line.components(separatedBy: ":")
            guard fields.count == 2 else {
                continue
            }
            let data = fields[1].trim.fields
            guard data.count > 11 else {
                continue
            }
            var io = NetIOCountersStat()
            io.name = fields[0].trim

            io.bytesRecv = (Int64(data[0]) ?? 0)
            io.packetsRecv = (Int64(data[1]) ?? 0)
            io.errin = (Int64(data[2]) ?? 0)
            io.dropin = (Int64(data[3]) ?? 0)
            io.fifoin = (Int64(data[4]) ?? 0)
            io.bytesSent = (Int64(data[8]) ?? 0)
            io.errout = (Int64(data[10]) ?? 0)
            io.dropout = (Int64(data[11]) ?? 0)
            io.fifoout = (Int64(data[12]) ?? 0)

            ret.append(io)
        }
        return ret
    }
}
