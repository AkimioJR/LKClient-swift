//
//  PageInfo.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/12/20.
//

public struct PageInfo: Codable, Sendable {
    var count: UInt
    var size: UInt
    var currentPage: UInt
    var previousPage: UInt
    var nextPage: UInt
    @LKBool var hasPreviousPage: Bool
    @LKBool var hasNextPage: Bool
    var model: UInt
    var supportModels: [UInt]

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
