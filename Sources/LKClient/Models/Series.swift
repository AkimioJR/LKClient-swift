//
//  Series.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/11/18.
//

import Foundation

public struct SeriesInfo: Codable, Sendable {
    struct EditorInfo: Codable, Sendable {
        static let `default` = EditorInfo(
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

        // 搜索接口中没有下面这些字段
        var followingCount: UInt?
        var commentCount: UInt?
        var favoriteCount: UInt?
        var articleCount: UInt?
        var followerCount: UInt?
        var medals: [Medal]?

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

            case followingCount = "following"
            case commentCount = "comments"
            case favoriteCount = "favorites"
            case articleCount = "articles"
            case followerCount = "followers"
            case medals = "medals"
        }
    }

    struct ArticleInfo: Codable, Sendable {
        static let `default` = ArticleInfo(
            order: 0,
            articleId: 0,
            title: "",
            bannerURL: "",
            coverURL: "",
            // hitCount: 0,
            // commentCount: 0,
            coverType: .landscape,
            createTime: Date(timeIntervalSince1970: 0),
            updateTime: Date(timeIntervalSince1970: 0)
        )

        var order: UInt
        var articleId: UInt
        var title: String
        var bannerURL: String
        var coverURL: String
        // var hitCount: UInt
        // var commentCount: UInt
        var coverType: CoverType
        var createTime: Date
        var updateTime: Date

        enum CodingKeys: String, CodingKey {
            case order = "order"
            case articleId = "aid"
            case title = "title"
            case bannerURL = "banner"
            case coverURL = "cover"
            // case hitCount = "hits"
            // case commentCount = "comments"
            case coverType = "cover_type"
            case createTime = "time"
            case updateTime = "last_time"
        }
    }

    struct UserRead: Codable, Sendable {
        var lastArticleId: UInt

        enum CodingKeys: String, CodingKey {
            case lastArticleId = "last_aid"
        }
    }

    static let `default` = SeriesInfo(
        seriesId: 0,
        seriesName: "",
        groupId: .all,
        author: "",
        intro: "",
        bannerURL: "",
        rate: 0,
        coverURL: "",
        coverType: .landscape,
        rateCount: 0,
        updateTime: Date(timeIntervalSince1970: 0),
        hitCount: 0,
        likeCount: 0,
        editors: [],
        score: 0.0,
        articles: [],
    )

    var seriesId: UInt
    var seriesName: String
    var groupId: GroupId
    var author: String  // 作者（并非发布集合的作者）
    var intro: String  // 简介
    var bannerURL: String
    var rate: UInt  // 0～5
    var coverURL: String
    var coverType: CoverType
    var rateCount: UInt  // 评分人数
    var updateTime: Date
    var hitCount: UInt
    var likeCount: UInt
    var editors: [EditorInfo]
    var score: Float64  // 0～10
    // var characters: [Any] // 未知数据结构
    var articles: [ArticleInfo]

    // 用户对集合的个人信息
    @LKBool var alreadyFavavorite: Bool?  // 是否已收藏
    @LKBool var alreadyRate: Bool?  // 是否已经评分
    @LKBool var alreadyLike: Bool?  // 是否已点赞
    var userRead: UserRead?  // 用户阅读进度

    enum CodingKeys: String, CodingKey {
        case seriesId = "sid"
        case seriesName = "name"
        case groupId = "gid"
        case author = "author"
        case intro = "intro"
        case bannerURL = "banner"
        case rate = "rate"
        case coverURL = "cover"
        case coverType = "cover_type"
        case rateCount = "rates"
        case updateTime = "last_time"
        case hitCount = "hits"
        case likeCount = "likes"
        case editors = "editors"
        case score = "score"
        // case characters = "characters"
        case articles = "articles"
        case alreadyFavavorite = "already_fav"
        case alreadyRate = "already_rate"
        case alreadyLike = "already_like"
        case userRead = "user_read"
    }
}

struct GetSeriesRequest: Codable, Sendable {
    var seriesId: UInt
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case seriesId = "sid"
        case securityKey = "security_key"
    }
}

public struct SeriesRateInfo: Codable, Sendable {
    struct RateDetail: Codable, Sendable {
        var userId: UInt
        var rate: UInt
        var text: String
        var time: Date
        var score: UInt
        var likeCount: UInt
        var userInfo: UserProfileDetail
        // @LKBool var alreadyLike: Bool

        enum CodingKeys: String, CodingKey {
            case userId = "uid"
            case rate = "rate"
            case text = "text"
            case time = "time"
            case score = "score"
            case likeCount = "likes"
            case userInfo = "user_info"
            // case alreadyLike = "already_like"
        }
    }

    var list: [RateDetail]
    var pageInfo: PageInfo

    enum CodingKeys: String, CodingKey {
        case list = "list"
        case pageInfo = "page_info"
    }
}

struct GetSeriesRateRequest: Codable, Sendable {
    var seriesId: UInt
    var page: UInt
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case seriesId = "sid"
        case page = "page"
        case securityKey = "security_key"
    }
}
