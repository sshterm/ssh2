// Auth.swift
// Copyright (c) 2025 ssh2.app
// Created by admin@ssh2.app 2025/1/19.

import CSSH
import Extension
import Foundation

public extension SSH {
    /// Authenticates the user using the provided password.
    ///
    /// This function attempts to authenticate the user with the given password
    /// asynchronously. It first checks if the raw session is available and if
    /// the authentication method list contains "password". If the user is already
    /// authenticated, it returns `true`. Otherwise, it calls the `libssh2_userauth_password_ex`
    /// function to perform the password authentication.
    ///
    /// - Parameter password: The password to use for authentication.
    /// - Returns: A boolean value indicating whether the authentication was successful.
    /// - Note: This function uses the `libssh2_userauth_password_ex` function from the libssh2 library.
    func authenticate(password: String) async -> Bool {
        guard isPassword else {
            return false
        }
        if isAuthenticated {
            return true
        }
        return await call { [self] in
            guard let rawSession else {
                return false
            }
            guard callSSH2 { libssh2_userauth_password_ex(rawSession, user, user.count.load(), password, password.count.load(), nil) } == LIBSSH2_ERROR_NONE, isAuthenticated else {
                return false
            }
            return isAuthenticated
        }
    }

    /// Authenticates the user using a private key file.
    ///
    /// This function attempts to authenticate the user using the provided private key file and optional passphrase.
    /// It first checks if the SSH session is valid and if the "publickey" authentication method is available.
    /// If the user is already authenticated, it returns `true`. Otherwise, it attempts to authenticate using the
    /// `libssh2_userauth_publickey_fromfile_ex` function.
    ///
    /// - Parameters:
    ///   - privateKeyFile: The path to the private key file.
    ///   - passphrase: An optional passphrase for the private key file. Defaults to `nil`.
    ///   - publickeyFile: The path to the public key file. Defaults to an empty string.
    /// - Returns: A `Bool` indicating whether the authentication was successful.
    /// - Note: This function is asynchronous and should be called with `await`.
    func authenticate(privateKeyFile: String, passphrase: String? = nil, publickeyFile: String = "") async -> Bool {
        guard isPublickey else {
            return false
        }
        if isAuthenticated {
            return true
        }
        return await call { [self] in
            guard let rawSession else {
                return false
            }
            guard callSSH2 { libssh2_userauth_publickey_fromfile_ex(rawSession, user, user.count.load(), publickeyFile, privateKeyFile, passphrase) } == LIBSSH2_ERROR_NONE, isAuthenticated else {
                return false
            }
            return isAuthenticated
        }
    }

    /**
     Authenticates the user using a private key and an optional passphrase.

     - Parameters:
       - privateKey: The private key used for authentication.
       - passphrase: An optional passphrase for the private key. Defaults to `nil`.
       - publickey: The public key used for authentication. Defaults to an empty string.

     - Returns: A boolean value indicating whether the authentication was successful.

     This function checks if the session is valid and if the "publickey" authentication method is available.
     If the user is already authenticated, it returns `true`. Otherwise, it attempts to authenticate using
     the provided private key and passphrase.
     */
    func authenticate(privateKey: String, passphrase: String? = nil, publickey: String = "") async -> Bool {
        guard isPublickey else {
            return false
        }
        if isAuthenticated {
            return true
        }
        return await call { [self] in
            guard let rawSession else {
                return false
            }
            guard callSSH2 { libssh2_userauth_publickey_frommemory(rawSession, user, user.count, publickey, publickey.count, privateKey, privateKey.count, passphrase) } == LIBSSH2_ERROR_NONE, isAuthenticated else {
                return false
            }
            return isAuthenticated
        }
    }

    /// Authenticates the user to the specified hostname using a private key file and an optional passphrase.
    /// - Parameters:
    ///   - hostname: The hostname of the server to authenticate to.
    ///   - privateKeyFile: The path to the private key file used for authentication.
    ///   - passphrase: An optional passphrase for the private key file. Defaults to `nil`.
    ///   - publickeyFile: The path to the public key file used for authentication. Defaults to an empty string.
    /// - Returns: A boolean value indicating whether the authentication was successful.
//    func authenticate(hostname: String, privateKeyFile: String, passphrase: String? = nil, publickeyFile: String = "") async -> Bool {
//        guard isHostbased else {
//            return false
//        }
//        if isAuthenticated {
//            return true
//        }
//        return await call { [self] in
//            guard let rawSession else {
//                return false
//            }
//            guard callSSH2 { libssh2_userauth_hostbased_fromfile_ex(rawSession, user, user.count.load(), publickeyFile, privateKeyFile, passphrase, hostname, hostname.count.load(), user, user.count.load()) } == LIBSSH2_ERROR_NONE, isAuthenticated else {
//                return false
//            }
//            return isAuthenticated
//        }
//    }

    /// Authenticates the user using the specified authentication method.
    ///
    /// - Parameter none: A Boolean value indicating whether to skip the authentication process. Default is `false`.
    /// - Returns: A Boolean value indicating whether the authentication was successful.
    ///
    /// This function performs user authentication by first retrieving the list of available authentication methods.
    /// If the `none` parameter is set to `true`, it returns the current authentication status without performing any authentication.
    /// Otherwise, it checks if the "keyboard-interactive" authentication method is available. If not, it returns `false`.
    /// If the "keyboard-interactive" method is available, it proceeds to authenticate the user using the provided session delegate
    /// to handle the keyboard-interactive prompts.
    ///
    /// The function uses the `libssh2_userauth_keyboard_interactive_ex` function to perform the keyboard-interactive authentication.
    /// It iterates through the prompts, retrieves the challenge text, and uses the session delegate to obtain the user's response.
    /// The responses are then passed back to the authentication function.
    ///
    /// The function returns `true` if the authentication was successful, otherwise it returns `false`.
    func authenticate(_ none: Bool = false) async -> Bool {
        if none {
            guard isNone else {
                return false
            }

            return isAuthenticated
        }
        guard isKeyboard else {
            return false
        }
        if isAuthenticated {
            return true
        }
        return await call { [self] in
            guard let rawSession else {
                return false
            }
            let code = callSSH2 { libssh2_userauth_keyboard_interactive_ex(rawSession, user, user.count.load()) { _, _, _, _, numPrompts, prompts, responses, abstract in
                guard let ssh: SSH = abstract?.address.load() else {
                    return
                }
                for i in 0 ..< Int(numPrompts) {
                    guard let promptI = prompts?[i], let text = promptI.text else {
                        continue
                    }
                    guard let challenge = Data(bytes: text, count: promptI.length).string else {
                        continue
                    }

                    let password = ssh.sessionDelegate?.keyboardInteractive(ssh: ssh, prompt: challenge) ?? ""
                    let response = LIBSSH2_USERAUTH_KBDINT_RESPONSE(text: password.bytes, length: password.count.load())
                    responses?[i] = response
                }
            }}
            guard code == LIBSSH2_ERROR_NONE else {
                return false
            }
            return isAuthenticated
        }
    }

    /// A computed property that checks if the user authentication method contains "none".
    ///
    /// This property returns `true` if the `userauth` string contains the substring "none",
    /// indicating that no authentication method is being used. Otherwise, it returns `false`.
    ///
    /// - Returns: A Boolean value indicating whether the user authentication method is "none".
    var isNone: Bool {
        userauth.contains(.none)
    }

    /// A computed property that checks if the user authentication method contains "password".
    ///
    /// - Returns: A Boolean value indicating whether the user authentication method includes "password".
    var isPassword: Bool {
        userauth.contains(.password)
    }

    /// A computed property that checks if the user authentication method includes "publickey".
    ///
    /// This property returns `true` if the `userauth` string contains the substring "publickey",
    /// indicating that public key authentication is being used. Otherwise, it returns `false`.
    ///
    /// - Returns: A Boolean value indicating whether public key authentication is used.
    var isPublickey: Bool {
        userauth.contains(.publickey)
    }

    /// A computed property that checks if the user authentication method includes "hostbased".
    ///
    /// This property returns `true` if the `userauth` string contains the substring "hostbased",
    /// indicating that host-based authentication is being used. Otherwise, it returns `false`.
    ///
    /// - Returns: A Boolean value indicating whether host-based authentication is used.
//    var isHostbased: Bool {
//        userauth.contains(.hostbased)
//    }

    /// A computed property that checks if the user authentication method contains "keyboard-interactive".
    ///
    /// - Returns: A Boolean value indicating whether the user authentication method includes "keyboard-interactive".
    var isKeyboard: Bool {
        userauth.contains(.keyboard)
    }

    /// A computed property that returns a list of user authentication methods available for the current session.
    /// - Returns: An array of strings representing the available user authentication methods. If the session is not available or the authentication list cannot be retrieved, an empty array is returned.
    var userauth: [AuthType] {
        guard let rawSession else {
            return []
        }
        let ptr = callSSH2 { [self] in
            libssh2_userauth_list(rawSession, user, user.count.load())
        }
        guard let ptr else {
            return []
        }
        var auth: [AuthType] = []
        for a in ptr.string.components(separatedBy: ",") {
            switch a {
            case "none":
                auth.append(.none)
            case "password":
                auth.append(.password)
            case "publickey":
                auth.append(.publickey)
            case "keyboard-interactive":
                auth.append(.keyboard)
//            case "hostbased":
//                auth.append(.hostbased)
            default:
                continue
            }
        }
        return auth
    }

    /// A computed property that checks if the user is authenticated.
    ///
    /// This property uses the `libssh2_userauth_authenticated` function to determine
    /// if the current session (`rawSession`) is authenticated. If `rawSession` is `nil`,
    /// the property returns `false`.
    ///
    /// - Returns: `true` if the user is authenticated, `false` otherwise.
    var isAuthenticated: Bool {
        guard let rawSession else {
            return false
        }
        return libssh2_userauth_authenticated(rawSession) == 1
    }
}
