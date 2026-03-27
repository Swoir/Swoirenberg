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
            url: "https://github.com/Swoir/Swoirenberg/releases/download/v1.0.0-beta.19-4/Swoirenberg.xcframework.zip",
            checksum: "a65d689bc20b3b97549f04dd6e3f4ec9f7e5b2b721d1cd6219c985e3d36b5573"),
        .testTarget(
            name: "SwoirenbergTests",
            dependencies: ["Swoirenberg"],
            path: "Swift/Tests/SwoirenbergTests"),
    ]
)
