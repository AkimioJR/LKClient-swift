//
//  Page.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/12/20.
//

public struct PageInfo: Codable, Sendable {
    static let `default` = PageInfo(
        count: 0,
        size: 0,
        currentPage: 0,
        previousPage: 0,
        nextPage: 0,
        hasPreviousPage: false,
        hasNextPage: false,
        model: 0,
        supportModels: []
    )

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

public struct Page<T: Decodable & Sendable>: Decodable, Sendable {
    public var info: PageInfo
    public var list: [T]

    enum CodingKeys: String, CodingKey {
        case info = "page_info"
        case list = "list"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.info = try container.decodeIfPresent(PageInfo.self, forKey: .info) ?? .default  // 当 list 为空时，page_info 可能不存在，此时使用默认值
        self.list = try container.decodeIfPresent([T].self, forKey: .list) ?? []  // 当 list 为空时，list 可能不存在，此时使用空数组
    }
}

extension Page: Encodable where T: Encodable {}
