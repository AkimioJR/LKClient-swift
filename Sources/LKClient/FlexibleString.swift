import Foundation

public protocol FlexibleStringValue: Codable, Sendable, Hashable {
    init(from container: SingleValueDecodingContainer) throws
    func encode(to container: inout SingleValueEncodingContainer) throws
}

// 让 String 遵循协议
extension String: FlexibleStringValue {
    public init(from container: SingleValueDecodingContainer) throws {
        if let string = try? container.decode(String.self) {
            self = string
        } else if let int = try? container.decode(Int.self) {
            self = String(int)
        } else {
            let double = try container.decode(Double.self)
            self = String(double)
        }
    }

    public func encode(to container: inout SingleValueEncodingContainer) throws {
        try container.encode(self)
    }
}

// 让 String? (Optional<String>) 遵循协议
extension Optional: FlexibleStringValue where Wrapped == String {
    public init(from container: SingleValueDecodingContainer) throws {
        if container.decodeNil() {
            self = nil
        } else if let string = try? container.decode(String.self) {
            self = string
        } else if let int = try? container.decode(Int.self) {
            self = String(int)
        } else {
            let double = try container.decode(Double.self)
            self = String(double)
        }
    }

    public func encode(to container: inout SingleValueEncodingContainer) throws {
        switch self {
        case .some(let string):
            try container.encode(string)
        case .none:
            try container.encodeNil()
        }
    }
}

// 最终的属性包装器
// 约束 Value: FlexibleStringValue
@propertyWrapper
public struct FlexibleString<Value: FlexibleStringValue>: Codable, Sendable, Hashable {
    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    // 统一的 Decodable 实现（只有这一个，不会冲突）
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = try Value(from: container)
    }

    // 统一的 Encodable 实现（只有这一个，不会冲突）
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try wrappedValue.encode(to: &container)
    }
}
