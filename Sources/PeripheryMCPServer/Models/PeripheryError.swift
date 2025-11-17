import Foundation

/// Errors that can occur during Periphery operations
enum PeripheryError: Error, CustomStringConvertible {
    case notInstalled
    case invalidProjectPath(String)
    case executionFailed(String)
    case parsingFailed(String)
    case timeout
    case invalidVersion(String)

    var description: String {
        switch self {
        case .notInstalled:
            return "Periphery is not installed. Install it using: brew install peripheryapp/periphery/periphery"
        case .invalidProjectPath(let path):
            return "Invalid project path: \(path)"
        case .executionFailed(let message):
            return "Periphery execution failed: \(message)"
        case .parsingFailed(let message):
            return "Failed to parse output: \(message)"
        case .timeout:
            return "Scan timed out after the configured timeout period"
        case .invalidVersion(let version):
            return "Invalid or unsupported Periphery version: \(version)"
        }
    }
}
