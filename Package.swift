// swift-tools-version:5.10

import PackageDescription


let package = Package(
    name: "SSH",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
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
            dependencies: ["CSSH", "SSHKey"],
            path: "SSH/src",
            linkerSettings: [
                .linkedLibrary("z"),
            ]
        ),
        .target(
            name: "SSHKey",
            dependencies: ["CSSH"],
            path: "SSHKey/src"
        ),
        .binaryTarget(
            name: "CSSH",
            path: "xcframework/CSSH.xcframework"
        )
    ],
    swiftLanguageVersions: [.v5]
)
