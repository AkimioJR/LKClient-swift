//
//  Article.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/11/11.
//

import Foundation

public struct ArticleDetail: Codable, Sendable {
    public struct PayInfo: Codable, Sendable {
        // 文章支付类型
        public enum PriceType: UInt, Codable, Sendable {
            case coin = 0  // 投币支付
        }

        var userId: UInt  // 支付给谁
        var priceType: PriceType  // 支付类型
        var price: UInt  // 价格
        @LKBool var alreadyPay: Bool  // 是否已经支付

        enum CodingKeys: String, CodingKey {
            case userId = "uid"
            case priceType = "price_type"
            case price = "price"
            case alreadyPay = "is_paid"
        }
    }
    public struct Resource: Codable, Sendable {
        public struct Info: Codable, Sendable {
            public var resourceId: UInt
            public var width: UInt
            public var height: UInt
            public var ext: String
            public var filename: String
            public var url: String

            enum CodingKeys: String, CodingKey {
                case resourceId = "resid"
                case width = "width"
                case height = "height"
                case ext = "ext"
                case filename = "filename"
                case url = "url"
            }
        }

        public var ids: [String]
        public var info: [String: Info]

        enum CodingKeys: String, CodingKey {
            case ids = "ids"
            case info = "res_info"
        }

        // 有时候 res_info 的空响应是一个list
        // "res":{"ids":["2,661","2,662"],"res_info":[]}
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.ids = (try? container.decode([String].self, forKey: .ids)) ?? []

            if let dict = try? container.decode(
                [String: Info].self, forKey: .info)
            {
                self.info = dict
                return
            }

            if let arr = try? container.decode([Info].self, forKey: .info) {
                if arr.isEmpty {
                    self.info = [:]
                    return
                }
            }

            throw DecodingError.typeMismatch(
                [String: Info].self,
                DecodingError.Context(
                    codingPath: [CodingKeys.info],
                    debugDescription: "Expected dictionary or empty array for res_info"
                )
            )
        }
    }

    static public let `default` = ArticleDetail(
        articleId: 0,
        userId: 0,
        title: "",
        summary: "",
        hitCount: 0,
        likeCount: 0,
        coinCount: 0,
        favoriteCount: 0,
        commentCount: 0,
        shareCount: 0,
        createTime: Date(timeIntervalSince1970: 0),
        hasPoll: false,
        bannerURL: "",
        updateTime: Date(timeIntervalSince1970: 0),
        onlyPasser: false,
        coverURL: "",
        lt: Date(timeIntervalSince1970: 0),
        groupId: .all,
        seriesId: 0,
        author: .default,
        cacheVersion: 0,
        onlyApp: false,
    )

    public var articleId: UInt
    public var userId: UInt
    public var title: String
    public var summary: String
    public var hitCount: UInt
    public var likeCount: UInt
    public var coinCount: UInt
    public var favoriteCount: UInt
    public var commentCount: UInt
    public var shareCount: UInt
    public var createTime: Date
    @LKBool public var hasPoll: Bool
    public var bannerURL: String
    public var updateTime: Date
    @LKBool public var onlyPasser: Bool
    public var coverURL: String
    public var lt: Date
    public var groupId: GroupId
    public var seriesId: UInt
    public var author: UserProfileDetail
    // var otherRecoms: [] // 未知
    public var cacheVersion: UInt
    @LKBool public var onlyApp: Bool
    public var alreadyCoinCount: UInt?  // 已经投币数
    @LKBool public var alreadyLike: Bool?  // 是否已点赞
    @LKBool public var alreadyFavavorite: Bool?  // 是否已收藏
    @LKBool public var alreadyFollow: Bool?  // 是否已关注作者

    public var content: String?  // 需要simple为false
    public var resource: Resource?  // 漫画文章可能没有这一项
    public var payInfo: PayInfo?  // 支付信息，未支付文章才有

    public init(
        articleId: UInt, userId: UInt, title: String, summary: String, hitCount: UInt,
        likeCount: UInt, coinCount: UInt, favoriteCount: UInt, commentCount: UInt, shareCount: UInt,
        createTime: Date, hasPoll: Bool, bannerURL: String, updateTime: Date, onlyPasser: Bool,
        coverURL: String, lt: Date, groupId: GroupId, seriesId: UInt, author: UserProfileDetail,
        cacheVersion: UInt, onlyApp: Bool, alreadyCoinCount: UInt? = nil, alreadyLike: Bool? = nil,
        alreadyFavavorite: Bool? = nil, alreadyFollow: Bool? = nil, content: String? = nil,
        resource: Resource? = nil, payInfo: PayInfo? = nil
    ) {
        self.articleId = articleId
        self.userId = userId
        self.title = title
        self.summary = summary
        self.hitCount = hitCount
        self.likeCount = likeCount
        self.coinCount = coinCount
        self.favoriteCount = favoriteCount
        self.commentCount = commentCount
        self.shareCount = shareCount
        self.createTime = createTime
        self.hasPoll = hasPoll
        self.bannerURL = bannerURL
        self.updateTime = updateTime
        self.onlyPasser = onlyPasser
        self.coverURL = coverURL
        self.lt = lt
        self.groupId = groupId
        self.seriesId = seriesId
        self.author = author
        self.cacheVersion = cacheVersion
        self.onlyApp = onlyApp
        self.alreadyCoinCount = alreadyCoinCount
        self.alreadyLike = alreadyLike
        self.alreadyFavavorite = alreadyFavavorite
        self.alreadyFollow = alreadyFollow
        self.content = content
        self.resource = resource
        self.payInfo = payInfo
    }

    enum CodingKeys: String, CodingKey {
        case articleId = "aid"
        case userId = "uid"
        case title = "title"
        case summary = "summary"
        case content = "content"
        case hitCount = "hits"
        case likeCount = "likes"
        case coinCount = "coins"
        case commentCount = "comments"
        case favoriteCount = "favorites"
        case shareCount = "shares"
        case createTime = "time"
        case hasPoll = "has_poll"
        case bannerURL = "banner"
        case onlyPasser = "only_passer"
        case coverURL = "cover"
        case updateTime = "last_time"
        case lt = "lt"
        case groupId = "gid"
        case seriesId = "sid"
        case author = "author"
        case resource = "res"
        case cacheVersion = "cache_ver"
        case onlyApp = "only_app"
        case alreadyCoinCount = "already_coin"
        case alreadyLike = "already_like"
        case alreadyFavavorite = "already_fav"
        case alreadyFollow = "already_follow"
        case payInfo = "pay_info"
    }
}

struct FetchArticleDetailRequest: Codable, Sendable {
    var securityKey: String
    var articleId: UInt
    @LKBool var simple: Bool

    enum CodingKeys: String, CodingKey {
        case articleId = "aid"
        case securityKey = "security_key"
        case simple = "simple"
    }
}

public struct ArticleTag: Codable, Sendable {
    public var tagId: UInt
    public var word: String
    public var contentType: String
    public var weight: UInt
    public var isClickable: Bool

    enum CodingKeys: String, CodingKey {
        case tagId = "id"
        case word = "word"
        case contentType = "content_type"
        case weight = "weight"
        case isClickable = "is_clickable"
    }
}

struct ArticleRequest: Codable, Sendable {
    public var securityKey: String
    public var articleId: UInt

    enum CodingKeys: String, CodingKey {
        case articleId = "aid"
        case securityKey = "security_key"
    }
}

/// MARK: - 文章相关
extension LKClient {
    /// 获取文章详情
    public func fetchArticleDetail(articleId: UInt, includeContent: Bool) async throws
        -> ArticleDetail
    {
        self.logger.debug(
            "正在获取文章详情，articleId: \(articleId), includeContent: \(includeContent)"
        )
        let req = FetchArticleDetailRequest(
            securityKey: await self.securityKey,
            articleId: articleId,
            simple: !includeContent,
        )

        return try await self.sendRequest(
            path: "/api/article/get-detail",
            requestData: req,
        )
    }

    /// 获取文章 tag
    public func fetchArticleTags(articleId: UInt) async throws(LKError) -> [ArticleTag] {
        self.logger.debug("正在获取文章标签，articleId: \(articleId)")
        let req = ArticleRequest(securityKey: await self.securityKey, articleId: articleId)
        return try await self.sendRequest(
            path: "/api/tag/get-article-tags",
            requestData: req,
        )
    }

    /// 点赞文章
    public func likeArticle(articleId: UInt) async throws {
        self.logger.debug("正在点赞文章，articleId: \(articleId)")
        let req = ArticleRequest(securityKey: await self.securityKey, articleId: articleId)
        try await self.sendRequest(
            path: "/api/article/like",
            requestData: req,
        )
    }
}
