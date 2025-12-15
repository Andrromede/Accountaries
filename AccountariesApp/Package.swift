// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AccountariesApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "AccountariesApp",
            targets: ["AccountariesApp"]
        )
    ],
    targets: [
        .executableTarget(
            name: "AccountariesApp",
            path: "Sources"
        )
    ]
)
