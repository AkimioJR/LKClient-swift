//
//  History.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/11/18.
//

import Foundation

// 添加/删除收藏请求
struct HistoryRequest: Codable, Sendable {
    var favoriteId: UInt
    var classType: ClassType
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case favoriteId = "fid"
        case classType = "class"
        case securityKey = "security_key"
    }
}

struct ArticleRecordInfo: Codable, Sendable {
    var articleId: UInt
    var title: String
    var bannerURL: String
    var userId: UInt
    var hitCount: UInt
    var commentCount: UInt
    var createTime: Date
    var updateTime: Date
    var coverURL: String
    var coverType: CoverType
    var groupId: GroupId
    var parentGroupId: ParentGroupId
    var seriesId: UInt

    enum CodingKeys: String, CodingKey {
        case articleId = "aid"
        case title = "title"
        case bannerURL = "banner"
        case userId = "uid"
        case hitCount = "hits"
        case commentCount = "comments"
        case createTime = "time"
        case updateTime = "last_time"
        case coverURL = "cover"
        case coverType = "cover_type"
        case groupId = "gid"
        case parentGroupId = "parent_gid"
        case seriesId = "sid"
    }
}

struct SeriesRecordInfo: Codable, Sendable {
    var seriesId: UInt
    var name: String
    var author: String
    var bannerURL: String
    var coverURL: String
    var coverType: CoverType
    var rateCount: UInt
    var updateTime: Date
    var groupId: GroupId
    var parentGroupId: ParentGroupId
    var editors: [SeriesInfo.EditorInfo]

    enum CodingKeys: String, CodingKey {
        case seriesId = "sid"
        case name = "name"
        case author = "author"
        case bannerURL = "banner"
        case coverURL = "cover"
        case coverType = "cover_type"
        case rateCount = "rates"
        case updateTime = "last_time"
        case groupId = "gid"
        case parentGroupId = "parent_gid"
        case editors = "editors"
    }
}

public struct HistoryRecord<T: Codable & Sendable>: Codable, Sendable {
    var list: [T]
    var pageInfo: PageInfo

    enum CodingKeys: String, CodingKey {
        case list = "list"
        case pageInfo = "page_info"
    }
}

struct GetHistoryRequest: Codable, Sendable {
    var type: ArticleType
    var classType: ClassType
    var page: UInt
    var pageSize: UInt
    var userId: UInt
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case classType = "class"
        case page = "page"
        case pageSize = "page_size"
        case userId = "uid"
        case securityKey = "security_key"
    }
}
