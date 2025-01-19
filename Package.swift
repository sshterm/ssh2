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
            targets: ["SSH2"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/sshterm/cssh.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "SSH2",
            dependencies: [.product(name: "CSSH", package: "CSSH"),.product(name: "SSHKey", package: "CSSH")]
        )
    ]
)
