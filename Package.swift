// swift-tools-version: 5.9
// Modern Disk Inventory - Swift Package

import PackageDescription

let package = Package(
    name: "DiskInventory",
    platforms: [
        .macOS(.v14) // macOS Sonoma+
    ],
    products: [
        .executable(
            name: "DiskInventory",
            targets: ["DiskInventory"]
        ),
        .executable(
            name: "CLI",
            targets: ["CLI"]
        ),
        .executable(
            name: "Demo",
            targets: ["Demo"]
        ),
        .library(
            name: "DiskInventoryCore",
            targets: ["DiskInventoryCore"]
        )
    ],
    dependencies: [
        // Add dependencies here if needed
        // .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "DiskInventory",
            dependencies: ["DiskInventoryCore"]
        ),
        .executableTarget(
            name: "CLI",
            dependencies: ["DiskInventoryCore"],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        ),
        .executableTarget(
            name: "Demo",
            dependencies: ["DiskInventoryCore"]
        ),
        .target(
            name: "DiskInventoryCore",
            dependencies: []
        ),
        .testTarget(
            name: "DiskInventoryCoreTests",
            dependencies: ["DiskInventoryCore"]
        )
    ]
)

