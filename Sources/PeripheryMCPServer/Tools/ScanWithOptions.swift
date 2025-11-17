import Foundation
import MCP

/// Tool for advanced scanning with custom Periphery flags
struct ScanWithOptionsTool {
    static let name = "scan_with_options"
    static let description = "Advanced scanning with custom Periphery flags"

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
                ]),
                "retain_public": .object([
                    "type": .string("boolean"),
                    "description": .string("Retain all public declarations")
                ]),
                "retain_objc_accessible": .object([
                    "type": .string("boolean"),
                    "description": .string("Retain @objc declarations")
                ]),
                "disable_unused_import_analysis": .object([
                    "type": .string("boolean"),
                    "description": .string("Disable unused import analysis")
                ]),
                "index_store_path": .object([
                    "type": .string("string"),
                    "description": .string("Custom index store location")
                ]),
                "verbose": .object([
                    "type": .string("boolean"),
                    "description": .string("Enable verbose output")
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

            // Add optional boolean flags
            if let retainPublic = arguments["retain_public"] as? Bool, retainPublic {
                args.append("--retain-public")
            }

            if let retainObjc = arguments["retain_objc_accessible"] as? Bool, retainObjc {
                args.append("--retain-objc-accessible")
            }

            if let disableImports = arguments["disable_unused_import_analysis"] as? Bool, disableImports {
                args.append("--disable-unused-import-analysis")
            }

            if let verbose = arguments["verbose"] as? Bool, verbose {
                args.append("--verbose")
            }

            // Add custom index store path if provided
            if let indexStorePath = arguments["index_store_path"] as? String {
                args.append("--index-store-path")
                args.append(indexStorePath)
            }

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
