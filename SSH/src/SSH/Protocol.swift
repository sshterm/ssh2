// Protocol.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2024/8/21.

import CSSH
import Foundation

/// A protocol that defines the delegate methods for handling SSH session events.
public protocol SessionDelegate {
    /// Called when the SSH session is disconnected.
    /// - Parameter ssh: The SSH session instance.
    func disconnect(ssh: SSH)

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

/// A typealias for a C function pointer that represents a send function used in the SSH protocol.
///
/// - Parameters:
///   - libssh2_socket_t: The socket to send data through.
///   - UnsafeRawPointer: A pointer to the data to be sent.
///   - size_t: The size of the data to be sent.
///   - CInt: Flags for the send operation.
///   - UnsafeRawPointer: A pointer to additional data required for the send operation.
///
/// - Returns: The number of bytes sent, or a negative value if an error occurred.
typealias sendType = @convention(c) (libssh2_socket_t, UnsafeRawPointer, size_t, CInt, UnsafeRawPointer) -> ssize_t
/// A typealias for a function pointer that represents a C function with the following signature:
///
/// - Parameters:
///   - libssh2_socket_t: A socket descriptor.
///   - UnsafeMutableRawPointer: A pointer to a buffer where the received data will be stored.
///   - size_t: The size of the buffer.
///   - CInt: Flags for the receive operation.
///   - UnsafeRawPointer: A pointer to user-defined data.
///
/// - Returns: The number of bytes received, or a negative value if an error occurred.
typealias recvType = @convention(c) (libssh2_socket_t, UnsafeMutableRawPointer, size_t, CInt, UnsafeRawPointer) -> ssize_t
/// A typealias for a C function pointer that represents a disconnect callback function.
///
/// - Parameters:
///   - arg1: An `UnsafeRawPointer` to the first argument.
///   - arg2: A `CInt` representing the second argument.
///   - arg3: An `UnsafePointer<CChar>` to the third argument.
///   - arg4: A `CInt` representing the fourth argument.
///   - arg5: An `UnsafePointer<CChar>` to the fifth argument.
///   - arg6: A `CInt` representing the sixth argument.
///   - arg7: An `UnsafeRawPointer` to the seventh argument.
typealias disconnectType = @convention(c) (UnsafeRawPointer, CInt, UnsafePointer<CChar>, CInt, UnsafePointer<CChar>, CInt, UnsafeRawPointer) -> Void
#if DEBUG
    /// A typealias for a C function pointer that represents a debug callback function.
    ///
    /// The function takes the following parameters:
    /// - `UnsafeRawPointer`: A raw pointer to user-defined data.
    /// - `CInt`: An integer representing the debug level.
    /// - `UnsafePointer<CChar>`: A pointer to a C string containing the file name where the debug message originated.
    /// - `CInt`: An integer representing the line number in the file.
    /// - `UnsafePointer<CChar>`: A pointer to a C string containing the function name where the debug message originated.
    /// - `CInt`: An integer representing the error code.
    /// - `UnsafeRawPointer`: A raw pointer to additional user-defined data.
    typealias debugType = @convention(c) (UnsafeRawPointer, CInt, UnsafePointer<CChar>, CInt, UnsafePointer<CChar>, CInt, UnsafeRawPointer) -> Void
#endif
/// A typealias for a generic callback function with no parameters and no return value.
/// The callback function is defined with the `@convention(c)` attribute, indicating that it uses the C calling convention.
typealias cbGenericType = @convention(c) () -> Void
