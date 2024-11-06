// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Swoirenberg",
    platforms: [ .macOS(.v10_15), .iOS(.v14) ],
    products: [
        .library(
            name: "Swoirenberg",
            targets: ["Swoirenberg", "SwoirenbergFramework"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Swoir/SwoirCore.git", exact: "0.5.0"),
    ],
    targets: [
        .target(
            name: "Swoirenberg",
            dependencies: ["SwoirCore", "SwoirenbergFramework"],
            path: "Swift/Sources/Swoirenberg",
            linkerSettings: [ .linkedFramework("SystemConfiguration") ]),
        .binaryTarget(
            name: "SwoirenbergFramework",
            url: "https://github.com/Swoir/Swoirenberg/releases/download/v0.36.0-2/Swoirenberg.xcframework.zip",
            checksum: "d6ad68a9bae337beea16c2e7727dab9e44c64c9b7e13d5d6a5eaface353365c3"),
        .testTarget(
            name: "SwoirenbergTests",
            dependencies: ["Swoirenberg"],
            path: "Swift/Tests/SwoirenbergTests"),
    ]
)
