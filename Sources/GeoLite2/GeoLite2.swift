// GeoLite2.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import Foundation

public class GeoLite2 {
    /// The file path to the GeoLite2 Country database.
    ///
    /// This property retrieves the path to the "GeoLite2-Country.mmdb" file
    /// from the module's bundle. The file is expected to be included in the
    /// module's resources.
    ///
    /// - Note: The path is force unwrapped, so ensure that the file exists
    ///         in the bundle to avoid runtime crashes.
    public static let country: String = Bundle.module.path(forResource: "GeoLite2-Country", ofType: "mmdb")!
}
