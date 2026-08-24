// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "R2ArtFractionPriceInput",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        // Umbrella library exporting all modules
        .library(
            name: "R2ArtFractionPriceInput",
            targets: ["FractionPriceCore", "FractionPriceSwiftUI", "FractionPriceUIKit"]
        ),
        // Pure Swift Business Logic Engine
        .library(
            name: "FractionPriceCore",
            targets: ["FractionPriceCore"]
        ),
        // Declarative SwiftUI Components
        .library(
            name: "FractionPriceSwiftUI",
            targets: ["FractionPriceSwiftUI"]
        ),
        // Classic UIKit Custom Views
        .library(
            name: "FractionPriceUIKit",
            targets: ["FractionPriceUIKit"]
        )
    ],
    dependencies: [],
    targets: [
        // 1. Pure Swift Engine
        .target(
            name: "FractionPriceCore",
            dependencies: [],
            path: "Sources/FractionPriceCore"
        ),
        // 2. SwiftUI UI Module
        .target(
            name: "FractionPriceSwiftUI",
            dependencies: ["FractionPriceCore"],
            path: "Sources/FractionPriceSwiftUI"
        ),
        // 3. UIKit UI Module
        .target(
            name: "FractionPriceUIKit",
            dependencies: ["FractionPriceCore"],
            path: "Sources/FractionPriceUIKit"
        ),
        // 4. Core Unit Tests
        .testTarget(
            name: "FractionPriceCoreTests",
            dependencies: ["FractionPriceCore"],
            path: "Tests/FractionPriceCoreTests"
        )
    ]
)
