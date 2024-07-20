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
        .package(url: "https://github.com/madztheo/SwoirCore.git", exact: "0.4.0"),
    ],
    targets: [
        .target(
            name: "Swoirenberg",
            dependencies: ["SwoirCore", "SwoirenbergFramework"],
            path: "Swift/Sources/Swoirenberg",
            linkerSettings: [ .linkedFramework("SystemConfiguration") ]),
        .binaryTarget(
            name: "SwoirenbergFramework",
            url: "https://github.com/madztheo/Swoirenberg/releases/download/v0.30.0-8/Swoirenberg.xcframework.zip",
            checksum: "c65725a7c7c3d585626f3a98af91af12423bd69c26082192936ed96273513e10"),
        .testTarget(
            name: "SwoirenbergTests",
            dependencies: ["Swoirenberg"],
            path: "Swift/Tests/SwoirenbergTests"),
    ]
)
