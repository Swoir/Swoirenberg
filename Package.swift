// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Swoirenberg",
    platforms: [ .macOS(.v13), .iOS(.v15) ],
    products: [
        .library(
            name: "Swoirenberg",
            targets: ["Swoirenberg", "SwoirenbergFramework"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Swoir/SwoirCore.git", exact: "0.9.0"),
    ],
    targets: [
        .target(
            name: "Swoirenberg",
            dependencies: ["SwoirCore", "SwoirenbergFramework"],
            path: "Swift/Sources/Swoirenberg",
            linkerSettings: [ .linkedFramework("SystemConfiguration") ]),
        .binaryTarget(
            name: "SwoirenbergFramework",
            url: "https://github.com/Swoir/Swoirenberg/releases/download/v1.0.0-beta.7-2/Swoirenberg.xcframework.zip",
            checksum: "5a3a048e8b97d16ba169e6d4cc07b8087928cf9a1f7741d9ec76e9e7238379df"),
        .testTarget(
            name: "SwoirenbergTests",
            dependencies: ["Swoirenberg"],
            path: "Swift/Tests/SwoirenbergTests"),
    ]
)
