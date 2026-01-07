// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreAuth",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "CoreAuth",
            targets: ["CoreAuth"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CoreAuth",
            dependencies: []),
        .testTarget(
            name: "CoreAuthTests",
            dependencies: ["CoreAuth"]),
    ]
)

