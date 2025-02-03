// LinuxStats.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/2/2.

import CSSH
import Darwin
import Extension
import Foundation

public extension SSH {
    func pathExistsWithContents(_ filename: String) async -> Bool {
        guard let fileinfo = await pathStat(filename) else {
            return false
        }
        return fileinfo.st_size > 4 && Int32(fileinfo.st_mode) & LIBSSH2_SFTP_S_IFMT != LIBSSH2_SFTP_S_IFDIR
    }

    func pathExists(_ filename: String) async -> Bool {
        return await pathStat(filename) != nil
    }

    func pathStat(_ filename: String) async -> stat? {
        guard rawSession != nil else {
            return nil
        }
        var fileinfo = libssh2_struct_stat()
        let handle = callSSH2 { [self] in
            libssh2_scp_recv2(rawSession, filename, &fileinfo)
        }
        guard handle != nil else {
            return nil
        }
        libssh2_channel_free(handle)

        return fileinfo
    }

    func readLines(_ filename: String, find: Bool = false) async -> [String]? {
        guard let data: Data? = await exec("\(find ? "find" : "cat") \(filename)") else {
            return nil
        }
        guard let text = data?.string?.trim,!text.isEmpty else {
            return nil
        }
        return text.lines
    }

    func readFile(_ filename: String) async -> String? {
        guard let data: Data? = await exec("cat \(filename)") else {
            return nil
        }
        guard let text = data?.string?.trim,!text.isEmpty else {
            return nil
        }
        return text
    }

    var hostEtc: String {
        return "/etc"
    }

    var hostProc: String {
        return "/proc"
    }

    var hostSys: String {
        return "/sys"
    }

    var hostClass: String {
        return hostSys.appendingPathComponent("class")
    }
}
