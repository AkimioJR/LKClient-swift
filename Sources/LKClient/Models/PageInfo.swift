//
//  PageInfo.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/12/20.
//

public struct PageInfo: Codable, Sendable {
    public var count: UInt
    public var size: UInt
    public var currentPage: UInt
    public var previousPage: UInt
    public var nextPage: UInt
    @LKBool public var hasPreviousPage: Bool
    @LKBool public var hasNextPage: Bool
    public var model: UInt
    public var supportModels: [UInt]

    enum CodingKeys: String, CodingKey {
        case count = "count"
        case size = "size"
        case currentPage = "cur"
        case previousPage = "prev"
        case nextPage = "next"
        case hasPreviousPage = "has_prev"
        case hasNextPage = "has_next"
        case model = "model"
        case supportModels = "support_model"
    }
}
