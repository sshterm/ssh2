# ssh2
Swift + libssh2 + OpenSSL


# Swift Package Manager

The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the swift compiler. Once you have your Swift package set up, adding SSH as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```swift
.package(url: "https://github.com/sshterm/ssh2.git", branch: "main")
```

```swift
[.product(name: "SSH2", package: "SSH2")]
```

# Demo
```swift
import SSH

DNS.shared.requireEncrypted(PubDNS.alidns.dohConfiguration)
print(SSH.version,SSH.libssh2_version)
let ssh = SSH(host: "openwrt.local", port: "22", user: "root")
ssh.trace = [.auth]
print(await ssh.checkActive())
print(await ssh.connect())
print(await ssh.handshake())
print(await ssh.authenticate(password: "openwrt"))
print(ssh.clientbanner)
print(ssh.serverbanner)
print(ssh.fingerprint(.md5))
```