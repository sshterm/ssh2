// Net.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/2/3.

import Foundation

public extension SSH {
    func getNetIOCountersStat() async -> [NetIOCountersStat] {
        let ret1: [NetIOCountersStat] = await findNetIOCountersStat()
        await Task.sleep(seconds: 1)
        var ret2: [NetIOCountersStat] = await findNetIOCountersStat()
        let cout = ret2.count - 1
        guard cout > 0 else {
            return []
        }
        for i in 0 ... cout {
            guard let t1 = ret1.first(where: { $0.name == ret2[i].name }) else {
                continue
            }
            ret2[i].bytesRecv = ret2[i].bytesRecv - t1.bytesRecv
            ret2[i].bytesSent = ret2[i].bytesSent - t1.bytesSent

            guard ret2[i].name != "lo" else {
                continue
            }

            guard let lines = await readLines(String(format: "%@ %@ %@", hostClass.appendingPathComponent(String(format: "net/%@/mtu", ret2[i].name)), hostClass.appendingPathComponent(String(format: "net/%@/speed", ret2[i].name)), hostClass.appendingPathComponent(String(format: "net/%@/address", ret2[i].name)))) else {
                continue
            }
            guard lines.count == 3 else {
                continue
            }
            ret2[i].mtu = Int64(lines[0]) ?? 0
            ret2[i].speed = (Int64(lines[1]) ?? 0) * 1_000_000
            ret2[i].address = lines[2]
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

            io.bytesRecvTotal = io.bytesRecv
            io.bytesSentTotal = io.bytesSent

            ret.append(io)
        }
        return ret
    }
}
