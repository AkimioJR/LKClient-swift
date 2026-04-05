import Foundation

public enum FlexibleParam: Codable, Sendable {
    case string(String)
    case uint(UInt)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let uintValue = try? container.decode(UInt.self) {
            self = .uint(uintValue)
        } else {
            let stringValue = try container.decode(String.self)
            self = .string(stringValue)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let stringValue):
            try container.encode(stringValue)
        case .uint(let uintValue):
            try container.encode(uintValue)
        }
    }

    // 便利属性和方法
    public var isString: Bool {
        if case .string = self {
            return true
        }
        return false
    }

    public var isUInt: Bool {
        if case .uint = self {
            return true
        }
        return false
    }

    public var stringValue: String? {
        if case .string(let value) = self {
            return value
        }
        return nil
    }

    public var uintValue: UInt? {
        if case .uint(let value) = self {
            return value
        }
        return nil
    }
}
