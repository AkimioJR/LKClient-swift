//
//  ArticleType.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/11/23.
//

public enum ArticleType: UInt8, Codable, Sendable, CaseIterable, Identifiable, Hashable {
    case other = 0  // 其他
    case book = 1  // 图书

    public var id: Self { self }
}

extension ArticleType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .other:
            return "其他"
        case .book:
            return "图书"
        }
    }
}
