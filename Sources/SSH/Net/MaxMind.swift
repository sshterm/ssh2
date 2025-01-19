// MaxMind.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import Foundation
import MaxMindDB

public class MaxMind {
    var raw: UnsafeMutablePointer<MMDB_s>?

    /// Initializes a new instance of the class with the specified file path.
    /// 
    /// - Parameter file: The path to the MaxMind database file as a `String`.
    /// - Note: The file path is converted to bytes and used to open the MaxMind database.
    public init(file: String) {
        raw = mmdb_open(file.bytes)
    }

    deinit {
        mmdb_close(raw)
        raw = nil
    }
}

public extension MaxMind {
    /// Looks up the ISO country code for a given IP address.
    /// 
    /// This function checks if the provided IP address is valid and not a local network IP.
    /// If the IP address is valid and not a LAN IP, it queries the MaxMind database for the
    /// corresponding ISO country code.
    ///
    /// - Parameter ip: The IP address to look up.
    /// - Returns: The ISO country code as a `String` if found, otherwise `nil`.
    func lookupIsoCode(_ ip: IP) -> String? {
        guard ip.isIP else {
            return nil
        }
        guard !ip.isLanIP else {
            return nil
        }
        guard let code = mmdb_lookup_iso_code(raw, ip.bytes) else {
            return nil
        }
        return code.string
    }

    /// A computed property that provides access to the metadata of the MaxMind database.
    /// 
    /// This property returns an `UnsafeMutablePointer` to an `MMDB_metadata_s` structure,
    /// which contains metadata information about the MaxMind database.
    /// 
    /// - Note: The pointer returned by this property is unsafe and mutable, so it should be
    ///         used with caution to avoid memory safety issues.
    var metadata: UnsafeMutablePointer<MMDB_metadata_s>? {
        mmdb_metadata(raw)
    }
}
