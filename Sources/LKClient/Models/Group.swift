//
//  DestinationView.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/11/10.
//

import Foundation

public struct ParentGroupItem: Codable, Sendable {
    var id: ParentGroupId
    //var logo: String
    var coverType: CoverType
    var articleItems: [ArticleInfo]
    var updateTime: Date

    struct ArticleInfo: Codable, Sendable {
        var articleId: UInt
        var title: String
        var coverURL: String
        var bannerURL: String
        var seriesId: UInt
        var seriesName: String?  // 非集合文章值为nil
        var hitCount: UInt
        var commentCount: UInt
        var rank: UInt
        var likeCount: UInt
        var coinCount: UInt
        var shareCount: UInt

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
        case articleItems = "items"
        case updateTime = "last_time"
    }
}

struct getParentGroupInfoRequest: Codable, Sendable {
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case securityKey = "security_key"
    }
}
