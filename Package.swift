// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StatefulVC",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "StatefulVC",
            targets: ["StatefulVC"]),
    ],
    targets: [
        .target(
            name: "StatefulVC",
            dependencies: []),
        .testTarget(
            name: "StatefulVCTests",
            dependencies: ["StatefulVC"]),
    ]
)
