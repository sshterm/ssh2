// Sensors.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/2/3.

import Foundation

public extension SSH {
    func getTemp() async -> [TemperatureStat]? {
        var files: [String] = []
        if let lines = await readLines(hostClass.appendingPathComponent("hwmon/hwmon*/temp*_input"), find: true) {
            files = lines
        }
        var ret: [TemperatureStat] = []
        if files.isEmpty {
            if let files = await readLines(hostClass.appendingPathComponent("thermal/thermal_zone*/temp"), find: true) {
                for file in files {
                    let directory = file.deletingLastPathComponent
                    guard let lines = await readLines(String(format: "%@ %@", file, directory.appendingPathComponent("type"))), lines.count == 2 else {
                        continue
                    }
                    let name = lines[1]
                    let temperature = lines[0]
                    var t = TemperatureStat()
                    t.name = name
                    t.temperature = (Double(temperature) ?? 0) / 1000
                    ret.append(t)
                }
            }
        } else {
            for file in files {
                let directory = file.deletingLastPathComponent
                let basename = file.lastPathComponent.components(separatedBy: "_")[0]
                guard let lines = await readLines(String(format: "%@ %@ %@", directory.appendingPathComponent("name"), file,directory.appendingPathComponent("\(basename)_crit"))) else {
                    continue
                }
                guard lines.count == 3 else {
                    continue
                }
                let name = lines[0].lowercased()
                let temperature = lines[1]
                let crit =   lines[2]
                let high =  await readFile(directory.appendingPathComponent("\(basename)_max"))?.lowercased() ?? ""
                let label = await readFile(directory.appendingPathComponent("\(basename)_label"))?.lowercased() ?? ""
                var t = TemperatureStat()
                t.name = name
                t.label = label
                t.temperature = (Double(temperature) ?? 0) / 1000
                t.sensorHigh = (Double(high) ?? 0) / 1000
                t.sensorCritical = (Double(crit) ?? 0) / 1000
                ret.append(t)
            }
        }
        return ret
    }
}
