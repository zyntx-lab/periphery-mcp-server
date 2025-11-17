// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "periphery-mcp-server",
    platforms: [.macOS(.v13)],
    products: [
        .executable(
            name: "periphery-mcp-server",
            targets: ["PeripheryMCPServer"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/modelcontextprotocol/swift-sdk",
            from: "0.10.0"
        )
    ],
    targets: [
        .executableTarget(
            name: "PeripheryMCPServer",
            dependencies: [
                .product(name: "MCP", package: "swift-sdk")
            ]
        )
    ]
)
