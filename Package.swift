// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "Stagger",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
    .tvOS(.v17),
  ],
  products: [
    .library(
      name: "Stagger",
      targets: ["Stagger"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0")
  ],
  targets: [
    .target(name: "Stagger"),
    .testTarget(
      name: "StaggerTests",
      dependencies: ["Stagger"]
    ),
  ]
)
