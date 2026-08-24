// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "R2ArtFractionPriceInput",
    defaultLocalization: "id",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "FractionPriceCore",
            targets: ["FractionPriceCore"]
        ),
        .library(
            name: "FractionPriceSwiftUI",
            targets: ["FractionPriceSwiftUI"]
        ),
        .library(
            name: "FractionPriceUIKit",
            targets: ["FractionPriceUIKit"]
        ),
    ],
    dependencies: [
        // No external dependencies - pure Swift implementation
    ],
    targets: [
        .target(
            name: "FractionPriceCore",
            dependencies: [],
            path: "Sources/FractionPriceCore"
        ),
        .target(
            name: "FractionPriceSwiftUI",
            dependencies: ["FractionPriceCore"],
            path: "Sources/FractionPriceSwiftUI"
        ),
        .target(
            name: "FractionPriceUIKit",
            dependencies: ["FractionPriceCore"],
            path: "Sources/FractionPriceUIKit"
        ),
        .testTarget(
            name: "FractionPriceCoreTests",
            dependencies: ["FractionPriceCore"],
            path: "Tests/FractionPriceCoreTests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
