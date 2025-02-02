// Disk.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/2/2.

import Foundation

public extension SSH {
    func getDiskIOCountersStat() async -> [DiskIOCountersStat]? {
        guard let lines = await readLines(hostProc.appendingPathComponent("diskstats")) else {
            return nil
        }
        guard lines.count > 1 else {
            return nil
        }
        var ret: [DiskIOCountersStat] = []
        for line in lines {
            let fields = line.fields
            if fields.count < 14 {
                continue
            }

            let name = fields[2]
            let reads = (Int64(fields[3]) ?? 0)
            let mergedReads = (Int64(fields[4]) ?? 0)
            let rbytes = (Int64(fields[5]) ?? 0)
            let rtime = (Int64(fields[6]) ?? 0)
            let writes = (Int64(fields[7]) ?? 0)
            let mergedWrites = (Int64(fields[8]) ?? 0)
            let wbytes = (Int64(fields[9]) ?? 0)
            let wtime = (Int64(fields[10]) ?? 0)
            let iopsInProgress = (Int64(fields[11]) ?? 0)
            let iotime = (Int64(fields[12]) ?? 0)
            let weightedIO = (Int64(fields[13]) ?? 0)

            var io = DiskIOCountersStat()
            io.readBytes = rbytes * 512
            io.writeBytes = wbytes * 512
            io.readCount = reads
            io.writeCount = writes
            io.mergedReadCount = mergedReads
            io.mergedWriteCount = mergedWrites
            io.readTime = rtime
            io.writeTime = wtime
            io.iopsInProgress = iopsInProgress
            io.ioTime = iotime
            io.weightedIO = weightedIO
            io.name = name
            ret.append(io)
        }

        return ret
    }
}
