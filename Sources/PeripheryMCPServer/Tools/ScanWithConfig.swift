import Foundation
import MCP

/// Tool for running Periphery scan using a YAML configuration file
struct ScanWithConfigTool {
    static let name = "scan_with_config"
    static let description = "Run Periphery scan using a YAML configuration file"

    static let schema: Tool = Tool(
        name: name,
        description: description,
        inputSchema: .object([
            "type": .string("object"),
            "properties": .object([
                "config_path": .object([
                    "type": .string("string"),
                    "description": .string("Path to .periphery.yml config file")
                ])
            ]),
            "required": .array([.string("config_path")])
        ])
    )

    static func execute(arguments: [String: Any]) async -> String {
        do {
            // Extract and validate config path
            guard let configPath = arguments["config_path"] as? String else {
                let errorResponse = ErrorResponse.create(error: "Missing required parameter: config_path")
                return try OutputParser.encodeToJSON(errorResponse)
            }

            let validatedPath = try PathValidator.validateConfigPath(configPath)

            // Build command arguments
            let args: [String] = [
                "scan",
                "--config",
                validatedPath
            ]

            // Execute Periphery
            let output = try await PeripheryRunner.execute(args)

            // Parse results (config files typically output JSON by default or as specified in config)
            // Try to parse as JSON first
            if let results = try? OutputParser.parseResults(output) {
                let scanOutput = ScanOutput.success(results: results)
                return try OutputParser.encodeToJSON(scanOutput)
            } else {
                // If not JSON, return raw output
                let response: [String: Any] = [
                    "success": true,
                    "output": output
                ]
                let data = try JSONSerialization.data(withJSONObject: response, options: [.prettyPrinted, .sortedKeys])
                return String(data: data, encoding: .utf8) ?? "{}"
            }
        } catch let error as PeripheryError {
            let errorResponse = ScanOutput.failure(error: error.description)
            return (try? OutputParser.encodeToJSON(errorResponse)) ?? "{\"success\": false, \"error\": \"\(error.description)\"}"
        } catch {
            let errorResponse = ScanOutput.failure(error: "Unexpected error: \(error.localizedDescription)")
            return (try? OutputParser.encodeToJSON(errorResponse)) ?? "{\"success\": false, \"error\": \"Unknown error\"}"
        }
    }
}
