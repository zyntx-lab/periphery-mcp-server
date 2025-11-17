import Foundation

/// Response for checking Periphery installation
struct InstallationCheckResponse: Codable, Sendable {
    let installed: Bool
    let path: String?
    let message: String
}

/// Response for getting Periphery version
struct VersionResponse: Codable, Sendable {
    let version: String
    let rawOutput: String

    enum CodingKeys: String, CodingKey {
        case version
        case rawOutput = "raw_output"
    }
}

/// Generic error response
struct ErrorResponse: Codable, Sendable {
    let success: Bool
    let error: String

    static func create(error: String) -> ErrorResponse {
        return ErrorResponse(success: false, error: error)
    }
}
