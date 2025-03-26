// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Stagger",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "Stagger",
            targets: ["Stagger"]
        )
    ],
    targets: [
        .target(name: "Stagger"),
        .testTarget(
            name: "StaggerTests",
            dependencies: ["Stagger"]
        )
    ]
)
