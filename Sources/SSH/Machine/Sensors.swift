// Sensors.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/2/2.

import Foundation

public extension SSH {
    func getTemp() async -> [Double]? {
        guard let lines = await readLines(hostClass.appendingPathComponent("hwmon/hwmon[0-9]/temp1_input")) else {
            return nil
        }
        return lines.map { Double($0) ?? 0 }.filter { $0 > 0 }.map { $0 / 1000 }
    }

    func getTempMax() async -> Double? {
        return await getTemp()?.max()
    }
}
