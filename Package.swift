// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "GradientUI",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "GradientUI",
            targets: ["GradientUI"]),
    ],
    dependencies: [
        .package(url: "http://github.com/heestand-xyz/PixelColor", from: "3.1.0")
    ],
    targets: [
        .target(
            name: "GradientUI",
            dependencies: ["PixelColor"]),
    ]
)
