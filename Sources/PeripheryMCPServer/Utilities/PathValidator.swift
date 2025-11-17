import Foundation

/// Utility for validating file system paths
struct PathValidator {
    /// Validates that a project path exists and is a valid Xcode project or Swift Package
    /// - Parameter path: The path to validate
    /// - Returns: The validated absolute path
    /// - Throws: PeripheryError.invalidProjectPath if validation fails
    static func validateProjectPath(_ path: String) throws -> String {
        let fileManager = FileManager.default
        let expandedPath = NSString(string: path).expandingTildeInPath
        let absolutePath: String

        // Convert to absolute path if needed
        if expandedPath.hasPrefix("/") {
            absolutePath = expandedPath
        } else {
            absolutePath = fileManager.currentDirectoryPath + "/" + expandedPath
        }

        // Check if path exists
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: absolutePath, isDirectory: &isDirectory) else {
            throw PeripheryError.invalidProjectPath("Path does not exist: \(absolutePath)")
        }

        // For Xcode projects, check if it's a .xcodeproj
        if absolutePath.hasSuffix(".xcodeproj") {
            guard isDirectory.boolValue else {
                throw PeripheryError.invalidProjectPath("Expected directory, found file: \(absolutePath)")
            }
            return absolutePath
        }

        // For Swift Packages, check if Package.swift exists
        if isDirectory.boolValue {
            let packageSwiftPath = absolutePath + "/Package.swift"
            if fileManager.fileExists(atPath: packageSwiftPath) {
                return absolutePath
            }
        }

        // If it's a file named Package.swift, return its directory
        if absolutePath.hasSuffix("Package.swift") && !isDirectory.boolValue {
            return NSString(string: absolutePath).deletingLastPathComponent
        }

        throw PeripheryError.invalidProjectPath(
            "Path must be an .xcodeproj or directory containing Package.swift: \(absolutePath)"
        )
    }

    /// Validates that a config file exists
    /// - Parameter path: The path to the config file
    /// - Returns: The validated absolute path
    /// - Throws: PeripheryError.invalidProjectPath if validation fails
    static func validateConfigPath(_ path: String) throws -> String {
        let fileManager = FileManager.default
        let expandedPath = NSString(string: path).expandingTildeInPath
        let absolutePath: String

        // Convert to absolute path if needed
        if expandedPath.hasPrefix("/") {
            absolutePath = expandedPath
        } else {
            absolutePath = fileManager.currentDirectoryPath + "/" + expandedPath
        }

        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: absolutePath, isDirectory: &isDirectory),
              !isDirectory.boolValue else {
            throw PeripheryError.invalidProjectPath("Config file does not exist: \(absolutePath)")
        }

        return absolutePath
    }
}
