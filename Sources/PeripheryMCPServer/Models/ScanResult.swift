import Foundation

/// Represents a single unused code detection from Periphery
struct PeripheryResult: Codable, Sendable {
    let kind: String
    let name: String
    let modifiers: [String]
    let location: String
    let hints: [String]?

    enum CodingKeys: String, CodingKey {
        case kind
        case name
        case modifiers
        case location
        case hints
    }
}

/// Summary statistics for a scan
struct ScanSummary: Codable, Sendable {
    let totalUnused: Int
    let byKind: [String: Int]

    enum CodingKeys: String, CodingKey {
        case totalUnused = "total_unused"
        case byKind = "by_kind"
    }

    init(results: [PeripheryResult]) {
        self.totalUnused = results.count

        var kindCounts: [String: Int] = [:]
        for result in results {
            kindCounts[result.kind, default: 0] += 1
        }
        self.byKind = kindCounts
    }

    init(totalUnused: Int, byKind: [String: Int]) {
        self.totalUnused = totalUnused
        self.byKind = byKind
    }
}

/// Output structure for scan operations
struct ScanOutput: Codable, Sendable {
    let success: Bool
    let results: [PeripheryResult]?
    let summary: ScanSummary?
    let error: String?

    static func success(results: [PeripheryResult]) -> ScanOutput {
        let summary = ScanSummary(results: results)
        return ScanOutput(
            success: true,
            results: results,
            summary: summary,
            error: nil
        )
    }

    static func failure(error: String) -> ScanOutput {
        return ScanOutput(
            success: false,
            results: nil,
            summary: nil,
            error: error
        )
    }
}
