// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MeshKit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .macCatalyst(.v13),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "MeshKit",
            targets: ["MeshKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/EthanLipnik/MeshGradient.git", from: "1.0.2"),
        .package(url: "https://github.com/EthanLipnik/RandomColorSwift.git", from: "2.0.1")
    ],
    targets: [
        .target(
            name: "MeshKit",
            dependencies: [
                .product(name: "MeshGradient", package: "meshgradient"),
                .product(name: "RandomColor", package: "randomcolorswift")
            ]),
        .testTarget(
            name: "MeshKitTests",
            dependencies: ["MeshKit"]),
    ]
)
