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
        .package(url: "https://github.com/Swoir/SwoirCore.git", exact: "0.11.0"),
    ],
    targets: [
        .target(
            name: "Swoirenberg",
            dependencies: ["SwoirCore", "SwoirenbergFramework"],
            path: "Swift/Sources/Swoirenberg",
            linkerSettings: [ .linkedFramework("SystemConfiguration") ]),
        .binaryTarget(
            name: "SwoirenbergFramework",
            url: "https://github.com/Swoir/Swoirenberg/releases/download/v1.0.0-beta.22-4/Swoirenberg.xcframework.zip",
            checksum: "37adccf28da03f397965516e0b45dbbd48d980df32e7485d871a376f91a35ee0"),
        .testTarget(
            name: "SwoirenbergTests",
            dependencies: ["Swoirenberg"],
            path: "Swift/Tests/SwoirenbergTests"),
    ]
)
