//
//  LKBool.swift
//  SwiftLK
//
//  Created by 秋澪 on 2026/1/6.
//

public protocol LKBoolConvertible {
    init(fromLKBool value: Bool?)
    var lkBoolValue: Bool? { get }
}

extension Bool: LKBoolConvertible {
    public init(fromLKBool value: Bool?) {
        self = value ?? false
    }

    public var lkBoolValue: Bool? {
        self
    }
}

extension Optional: LKBoolConvertible where Wrapped == Bool {
    public init(fromLKBool value: Bool?) {
        self = value
    }

    public var lkBoolValue: Bool? {
        self
    }
}

@propertyWrapper
public struct LKBool<T: LKBoolConvertible>: Codable, Hashable, Sendable
where T: Codable, T: Hashable, T: Sendable {
    public var wrappedValue: T

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let boolValue: Bool?

        // 尝试获取单值容器，如果失败（键不存在）则使用 nil
        if let container = try? decoder.singleValueContainer() {
            if container.decodeNil() {
                boolValue = nil
            } else if let intValue = try? container.decode(Int.self) {
                boolValue = intValue == 1
            } else if let bool = try? container.decode(Bool.self) {
                boolValue = bool
            } else {
                boolValue = nil
            }
        } else {
            boolValue = nil
        }

        self.wrappedValue = T(fromLKBool: boolValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let boolValue = self.wrappedValue.lkBoolValue {
            try container.encode(boolValue ? 1 : 0)
        } else {
            try container.encodeNil()
        }
    }
}

// 为 KeyedDecodingContainer 添加扩展，优雅处理可选的 LKBool 字段
extension KeyedDecodingContainer {
    public func decode<T>(_ type: LKBool<T>.Type, forKey key: Key) throws -> LKBool<T>
    where T: LKBoolConvertible, T: Codable, T: Hashable {
        // 如果键不存在或解码失败，返回 nil 值的 LKBool
        if let value = try? decodeIfPresent(LKBool<T>.self, forKey: key) {
            return value
        }
        return LKBool(wrappedValue: T(fromLKBool: nil))
    }
}
