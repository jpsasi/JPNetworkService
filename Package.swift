// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JPNetworkService",
    platforms: [
        .macOS(.v11),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "JPNetworkService",
            targets: ["JPNetworkService"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "JPNetworkService",
            path: "Sources/JPNetworkService"),
        .testTarget(
            name: "JPNetworkServiceTests",
            dependencies: ["JPNetworkService"]),
    ],
    swiftLanguageVersions: [.v5]
)
