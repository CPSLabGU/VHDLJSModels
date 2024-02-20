// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// Package definition.
let package = Package(
    name: "VHDLMachineTransformations",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other
        // packages.
        .library(
            name: "VHDLMachineTransformations",
            targets: ["VHDLMachineTransformations"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "VHDLMachineTransformations"
        ),
        .testTarget(
            name: "VHDLMachineTransformationsTests",
            dependencies: ["VHDLMachineTransformations"]
        )
    ]
)
