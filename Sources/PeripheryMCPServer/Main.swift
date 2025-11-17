import Foundation
import MCP

@main
struct PeripheryMCPServerMain {
    static func main() async throws {
        // Define all available tools
        let allTools: [Tool] = [
            CheckPeripheryInstalledTool.schema,
            GetPeripheryVersionTool.schema,
            ScanProjectTool.schema,
            ScanWithConfigTool.schema,
            AnalyzeUnusedImportsTool.schema,
            FindRedundantPublicTool.schema,
            ScanWithOptionsTool.schema
        ]

        // Create the MCP server
        let server = await Server(
            name: "Periphery Code Audit Server",
            version: "1.0.0",
            capabilities: .init(
                tools: .init()
            )
        )
        .withMethodHandler(ListTools.self) { _ in
            ListTools.Result(tools: allTools)
        }
        .withMethodHandler(CallTool.self) { params in
            let arguments = params.arguments?.reduce(into: [String: Any]()) { result, pair in
                result[pair.key] = pair.value.toAny()
            } ?? [:]

            let resultText: String
            switch params.name {
            case CheckPeripheryInstalledTool.name:
                resultText = await CheckPeripheryInstalledTool.execute(arguments: arguments)
            case GetPeripheryVersionTool.name:
                resultText = await GetPeripheryVersionTool.execute(arguments: arguments)
            case ScanProjectTool.name:
                resultText = await ScanProjectTool.execute(arguments: arguments)
            case ScanWithConfigTool.name:
                resultText = await ScanWithConfigTool.execute(arguments: arguments)
            case AnalyzeUnusedImportsTool.name:
                resultText = await AnalyzeUnusedImportsTool.execute(arguments: arguments)
            case FindRedundantPublicTool.name:
                resultText = await FindRedundantPublicTool.execute(arguments: arguments)
            case ScanWithOptionsTool.name:
                resultText = await ScanWithOptionsTool.execute(arguments: arguments)
            default:
                resultText = "{\"success\": false, \"error\": \"Unknown tool: \(params.name)\"}"
            }

            return CallTool.Result(content: [.text(resultText)])
        }

        // Start the server with stdio transport
        let transport = StdioTransport()
        try await server.start(transport: transport)
    }
}
