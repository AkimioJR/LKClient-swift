//
//  Article.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/11/11.
//

import Foundation

public struct ArticleDetailDTO: Codable, Sendable {
    public struct PayInfo: Codable, Sendable, Equatable {
        // 文章支付类型
        public enum PriceType: UInt, Codable, Sendable {
            case coin = 0  // 投币支付
        }

        public var userId: UInt  // 支付给谁
        public var priceType: PriceType  // 支付类型
        public var price: UInt  // 价格
        @LKBool public var isPaid: Bool  // 是否已经支付

        enum CodingKeys: String, CodingKey {
            case userId = "uid"
            case priceType = "price_type"
            case price = "price"
            case isPaid = "is_paid"
        }
    }
    public struct Resource: Codable, Sendable {
        public struct Info: Codable, Sendable, Equatable {
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
    // public var lt: Date // 似乎和 updateTime 是重复字段
    public var groupId: GroupId
    public var seriesId: UInt
    public var author: UserInfoDTO
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
        // case lt = "lt"
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

struct FetchArticleDetailDTORequest: Codable, Sendable {
    var securityKey: String
    var articleId: UInt
    @LKBool var simple: Bool

    enum CodingKeys: String, CodingKey {
        case articleId = "aid"
        case securityKey = "security_key"
        case simple = "simple"
    }
}

public struct ArticleTagDTO: Codable, Sendable, Identifiable {
    public var id: UInt
    public var word: String
    public var contentType: String
    public var weight: UInt
    public var isClickable: Bool

    enum CodingKeys: String, CodingKey {
        case id = "id"
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
    public func fetchArticleDetail(_ articleId: UInt, includeContent: Bool) async throws
        -> ArticleDetailDTO
    {
        self.logger.debug(
            "正在获取文章详情，articleId: \(articleId), includeContent: \(includeContent)"
        )
        let req = FetchArticleDetailDTORequest(
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
    public func fetchArticleTags(_ articleId: UInt) async throws(LKError) -> [ArticleTagDTO] {
        self.logger.debug("正在获取文章标签，articleId: \(articleId)")
        let req = ArticleRequest(securityKey: await self.securityKey, articleId: articleId)
        return try await self.sendRequest(
            path: "/api/tag/get-article-tags",
            requestData: req,
        )
    }

    /// 点赞文章
    public func likeArticle(_ articleId: UInt) async throws {
        self.logger.debug("正在点赞文章，articleId: \(articleId)")
        let req = ArticleRequest(securityKey: await self.securityKey, articleId: articleId)
        try await self.sendRequest(
            path: "/api/article/like",
            requestData: req,
        )
    }
}
