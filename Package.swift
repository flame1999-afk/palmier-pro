// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PalmierPro",
    platforms: [.windows(.v10)], // Target Windows (Windows 10+). Intended runtime: Windows 11
    products: [
        .executable(name: "PalmierPro", targets: ["PalmierPro"]),
    ],
    dependencies: [
        // Minimal, cross-platform-first dependencies for Windows porting iteration.
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", from: "0.11.0"),
        .package(url: "https://github.com/get-convex/convex-swift", from: "0.8.0"),
        .package(url: "https://github.com/huggingface/swift-transformers", from: "1.3.3"),
    ],
    targets: [
        .executableTarget(
            name: "PalmierPro",
            dependencies: [
                .product(name: "MCP", package: "swift-sdk"),
                .product(name: "ConvexMobile", package: "convex-swift"),
                .product(name: "Tokenizers", package: "swift-transformers"),
            ],
            path: "Sources/PalmierPro",
            exclude: [
                "Resources/Info.plist",
                "Resources/AppIcon.icon",
                "Resources/AppIcon.icns",
                "Resources/AppIcon.png",
            ],
            resources: [
                .copy("Resources/Fonts"),
                .copy("Resources/MCPB/palmier-pro.mcpb"),
                .copy("Resources/Images"),
                .copy("Resources/Changelog"),
            ]
        ),
        .testTarget(
            name: "PalmierProTests",
            dependencies: ["PalmierPro"],
            path: "Tests/PalmierProTests"
        ),
    ]
)
