//
//  DestinationView.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/11/10.
//

import Foundation

public struct ParentGroupRecommendItems: Codable, Sendable {
    public var id: ParentGroupId
    //var logo: String
    public var coverType: CoverType
    public var items: [Item]
    public var updateTime: Date

    public struct Item: Codable, Sendable {
        public var articleId: UInt
        public var title: String
        public var coverURL: String
        public var bannerURL: String
        public var seriesId: UInt
        public var seriesName: String?  // 非集合文章值为nil
        public var hitCount: UInt
        public var commentCount: UInt
        public var rank: UInt
        public var likeCount: UInt
        public var coinCount: UInt
        public var shareCount: UInt

        enum CodingKeys: String, CodingKey {
            case articleId = "aid"
            case title = "title"
            case coverURL = "cover"
            case bannerURL = "banner"
            case seriesId = "sid"
            case seriesName = "series_name"
            case hitCount = "hits"
            case likeCount = "likes"
            case coinCount = "coins"
            case commentCount = "comments"
            case shareCount = "shares"
            case rank = "rank"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id = "gid"
        //case logo = "logo"
        case coverType = "cover_type"
        case items = "items"
        case updateTime = "last_time"
    }
}

struct FetchParentGroupRecommendItemsRequest: Codable, Sendable {
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case securityKey = "security_key"
    }
}
