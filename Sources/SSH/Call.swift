// Call.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import CSSH
import Foundation

extension SSH {
    /// Executes a given callback function asynchronously, ensuring thread safety by locking and unlocking a mutex around the callback execution.
    ///
    /// - Parameter callback: A closure that returns a value of type `T`.
    /// - Returns: The result of the callback function of type `T`.
    /// - Note: This function uses `withUnsafeContinuation` to bridge the synchronous callback execution with the asynchronous context.
    func call<T>(_ callback: @escaping () -> T) async -> T {
        await withUnsafeContinuation { continuation in
            let ret = waitGroup.with {
                callback()
            }
            continuation.resume(returning: ret)
        }
    }

    func call<T>(_ callback: @escaping () -> T) -> T {
        waitGroup.with {
            callback()
        }
    }

    /// Calls an SSH2 function and handles the `LIBSSH2_ERROR_EAGAIN` error by waiting for the socket to be ready.
    ///
    /// - Parameters:
    ///   - wait: A Boolean value indicating whether to wait for the socket to be ready if the `LIBSSH2_ERROR_EAGAIN` error occurs. Default is `true`.
    ///   - callback: A closure that performs the SSH2 function call and returns a value of type `T`.
    ///
    /// - Returns: The result of the SSH2 function call, which is of type `T`.
    ///
    /// - Note: The type `T` must conform to `FixedWidthInteger`.
    ///
    /// - Important: This function locks the SSH2 resource before executing the callback and unlocks it after the callback completes.
    func callSSH2<T>(_ wait: Bool = true, _ callback: @escaping () -> T) -> T where T: FixedWidthInteger {
        waitGroup.with {
            lock.withLock { var ret: T
                repeat {
                    guard !isFree else {
                        ret = T(LIBSSH2_ERROR_ALLOC)
                        break
                    }
                    ret = callback()
                    guard wait, ret == T(LIBSSH2_ERROR_EAGAIN) else { break }
                    guard waitsocket() > 0 else { break }
                } while true
                return ret
            }
        }
    }

    /// Executes a callback function within a locked SSH session, handling potential EAGAIN errors.
    ///
    /// - Parameters:
    ///   - wait: A Boolean value indicating whether to wait for the session to be ready. Defaults to `true`.
    ///   - callback: A closure that returns a value of type `T`.
    /// - Returns: The result of the callback function.
    ///
    /// This function locks the SSH session before executing the callback and unlocks it afterward.
    /// If `wait` is `true`, it will handle `LIBSSH2_ERROR_EAGAIN` errors by waiting for the session to be ready.
    /// The function will repeat the callback execution until it succeeds or an error other than `E
    func callSSH2<T>(_ wait: Bool = true, _ callback: @escaping () -> T) -> T {
        waitGroup.with {
            lock.withLock { var ret: T
                repeat {
                    ret = callback()
                    guard wait, rawSession != nil, libssh2_session_last_errno(rawSession) == LIBSSH2_ERROR_EAGAIN else { break }
                    guard waitsocket() > 0 else { break }
                } while true
                return ret
            }
        }
    }

    /// Adds a new operation to the job queue.
    ///
    /// - Parameter callback: A closure that will be executed when the operation is performed.
    func addOperation(_ callback: @escaping () -> Void) {
        let operation = BlockOperation {
            callback()
        }
        job.addOperation(operation)
    }

    /// Adds an asynchronous operation to be executed.
    ///
    /// - Parameter callback: A closure that contains the asynchronous code to be executed.
//    func addOperation(_ callback: @escaping () async -> Void) {
//        let operation = BlockOperation {
//            async {
//                await callback()
//            }
//        }
//        job.addOperation(operation)
//    }

    /// Traces a message by converting it from a C-style string to a Swift string and passing it to the session delegate.
    /// - Parameters:
    ///   - message: A pointer to the C-style string message to be traced.
    ///   - messageLen: The length of the message in bytes.
    func trace(message: UnsafePointer<CChar>, messageLen: Int) {
        guard SSH.traceFD != -1 else {
            return
        }
        addOperation {
            Darwin.write(SSH.traceFD, message, messageLen)
        }
    }

    /**
     This function is a debug callback for an SSH session. It converts the provided message into a UTF-8 encoded string and passes it to the session delegate's debug method.

     - Parameters:
        - sess: An unused parameter representing the SSH session.
        - reason: An unused parameter representing the reason for the debug message.
        - message: A pointer to the debug message.
        - messageLen: The length of the debug message.
        - language: An unused parameter representing the language of the debug message.
        - languageLen: An unused parameter representing the length of the language string.
     */
    func debug(sess _: UnsafeRawPointer, reason _: CInt, message: UnsafePointer<CChar>, messageLen: CInt, language _: UnsafePointer<CChar>, languageLen _: CInt) {
        guard SSH.traceFD != -1 else {
            return
        }
        addOperation {
            Darwin.write(SSH.traceFD, message, Int(messageLen))
        }
    }

    /**
     Disconnects the SSH session.

     - Parameters:
       - sess: An unsafe raw pointer to the session.
       - reason: The reason code for the disconnection.
       - message: A pointer to the message describing the reason for disconnection.
       - messageLen: The length of the message.
       - language: A pointer to the language of the message.
       - languageLen: The length of the language string.
     */
    func disconnect(sess _: UnsafeRawPointer, reason _: CInt, message _: UnsafePointer<CChar>, messageLen _: CInt, language _: UnsafePointer<CChar>, languageLen _: CInt) {
        sessionDelegate?.disconnect()
        free()
    }

    /// Handles incoming data from the SSH channel.
    /// - Parameters:
    ///   - data: The data received from the SSH channel.
    ///   - stdout: A boolean indicating whether the data is from the standard output (true) or standard error (false).
    /// - Note: If the data is not empty, it adds an operation to handle the data by calling the appropriate delegate method (`stdout` or `dtderr`).
    func onData(_ data: Data, _ stdout: Bool) {
        guard data.count > 0 else {
            return
        }
        addOperation { [self] in
            stdout ? channelDelegate?.stdout(ssh: self, data: data) : channelDelegate?.dtderr(ssh: self, data: data)
        }
    }
}
