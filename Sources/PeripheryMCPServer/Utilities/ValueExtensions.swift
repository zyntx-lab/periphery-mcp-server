import Foundation
import MCP

extension Value {
    /// Converts a Value to its Any representation for tool execution
    func toAny() -> Any {
        switch self {
        case .null:
            return NSNull()
        case .bool(let bool):
            return bool
        case .int(let int):
            return int
        case .double(let double):
            return double
        case .string(let string):
            return string
        case .data(_, let data):
            return data
        case .array(let array):
            return array.map { $0.toAny() }
        case .object(let dict):
            return dict.mapValues { $0.toAny() }
        }
    }
}
