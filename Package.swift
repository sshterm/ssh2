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
        .library(
            name: "DNS",
            targets: ["DNS"]
        ),
        .library(
            name: "GeoLite2",
            targets: ["GeoLite2"]
        ),
    ],
    dependencies: [
        // .package(name: "CSSH", path: "~/project/github/cssh"),
        .package(url: "https://github.com/sshterm/cssh.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "SSH",
            dependencies: [.product(name: "CSSH", package: "CSSH"), "Crypto"]
        ),
        .target(
            name: "Crypto",
            dependencies: [
                .product(name: "OpenSSL", package: "CSSH"),
                .product(name: "SSHKey", package: "CSSH"),
                "Extension"
            ],
            swiftSettings: [.define("HAVE_OPENSSL")]
        ),
        .target(
            name: "Extension"
        ),
        .target(
            name: "DNS",
            dependencies: ["Extension"]
        ),
        .target(
            name: "GeoLite2",
            dependencies: [.product(name: "MaxMindDB", package: "CSSH"), "Extension"],
            resources: [
                .process("Resources"),
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
