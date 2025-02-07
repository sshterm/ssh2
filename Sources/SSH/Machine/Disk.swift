// Disk.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/2/3.

import Foundation

public extension SSH {
    func getDiskIOCountersStat() async -> [DiskIOCountersStat] {
        let ret1: [DiskIOCountersStat] = await findDiskIOCountersStat()
        sleep(1)
        var ret2: [DiskIOCountersStat] = await findDiskIOCountersStat()
        let cout = ret2.count - 1
        guard cout > 0 else{
            return []
        }
        for i in 0...cout {
            guard let t1 = ret1.first(where: {$0.name == ret2[i].name})  else{
                continue
            }
            ret2[i].readBytes = ret2[i].readBytes - ret1[i].readBytes
            ret2[i].writeBytes = ret2[i].writeBytes - ret1[i].writeBytes
        }
        return ret2
    }
    func findDiskIOCountersStat() async -> [DiskIOCountersStat] {
        guard let lines = await readLines(hostProc.appendingPathComponent("diskstats")) else {
            return []
        }
        guard lines.count > 1 else {
            return []
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
            io.readBytes = rbytes * 0x200
            io.writeBytes = wbytes * 0x200
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
