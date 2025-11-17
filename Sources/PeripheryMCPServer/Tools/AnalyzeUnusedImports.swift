import Foundation
import MCP

/// Tool for analyzing unused imports in a project
struct AnalyzeUnusedImportsTool {
    static let name = "analyze_unused_imports"
    static let description = "Focus specifically on detecting unused imports"

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
            var args: [String] = ["scan", "--format", "json"]

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

            // Execute Periphery
            let output = try await PeripheryRunner.execute(args)

            // Parse and filter results for imports only
            let allResults = try OutputParser.parseResults(output)
            let importResults = OutputParser.filterUnusedImports(allResults)

            let scanOutput = ScanOutput.success(results: importResults)
            return try OutputParser.encodeToJSON(scanOutput)
        } catch let error as PeripheryError {
            let errorResponse = ScanOutput.failure(error: error.description)
            return (try? OutputParser.encodeToJSON(errorResponse)) ?? "{\"success\": false, \"error\": \"\(error.description)\"}"
        } catch {
            let errorResponse = ScanOutput.failure(error: "Unexpected error: \(error.localizedDescription)")
            return (try? OutputParser.encodeToJSON(errorResponse)) ?? "{\"success\": false, \"error\": \"Unknown error\"}"
        }
    }
}
