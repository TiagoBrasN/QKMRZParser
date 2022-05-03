// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QKMRZParser",
    products: [
        .library(name: "QKMRZParser", targets: ["QKMRZParser"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "QKMRZParser",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms")
            ],
            path: "QKMRZParser",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "QKMRZParserTests",
            dependencies: ["QKMRZParser"],
            path: "QKMRZParserTests"
        )
    ]
)
