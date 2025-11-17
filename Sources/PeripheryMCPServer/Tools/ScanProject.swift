import Foundation
import MCP

/// Tool for running a basic Periphery scan on a project
struct ScanProjectTool {
    static let name = "scan_project"
    static let description = "Run a basic Periphery scan on a project"

    static let schema: Tool = Tool(
        name: name,
        description: description,
        inputSchema: .object([
            "type": .string("object"),
            "properties": .object([
                "project_path": .object([
                    "type": .string("string"),
                    "description": .string("Path to .xcodeproj or Package.swift")
                ]),
                "schemes": .object([
                    "type": .string("array"),
                    "description": .string("Build schemes to scan (Xcode only)"),
                    "items": .object([
                        "type": .string("string")
                    ])
                ]),
                "targets": .object([
                    "type": .string("array"),
                    "description": .string("Specific targets to analyze"),
                    "items": .object([
                        "type": .string("string")
                    ])
                ]),
                "format": .object([
                    "type": .string("string"),
                    "description": .string("Output format: json, xcode, csv, checkstyle (default: json)")
                ])
            ]),
            "required": .array([.string("project_path")])
        ])
    )

    static func execute(arguments: [String: Any]) async -> String {
        do {
            // Extract and validate project path
            guard let projectPath = arguments["project_path"] as? String else {
                let errorResponse = ErrorResponse.create(error: "Missing required parameter: project_path")
                return try OutputParser.encodeToJSON(errorResponse)
            }

            let validatedPath = try PathValidator.validateProjectPath(projectPath)

            // Build command arguments
            var args: [String] = ["scan"]

            // Determine if it's an Xcode project or Swift Package
            if validatedPath.hasSuffix(".xcodeproj") {
                args.append("--project")
                args.append(validatedPath)

                // Add schemes if provided
                if let schemes = arguments["schemes"] as? [String], !schemes.isEmpty {
                    args.append("--schemes")
                    args.append(schemes.joined(separator: ","))
                }
            } else {
                // Swift Package
                args.append("--project")
                args.append(validatedPath)
            }

            // Add targets if provided
            if let targets = arguments["targets"] as? [String], !targets.isEmpty {
                args.append("--targets")
                args.append(targets.joined(separator: ","))
            }

            // Set output format (default to json)
            let format = arguments["format"] as? String ?? "json"
            args.append("--format")
            args.append(format)

            // Execute Periphery
            let output = try await PeripheryRunner.execute(args)

            // Parse results if format is json
            if format == "json" {
                let results = try OutputParser.parseResults(output)
                let scanOutput = ScanOutput.success(results: results)
                return try OutputParser.encodeToJSON(scanOutput)
            } else {
                // For non-JSON formats, return raw output wrapped in a success response
                let response: [String: Any] = [
                    "success": true,
                    "output": output,
                    "format": format
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
