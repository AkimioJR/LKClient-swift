//
//  ClassType.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/11/23.
//

public enum ClassType: UInt8, Codable, Sendable {
    case article = 1  // 文章
    case series = 2  // 系列集合
    case themereply = 4  // 主题回复
}

extension ClassType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .article:
            return "文章"
        case .series:
            return "系列集合"
        case .themereply:
            return "主题回复"
        }
    }
}
