// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "iqchannels-swift",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "IQChannelsSwift",
            targets: ["IQChannelsSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "3.0.4"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.13.0")
    ],
    targets: [
        .target(
            name: "IQChannelsSwift",
            dependencies: [
                .product(name: "SDWebImageSwiftUI", package: "SDWebImageSwiftUI"),
                .product(name: "SQLite", package: "SQLite.swift"),
            ],
            path: "IQChannelsSwift",
            exclude: [
                "Managers/TRVSEventSource.m",
                "Managers/TRVSServerSentEvent.m"
            ],
            sources: [
                "Assets",
                "Controllers",
                "Database",
                "Extensions",
                "IQLibraryConfiguration.swift",
                "Managers",
                "Models",
                "Protocols",
                "ViewModels",
                "Views",
            ],
            publicHeadersPath: "Managers",
            cSettings: [
                .headerSearchPath("Managers")
            ],
            resources: [
                .process("Assets/Assets.xcassets")
            ]
        ),
        .testTarget(
            name: "IQChannelsSwiftTests",
            dependencies: ["IQChannelsSwift"],
            path: "Example/Tests"
        ),
    ]
)
