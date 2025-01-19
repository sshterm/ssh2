// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "SSH2",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "SSH2",
            targets: ["SSH"]
        ),
    ],
    dependencies: [
        .package(name: "CSSH", path: "~/project/github/cssh"),
        // .package(url: "https://github.com/sshterm/cssh.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "SSH",
            dependencies: [.product(name: "CSSH", package: "CSSH"), .product(name: "SSHKey", package: "CSSH"), .product(name: "OpenSSL", package: "CSSH")]
        ),
    ]
)
