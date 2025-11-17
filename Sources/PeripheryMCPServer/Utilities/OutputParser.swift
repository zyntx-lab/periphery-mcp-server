import Foundation

/// Utility for parsing Periphery output
struct OutputParser {
    /// Parses Periphery JSON output into structured results
    /// - Parameter jsonString: Raw JSON output from Periphery
    /// - Returns: Array of PeripheryResult objects
    /// - Throws: PeripheryError.parsingFailed if parsing fails
    static func parseResults(_ jsonString: String) throws -> [PeripheryResult] {
        guard !jsonString.isEmpty else {
            return []
        }

        guard let data = jsonString.data(using: .utf8) else {
            throw PeripheryError.parsingFailed("Failed to convert string to data")
        }

        let decoder = JSONDecoder()
        do {
            let results = try decoder.decode([PeripheryResult].self, from: data)
            return results
        } catch {
            throw PeripheryError.parsingFailed("JSON decoding failed: \(error.localizedDescription)")
        }
    }

    /// Filters results to only include unused imports
    /// - Parameter results: All scan results
    /// - Returns: Filtered results containing only imports
    static func filterUnusedImports(_ results: [PeripheryResult]) -> [PeripheryResult] {
        return results.filter { $0.kind == "import" }
    }

    /// Filters results to find redundant public declarations
    /// - Parameter results: All scan results
    /// - Returns: Filtered results containing only redundant public declarations
    static func filterRedundantPublic(_ results: [PeripheryResult]) -> [PeripheryResult] {
        return results.filter { result in
            result.modifiers.contains("public") ||
            result.modifiers.contains("open")
        }
    }

    /// Parses version string into components
    /// - Parameter versionString: Version string (e.g., "2.18.0")
    /// - Returns: Tuple of (major, minor, patch) or nil if parsing fails
    static func parseVersion(_ versionString: String) -> (major: Int, minor: Int, patch: Int)? {
        let cleaned = versionString.trimmingCharacters(in: .whitespacesAndNewlines)
        let components = cleaned.split(separator: ".").compactMap { Int($0) }

        guard components.count >= 2 else {
            return nil
        }

        return (
            major: components[0],
            minor: components[1],
            patch: components.count > 2 ? components[2] : 0
        )
    }

    /// Checks if a version supports JSON format
    /// - Parameter version: Version string
    /// - Returns: True if JSON format is supported
    static func supportsJSONFormat(version: String) -> Bool {
        guard let parsed = parseVersion(version) else {
            return false
        }

        // JSON format has been supported since Periphery 2.0
        return parsed.major >= 2
    }

    /// Converts results to JSON string
    /// - Parameter output: ScanOutput to convert
    /// - Returns: JSON string representation
    /// - Throws: PeripheryError.parsingFailed if encoding fails
    static func encodeToJSON<T: Encodable>(_ output: T) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let data = try encoder.encode(output)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                throw PeripheryError.parsingFailed("Failed to convert data to string")
            }
            return jsonString
        } catch {
            throw PeripheryError.parsingFailed("JSON encoding failed: \(error.localizedDescription)")
        }
    }
}
