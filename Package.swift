// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SnowPack",
    platforms: [
      .iOS(.v15)
    ],
    products: [
        .library(name: "SnowPack", targets: ["SnowPack"])
    ],
    dependencies: [
        .package(url: "https://github.com/roberthein/TinyConstraints.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/kean/Nuke", .upToNextMajor(from: "9.0.0")),
    ],
    targets: [
        .target(name: "SnowPack", dependencies: ["TinyConstraints"]),
        .testTarget(name: "SnowPackTests", dependencies: ["SnowPack"])
    ]
)
