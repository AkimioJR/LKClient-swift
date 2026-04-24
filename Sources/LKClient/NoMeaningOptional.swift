import Foundation

// MARK: - 零值判断协议
/// 用于判断一个类型是否为“无意义零值”的协议
public protocol ZeroRepresentable {
    /// 判断当前值是否为无意义的零值
    var isNoMeaningZero: Bool { get }
}

// MARK: - 常见类型的 ZeroRepresentable 实现
// 数字类型 (0 视为零值)
// extension Int: ZeroRepresentable {
//     public var isNoMeaningZero: Bool { self == 0 }
// }
extension UInt: ZeroRepresentable {
    public var isNoMeaningZero: Bool { self == 0 }
}
// extension Int64: ZeroRepresentable {
//     public var isNoMeaningZero: Bool { self == 0 }
// }
// extension UInt64: ZeroRepresentable {
//     public var isNoMeaningZero: Bool { self == 0 }
// }

// 字符串 (空字符串 "" 视为零值)
extension String: ZeroRepresentable {
    public var isNoMeaningZero: Bool { self.isEmpty }
}

// // 数组 (空数组 [] 视为零值)
// extension Array: ZeroRepresentable {
//     public var isNoMeaningZero: Bool { self.isEmpty }
// }

// // 布尔值 (false 视为零值，根据你的需求可选是否开启)
// extension Bool: ZeroRepresentable {
//     public var isNoMeaningZero: Bool { self == false }
// }

// MARK: - 属性包装器定义
@propertyWrapper
public struct NoMeaningOptional<Wrapped: Decodable & ZeroRepresentable> {
    public var wrappedValue: Wrapped?

    public init(wrappedValue: Wrapped?) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: - Decodable 实现
extension NoMeaningOptional: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // 1. 尝试解码值
        if let value = try? container.decode(Wrapped.self) {
            wrappedValue = value.isNoMeaningZero ? nil : value  // 2. 如果解码成功，判断是否为零值
        } else {
            wrappedValue = nil  // 3. 解码失败（字段缺失或类型不匹配），设为 nil
        }
    }
}

// MARK: - Encodable 实现 (可选，用于编码回 JSON)
extension NoMeaningOptional: Encodable where Wrapped: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let value = wrappedValue {
            try container.encode(value)
        } else {
            try container.encodeNil()
        }
    }
}

extension NoMeaningOptional: Sendable where Wrapped: Sendable {}
extension NoMeaningOptional: Equatable where Wrapped: Equatable {}
extension NoMeaningOptional: Hashable where Wrapped: Hashable {}
