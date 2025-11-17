import Foundation
import MCP

/// Tool for checking if Periphery is installed and accessible
struct CheckPeripheryInstalledTool {
    static let name = "check_periphery_installed"
    static let description = "Verify Periphery CLI is installed and accessible"

    static let schema: Tool = Tool(
        name: name,
        description: description,
        inputSchema: .object([
            "type": .string("object")
        ])
    )

    static func execute(arguments: [String: Any]) async -> String {
        let isInstalled = PeripheryRunner.isPeripheryInstalled()
        let path = PeripheryRunner.findPeripheryPath()

        let response = InstallationCheckResponse(
            installed: isInstalled,
            path: path,
            message: isInstalled
                ? "Periphery is installed and ready"
                : "Periphery is not installed. Install it using: brew install peripheryapp/periphery/periphery"
        )

        do {
            return try OutputParser.encodeToJSON(response)
        } catch {
            let errorResponse = ErrorResponse.create(
                error: "Failed to encode response: \(error.localizedDescription)"
            )
            return (try? OutputParser.encodeToJSON(errorResponse)) ?? "{\"success\": false, \"error\": \"Unknown error\"}"
        }
    }
}
