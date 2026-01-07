// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConfigKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "ConfigKit",
            targets: ["ConfigKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", "10.18.0"..<"13.0.0")
    ],
    targets: [
        .target(
            name: "ConfigKit",
            dependencies: [
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk")
            ]),
        .testTarget(
            name: "ConfigKitTests",
            dependencies: ["ConfigKit"]),
    ]
)

