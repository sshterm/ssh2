# ssh2
Swift + libssh2 + OpenSSL


# Swift Package Manager

The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the swift compiler. Once you have your Swift package set up, adding SSH as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```swift
 .package(url: "https://github.com/sshterm/ssh2.git", branch: "main")
```

```swift
.product(name: "SSH", package: "ssh2")
```