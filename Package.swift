// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "ClipStack",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ClipStack", targets: ["ClipStack"])
    ],
    targets: [
        .executableTarget(
            name: "ClipStack",
            path: "Sources"
        ),
        .testTarget(
            name: "ClipStackTests",
            dependencies: ["ClipStack"],
            path: "Tests"
        )
    ]
)
