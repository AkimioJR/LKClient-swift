//
//  Search.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/11/18.
//

import Foundation

public enum SearchType: UInt8, Codable, Sendable {
    case all = 0
    case user = 1
    case series = 2
    case news = 3
    case anime = 4
    case manga = 5
    case lightnovel = 6

    public var name: String {
        switch self {
        case .all:
            return "全部"
        case .user:
            return "用户"
        case .series:
            return "集合"
        case .news:
            return "资讯"
        case .anime:
            return "动画"
        case .manga:
            return "漫画"
        case .lightnovel:
            return "轻小说"
        }
    }
}

extension SearchType: CustomStringConvertible {
    public var description: String {
        return "SearchType.\(self.rawValue) (\(self.name))"
    }
}

struct GetSearchRequest: Codable, Sendable {
    var query: String
    var type: SearchType
    var page: UInt
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case query = "q"
        case type = "type"
        case page = "page"
        case securityKey = "security_key"
    }
}

public struct UserSearchResult: Codable, Sendable {
    public struct SearchData: Codable, Sendable {
        public var userId: UInt
        public var nickName: String
        public var avatarURL: String
        @LKBool public var passer: Bool
        public var gender: GenderType
        public var sign: String
        @LKBool public var status: Bool
        public var bannerURL: String
        public var banEndDate: Date
        public var followingCount: UInt
        public var commentCount: UInt
        public var favoriteCount: UInt
        public var articleCount: UInt
        public var followerCount: UInt
        public var medals: [Medal]
        public var levelInfo: LevelInfo
        public var highlightedNickname: String

        enum CodingKeys: String, CodingKey {
            case userId = "uid"
            case nickName = "nickname"
            case avatarURL = "avatar"
            case passer = "passer"
            case gender = "gender"
            case sign = "sign"
            case status = "status"
            case bannerURL = "banner"
            case banEndDate = "ban_end_date"
            case followingCount = "following"
            case commentCount = "comments"
            case favoriteCount = "favorites"
            case articleCount = "articles"
            case followerCount = "followers"
            case medals = "medals"
            case levelInfo = "level"
            case highlightedNickname = "highlighted_nickname"
        }
    }

    public var list: [SearchData]
    public var pageInfo: PageInfo

    enum CodingKeys: String, CodingKey {
        case list = "list"
        case pageInfo = "page_info"
    }
}

public struct SeriesSearchResult: Codable, Sendable {
    struct UserInfo: Codable, Sendable {
        static let `default` = UserInfo(
            userId: 0,
            nickName: "",
            avatarURL: "",
            passer: false,
            gender: .unknown,
            sign: "",
            status: false,
            bannerURL: "",
            banEndDate: Date(timeIntervalSince1970: 0),
            levelInfo: .default,
        )

        var userId: UInt
        var nickName: String
        var avatarURL: String
        @LKBool var passer: Bool
        var gender: GenderType
        var sign: String
        @LKBool var status: Bool
        var bannerURL: String
        var banEndDate: Date
        var levelInfo: LevelInfo

        enum CodingKeys: String, CodingKey {
            case userId = "uid"
            case nickName = "nickname"
            case avatarURL = "avatar"
            case passer = "passer"
            case gender = "gender"
            case sign = "sign"
            case status = "status"
            case bannerURL = "banner"
            case banEndDate = "ban_end_date"
            case levelInfo = "level"
        }
    }
    struct SearchData: Codable, Sendable {
        var author: String  // 作者（并非发布集合的作者）
        var bannerURL: String
        var coverURL: String
        var coverType: CoverType
        var editors: [UserInfo]
        var groupId: GroupId
        var hightlightName: String
        var hitCount: UInt
        var updateTime: Date
        var likeCount: UInt
        var seriesName: String
        var order: UInt
        var rateCount: UInt
        var seriesId: UInt

        enum CodingKeys: String, CodingKey {
            case author = "author"
            case bannerURL = "banner"
            case coverURL = "cover"
            case coverType = "cover_type"
            case editors = "editors"
            case groupId = "gid"
            case hightlightName = "highlighted_name"
            case hitCount = "hits"
            case updateTime = "last_time"
            case likeCount = "likes"
            case seriesName = "name"
            case order = "order"
            case rateCount = "rates"
            case seriesId = "sid"
        }
    }

    var list: [SearchData]
    var pageInfo: PageInfo

    enum CodingKeys: String, CodingKey {
        case list = "list"
        case pageInfo = "page_info"
    }
}

public struct ArticleSearchResult: Codable, Sendable {
    public struct SearchData: Codable, Sendable {
        public var articleId: UInt
        public var author: FlexibleParam
        public var avatarURL: String
        public var bannerURL: String
        public var commentCount: UInt
        public var coverURL: String
        public var coverType: CoverType

        public var groupId: GroupId
        public var hightlightTitle: String
        public var hitCount: UInt
        public var seriesId: UInt
        public var createTime: Date
        public var title: String
        public var userId: UInt

        // 仅资讯（News）有这个结果
        @LKBool public var empty: Bool?

        enum CodingKeys: String, CodingKey {
            case articleId = "aid"
            case author = "author"
            case avatarURL = "avatar"
            case bannerURL = "banner"
            case commentCount = "comments"
            case coverURL = "cover"
            case coverType = "cover_type"
            case empty = "empty"
            case groupId = "gid"
            case hightlightTitle = "highlighted_title"
            case hitCount = "hits"
            case seriesId = "sid"
            case createTime = "time"
            case title = "title"
            case userId = "uid"
        }
    }

    public var list: [SearchData]
    public var pageInfo: PageInfo

    enum CodingKeys: String, CodingKey {
        case list = "list"
        case pageInfo = "page_info"
    }
}

public struct HotSearchTag: Codable, Sendable {
    public var id: UInt
    public var word: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case word = "alias"
    }
}
