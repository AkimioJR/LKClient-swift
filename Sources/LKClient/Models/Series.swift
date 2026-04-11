//
//  Series.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/11/18.
//

import Foundation

public struct SeriesInfo: Codable, Sendable {
    public struct ArticleInfo: Codable, Sendable {
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

        public var order: UInt
        public var articleId: UInt
        public var title: String
        public var bannerURL: String
        public var coverURL: String
        // var hitCount: UInt
        // var commentCount: UInt
        public var coverType: CoverType
        public var createTime: Date
        public var updateTime: Date

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

    public struct UserRead: Codable, Sendable {
        public var lastArticleId: UInt

        enum CodingKeys: String, CodingKey {
            case lastArticleId = "last_aid"
        }
    }

    static public let `default` = SeriesInfo(
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

    public var seriesId: UInt
    public var seriesName: String
    public var groupId: GroupId
    public var author: String  // 作者（并非发布集合的作者）
    public var intro: String  // 简介
    public var bannerURL: String
    public var rate: UInt  // 0～5
    public var coverURL: String
    public var coverType: CoverType
    public var rateCount: UInt  // 评分人数
    public var updateTime: Date
    public var hitCount: UInt
    public var likeCount: UInt
    public var editors: [UserInfo]
    public var score: Float64  // 0～10
    // var characters: [Any] // 未知数据结构
    public var articles: [ArticleInfo]

    // 用户对集合的个人信息
    @LKBool public var alreadyFavavorite: Bool?  // 是否已收藏
    @LKBool public var alreadyRate: Bool?  // 是否已经评分
    @LKBool public var alreadyLike: Bool?  // 是否已点赞
    public var userRead: UserRead?  // 用户阅读进度

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

struct FetchSeriesRequest: Codable, Sendable {
    var seriesId: UInt
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case seriesId = "sid"
        case securityKey = "security_key"
    }
}

public struct SeriesRateInfo: Codable, Sendable {
    public var userId: UInt
    public var rate: UInt
    public var text: String
    public var time: Date
    public var score: UInt
    public var likeCount: UInt
    public var userInfo: UserProfileDetail
    // @LKBool var alreadyLike: Bool

    public init(
        userId: UInt, rate: UInt, text: String, time: Date, score: UInt, likeCount: UInt,
        userInfo: UserProfileDetail
    ) {
        self.userId = userId
        self.rate = rate
        self.text = text
        self.time = time
        self.score = score
        self.likeCount = likeCount
        self.userInfo = userInfo
    }

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
struct FetchSeriesRateRequest: Codable, Sendable {
    var seriesId: UInt
    var page: UInt
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case seriesId = "sid"
        case page = "page"
        case securityKey = "security_key"
    }
}

/// MARK: - 集合相关

extension LKClient {
    /// 查询集合信息
    public func fetchSeries(seriesId: UInt) async throws(LKError) -> SeriesInfo {
        self.logger.debug("正在查询集合信息，seriesId: \(seriesId)")
        let req = await FetchSeriesRequest(seriesId: seriesId, securityKey: self.securityKey)
        return try await self.sendRequest(
            path: "/api/series/get-info",
            requestData: req,
        )
    }

    /// 查询集合评价
    public func fetchSeriesRatings(seriesId: UInt, page: UInt) async throws(LKError)
        -> Page<SeriesRateInfo>
    {
        self.logger.debug("正在查询集合评价，seriesId: \(seriesId), page: \(page)")
        let req = await FetchSeriesRateRequest(
            seriesId: seriesId, page: page, securityKey: self.securityKey)
        return try await self.sendRequest(
            path: "/api/series/get-rate-list",
            requestData: req,
        )
    }
}
