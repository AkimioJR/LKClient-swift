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
        public struct ImageResource: Codable, Sendable {
            var resourceId: UInt
            var width: UInt
            var height: UInt
            var ext: String
            var filename: String
            var url: String

            enum CodingKeys: String, CodingKey {
                case resourceId = "resid"
                case width = "width"
                case height = "height"
                case ext = "ext"
                case filename = "filename"
                case url = "url"
            }
        }

        var ids: [String]
        var info: [String: ImageResource]

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
                [String: ImageResource].self, forKey: .info)
            {
                self.info = dict
                return
            }

            if let arr = try? container.decode([ImageResource].self, forKey: .info) {
                if arr.isEmpty {
                    self.info = [:]
                    return
                }
            }

            throw DecodingError.typeMismatch(
                [String: ImageResource].self,
                DecodingError.Context(
                    codingPath: [CodingKeys.info],
                    debugDescription: "Expected dictionary or empty array for res_info"
                )
            )
        }
    }

    static let `default` = ArticleDetail(
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

    var articleId: UInt
    var userId: UInt
    var title: String
    var summary: String
    var hitCount: UInt
    var likeCount: UInt
    var coinCount: UInt
    var favoriteCount: UInt
    var commentCount: UInt
    var shareCount: UInt
    var createTime: Date
    @LKBool var hasPoll: Bool
    var bannerURL: String
    var updateTime: Date
    @LKBool var onlyPasser: Bool
    var coverURL: String
    var lt: Date
    var groupId: GroupId
    var seriesId: UInt
    var author: UserProfileDetail
    // var otherRecoms: [] // 未知
    var cacheVersion: UInt
    @LKBool var onlyApp: Bool
    var alreadyCoinCount: UInt?  // 已经投币数
    @LKBool var alreadyLike: Bool?  // 是否已点赞
    @LKBool var alreadyFavavorite: Bool?  // 是否已收藏
    @LKBool var alreadyFollow: Bool?  // 是否已关注作者

    var content: String?  // 需要simple为false
    var resource: Resource?  // 漫画文章可能没有这一项
    var payInfo: PayInfo?  // 支付信息，未支付文章才有

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

struct GetArticleDetailRequest: Codable, Sendable {
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
    var tagId: UInt
    var word: String
    var contentType: String
    var weight: UInt
    var isClickable: Bool

    enum CodingKeys: String, CodingKey {
        case tagId = "id"
        case word = "word"
        case contentType = "content_type"
        case weight = "weight"
        case isClickable = "is_clickable"
    }
}

struct ArticleRequest: Codable, Sendable {
    var securityKey: String
    var articleId: UInt

    enum CodingKeys: String, CodingKey {
        case articleId = "aid"
        case securityKey = "security_key"
    }
}
