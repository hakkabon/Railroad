// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Railroad",
    platforms: [
        .macOS(.v11),
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "Railroad",
            targets: ["Railroad"]
        ),
        .executable(
            name: "RailroadDemo",
            targets: ["RailroadDemo"]
        ),
    ],
    targets: [
        .target(
            name: "Railroad",
            dependencies: []
        ),
        .executableTarget(
            name: "RailroadDemo",
            dependencies: ["Railroad"],
            path: "Sources/RailroadDemo"
        ),
        .testTarget(
            name: "RailroadTests",
            dependencies: ["Railroad"]
        ),
    ]
)
