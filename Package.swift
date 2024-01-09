// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Swoirenberg",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "Swoirenberg",
            targets: ["Swoirenberg"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Swoir/SwoirCore.git", exact: "0.1.0"),
    ],
    targets: [
        .target(
            name: "Swoirenberg",
            dependencies: ["SwiftBridge", "SwoirCore"],
            path: "Swift/Sources/Swoirenberg"),
        .target(
            name: "SwiftBridge",
            dependencies: ["CBridge"],
            path: "Swift/Sources/Bridge/SwiftBridge"),
        .target(
            name: "CBridge",
            dependencies: ["SwoirenbergFramework"],
            path: "Swift/Sources/Bridge/CBridge",
            linkerSettings: [ .linkedFramework("SystemConfiguration") ]),
        .binaryTarget(
            name: "SwoirenbergFramework",
            url: "https://github.com/Swoir/Swoirenberg/releases/download/v0.19.4-1/Swoirenberg.xcframework.zip",
            checksum: "124e43aae00f2d4aa71ac9419575e2ebd035133009026177d749a6dd2e67012f"),
        .testTarget(
            name: "SwoirenbergTests",
            dependencies: ["Swoirenberg"]),
    ]
)
