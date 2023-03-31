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
        .package(url: "https://github.com/kean/Nuke", .upToNextMajor(from: "11.0.0")),
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "3.4.0"),
        .package(url: "https://github.com/vi66r/Shuttle", branch: "main")
    ],
    targets: [
        .target(name: "SnowPack", dependencies: ["Shuttle", "TinyConstraints", "Nuke", .product(name: "NukeExtensions", package: "Nuke"), "PhoneNumberKit"]),
        .testTarget(name: "SnowPackTests", dependencies: ["SnowPack"])
    ]
)
