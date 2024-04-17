// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// Package definition.
let package = Package(
    name: "VHDLJSModels",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other
        // packages.
        .library(
            name: "VHDLJSModels",
            targets: ["VHDLMachineTransformations", "JavascriptModel"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
        .package(url: "https://github.com/mipalgu/VHDLMachines", from: "4.0.1"),
        .package(url: "https://github.com/mipalgu/VHDLParsing", from: "2.4.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "JavascriptModel"
        ),
        .target(
            name: "VHDLMachineTransformations",
            dependencies: [
                .target(name: "JavascriptModel"),
                .product(name: "VHDLMachines", package: "VHDLMachines"),
                .product(name: "VHDLParsing", package: "VHDLParsing")
            ]
        ),
        .testTarget(name: "JavascriptModelTests", dependencies: ["JavascriptModel"]),
        .testTarget(
            name: "TestHelpers",
            dependencies: ["VHDLMachineTransformations", "VHDLParsing", "VHDLMachines", "JavascriptModel"]
        ),
        .testTarget(
            name: "VHDLMachineTransformationsTests",
            dependencies: [
                "VHDLMachineTransformations", "VHDLParsing", "VHDLMachines", "JavascriptModel", "TestHelpers"
            ]
        )
    ]
)
