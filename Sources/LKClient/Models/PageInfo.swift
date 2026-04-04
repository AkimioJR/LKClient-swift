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

    public init(
        count: UInt, size: UInt, currentPage: UInt, previousPage: UInt, nextPage: UInt,
        hasPreviousPage: Bool, hasNextPage: Bool, model: UInt, supportModels: [UInt]
    ) {
        self.count = count
        self.size = size
        self.currentPage = currentPage
        self.previousPage = previousPage
        self.nextPage = nextPage
        self.hasPreviousPage = hasPreviousPage
        self.hasNextPage = hasNextPage
        self.model = model
        self.supportModels = supportModels
    }

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
