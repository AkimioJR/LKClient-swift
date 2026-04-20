import Foundation

public protocol FlexibleStringConvertible {
    init(fromFlexibleString value: String?)
    var flexibleStringValue: String? { get }
}

extension String: FlexibleStringConvertible {
    public init(fromFlexibleString value: String?) {
        self = value ?? ""
    }

    public var flexibleStringValue: String? {
        self
    }
}

extension Optional: FlexibleStringConvertible where Wrapped == String {
    public init(fromFlexibleString value: String?) {
        self = value
    }

    public var flexibleStringValue: String? {
        self
    }
}

@propertyWrapper
public struct FlexibleString<T: FlexibleStringConvertible>: Codable {
    public var wrappedValue: T

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    // 统一的 Decodable 实现（只有这一个，不会冲突）
    public init(from decoder: Decoder) throws {
        let stringValue: String?

        // 尝试获取单值容器，如果失败（键不存在）则使用 nil
        if let container = try? decoder.singleValueContainer() {
            if container.decodeNil() {
                stringValue = nil
            } else if let strValue = try? container.decode(String.self) {
                stringValue = strValue
            } else if let intValue = try? container.decode(Int.self) {
                stringValue = String(intValue)
            } else if let doubleValue = try? container.decode(Double.self) {
                stringValue = String(doubleValue)
            } else {
                stringValue = nil
            }
        } else {
            stringValue = nil
        }

        self.wrappedValue = T(fromFlexibleString: stringValue)
    }

    // 统一的 Encodable 实现（只有这一个，不会冲突）
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let strValue = self.wrappedValue.flexibleStringValue {
            try container.encode(strValue)
        } else {
            try container.encodeNil()
        }
    }
}

extension FlexibleString: Sendable where T: Sendable {}
extension FlexibleString: Equatable where T: Equatable {}
extension FlexibleString: Hashable where T: Hashable {}

// 为 KeyedDecodingContainer 添加扩展，优雅处理可选的 FlexibleString 字段
extension KeyedDecodingContainer {
    public func decode<T>(_ type: FlexibleString<T>.Type, forKey key: Key) throws -> FlexibleString<
        T
    > {
        // 如果键不存在或解码失败，返回 nil 值的 LKBool
        if let value = try? decodeIfPresent(FlexibleString<T>.self, forKey: key) {
            return value
        }
        return FlexibleString(wrappedValue: T(fromFlexibleString: nil))
    }
}
