// Net.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/2/2.

import Foundation

public extension SSH {
    func getNetIOCountersStat() async -> [NetIOCountersStat]? {
        guard let lines = await readLines(hostProc.appendingPathComponent("net/dev")) else {
            return nil
        }
        guard lines.count > 1 else {
            return nil
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
