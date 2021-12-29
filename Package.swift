// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "MicroColorQuantizer",
    products: [
        .library(
            name: "MicroColorQuantizer",
            targets: ["MicroColorQuantizer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/rbruinier/SwiftMicroPNG.git", from: "0.0.1")
    ],
    targets: [
        .target(
            name: "MicroColorQuantizer",
            dependencies: []),
        .testTarget(
            name: "MicroColorQuantizerTests",
            dependencies: ["MicroColorQuantizer", .product(name: "MicroPNG", package: "SwiftMicroPNG")],
            resources: [
                .copy("Data"),
            ])
    ]
)
