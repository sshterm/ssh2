// Protocol.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import Foundation

/// A protocol that defines the delegate methods for handling SSH session events.
public protocol SessionDelegate {
    /// Disconnects the SSH session with an optional message.
    /// - Parameters:
    ///   - ssh: The SSH session to be disconnected.
    ///   - message: An optional data message to be sent before disconnecting.
    func disconnect(ssh: SSH, message: Data)

    /// Called when the SSH session is connected.
    /// - Parameters:
    ///   - ssh: The SSH session instance.
    ///   - fingerprint: The fingerprint of the SSH server.
    /// - Returns: A Boolean value indicating whether the connection is successful.
    func connect(ssh: SSH, fingerprint: String) -> Bool

    /// Called when a keyboard-interactive authentication prompt is received.
    /// - Parameters:
    ///   - ssh: The SSH session instance.
    ///   - prompt: The authentication prompt message.
    /// - Returns: The response to the authentication prompt.
    func keyboardInteractive(ssh: SSH, prompt: String) -> String

    /// Called to send data over the SSH session.
    /// - Parameters:
    ///   - ssh: The SSH session instance.
    ///   - size: The size of the data to be sent.
    func send(ssh: SSH, size: Int) async

    /// Called to receive data over the SSH session.
    /// - Parameters:
    ///   - ssh: The SSH session instance.
    ///   - size: The size of the data to be received.
    func recv(ssh: SSH, size: Int) async

    /// Called to log debug messages.
    /// - Parameters:
    ///   - ssh: The SSH session instance.
    ///   - message: The debug message.
    func debug(ssh: SSH, message: String) async

    /// Called to trace SSH session events.
    /// - Parameters:
    ///   - ssh: The SSH session instance.
    ///   - message: The trace message.
    func trace(ssh: SSH, message: String) async
}

/// A protocol that defines the delegate methods for handling SSH channel events.
public protocol ChannelDelegate {
    /// Called when there is data available on the standard output stream.
    ///
    /// - Parameters:
    ///   - ssh: The SSH instance associated with the event.
    ///   - data: The data received on the standard output stream.
    func stdout(ssh: SSH, data: Data) async

    /// Called when there is data available on the standard error stream.
    ///
    /// - Parameters:
    ///   - ssh: The SSH instance associated with the event.
    ///   - data: The data received on the standard error stream.
    func dtderr(ssh: SSH, data: Data) async

    /// Called when the SSH connection is disconnected.
    ///
    /// - Parameter ssh: The SSH instance associated with the event.
    func disconnect(ssh: SSH)

    /// Called when the SSH connection is established or changes its online status.
    ///
    /// - Parameters:
    ///   - ssh: The SSH instance associated with the event.
    ///   - online: A boolean indicating whether the connection is online.
    func connect(ssh: SSH, online: Bool)
}
