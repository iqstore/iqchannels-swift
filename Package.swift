// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iqchannels-swift",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "iqchannels-swift",
            targets: ["iqchannels-swift"]),
    ],
    dependencies: [
        .package(name: "SDWebImageSwiftUI", url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "3.0.4"),
        .package(name: "SQLite.swift", url: "https://github.com/stephencelis/SQLite.swift.git", ">=0.13")
    ],
    targets: [
        .target(
            name: "iqchannels-swift"),
        .testTarget(
            name: "iqchannels-swiftTests",
            dependencies: ["iqchannels-swift"]
        ),
    ]
)
