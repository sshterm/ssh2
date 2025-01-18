// swift-tools-version:5.10

import PackageDescription


let package = Package(
    name: "SSH",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    dependencies: [
        .package(url: "https://github.com/sshterm/cssh.git", branch: "main"),
    ],
    products: [
        .library(
            name: "SSH",
            targets: ["SSH"]
        ),
    ],
    targets: [
        .target(
            name: "SSH",
            dependencies: [.product(name: "CSSH", package: "CSSH"),.product(name: "SSHKey", package: "CSSH")],
            path: "SSH/src"
        )
    ],
    swiftLanguageVersions: [.v5]
)
