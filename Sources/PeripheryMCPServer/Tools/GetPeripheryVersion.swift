import Foundation
import MCP

/// Tool for getting the installed version of Periphery
struct GetPeripheryVersionTool {
    static let name = "get_periphery_version"
    static let description = "Get the installed version of Periphery"

    static let schema: Tool = Tool(
        name: name,
        description: description,
        inputSchema: .object([
            "type": .string("object")
        ])
    )

    static func execute(arguments: [String: Any]) async -> String {
        do {
            let version = try await PeripheryRunner.getVersion()
            let response = VersionResponse(version: version, rawOutput: version)
            return try OutputParser.encodeToJSON(response)
        } catch let error as PeripheryError {
            let errorResponse = ErrorResponse.create(error: error.description)
            return (try? OutputParser.encodeToJSON(errorResponse)) ?? "{\"success\": false, \"error\": \"\(error.description)\"}"
        } catch {
            let errorResponse = ErrorResponse.create(error: "Unexpected error: \(error.localizedDescription)")
            return (try? OutputParser.encodeToJSON(errorResponse)) ?? "{\"success\": false, \"error\": \"Unknown error\"}"
        }
    }
}
