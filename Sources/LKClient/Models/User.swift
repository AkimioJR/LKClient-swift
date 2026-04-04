//
//  User.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/11/9.
//

import Foundation

public enum GenderType: UInt8, Codable, Hashable, Sendable {
    case unknown = 0
    case male = 1
    case female = 2
}

struct LevelInfo: Codable, Hashable, Sendable {
    static let `default` = LevelInfo(experience: 0, level: .commoner)

    var experience: UInt
    var level: Level
    // var name: String

    // var nextExperience: UInt?

    enum CodingKeys: String, CodingKey {
        case experience = "exp"
        case level = "level"
        // case name = "name"
        // case nextExperience = "next_exp"
    }
}

struct Medal: Codable, Hashable, Sendable {
    var medalId: UInt
    var name: String
    var desc: String
    var medalsType: UInt

    @LKBool var equip: Bool?  // 是否装备？
    var expiration: Date?  // 过期时间，可能为"0000-00-00 00:00:00"
    var imgURL: String?

    enum CodingKeys: String, CodingKey {
        case medalId = "medal_id"
        case name = "name"
        case desc = "desc"
        case medalsType = "type"
        case equip = "equip"
        case expiration = "expiration"
        case imgURL = "img"
    }
}

struct UserBalance: Codable, Hashable, Sendable {
    var coin: UInt
    var balance: UInt

    enum CodingKeys: String, CodingKey {
        case coin = "coin"
        case balance = "balance"
    }
}

/// 基础用户信息
/// 搜索接口、集合创作者、集合记录返回的用户列表使用这个结构体
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
        followingCount: 0,
        commentCount: 0,
        favoriteCount: 0,
        articleCount: 0,
        followerCount: 0,
        medals: [],
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

    var followingCount: UInt
    var commentCount: UInt
    var favoriteCount: UInt
    var articleCount: UInt
    var followerCount: UInt
    var medals: [Medal]

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

public struct UserProfileDetail: Codable, Hashable, Sendable {
    static let `default` = UserProfileDetail(
        userId: 0,
        nickName: "",
        avatarURL: "",
        passer: false,
        gender: .unknown,
        sign: "",
        status: false,
        bannerURL: "",
        banEndDate: Date(timeIntervalSince1970: 0),
        followingCount: 0,
        articleCount: 0,
        followerCount: 0,
        levelInfo: .default,
    )

    var userId: UInt
    var nickName: String
    var avatarURL: String  // Avatar image URL
    @LKBool var passer: Bool
    var gender: GenderType
    var sign: String
    @LKBool var status: Bool
    var bannerURL: String  // Banner image URL
    var banEndDate: Date  // Date when ban ends
    var medals: [Medal]?  // 搜索结果中获取到的 UserProfileDetail 没有该字段
    var followingCount: UInt  // Number of users this user is following
    var articleCount: UInt
    var followerCount: UInt  // 粉丝数
    var levelInfo: LevelInfo

    // 文章详情获取到的 UserProfileDetail 没有以下字段
    var favoriteCount: UInt?
    // var allLevels: [LevelInfo]?

    // 仅能看到自己的信息
    var commentCount: UInt?
    var balance: UserBalance?
    var securityKey: String?  // 仅在登录用户时返回

    // 仅他人信息
    @LKBool var alreadyFollow: Bool?  // 是否关注
    @LKBool var alreadyBlock: Bool?  // 是否拉黑

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
        case medals = "medals"
        case followingCount = "following"
        case favoriteCount = "favorites"
        case articleCount = "articles"
        case followerCount = "followers"
        case levelInfo = "level"
        case commentCount = "comments"
        case balance = "balance"
        // case allLevels = "all_level"
        case securityKey = "security_key"
        case alreadyFollow = "followed"
        case alreadyBlock = "blocked"
    }
}

extension UserProfileDetail {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.userId = try container.decodeIfPresent(UInt.self, forKey: .userId) ?? 0

        if let nickname = try? container.decode(String.self, forKey: .nickName) {
            self.nickName = nickname
        } else if let nicknameUInt = try? container.decode(UInt.self, forKey: .nickName) {
            self.nickName = String(nicknameUInt)
        } else if let nicknameInt = try? container.decode(Int.self, forKey: .nickName) {
            self.nickName = String(nicknameInt)
        } else {
            self.nickName = ""
        }

        self.avatarURL = try container.decodeIfPresent(String.self, forKey: .avatarURL) ?? ""
        self._passer = try container.decode(LKBool<Bool>.self, forKey: .passer)
        self.gender = try container.decodeIfPresent(GenderType.self, forKey: .gender) ?? .unknown
        self.sign = try container.decodeIfPresent(String.self, forKey: .sign) ?? ""
        self._status = try container.decode(LKBool<Bool>.self, forKey: .status)
        self.bannerURL = try container.decodeIfPresent(String.self, forKey: .bannerURL) ?? ""
        self.banEndDate =
            try container.decodeIfPresent(Date.self, forKey: .banEndDate)
            ?? Date(timeIntervalSince1970: 0)
        self.medals = try container.decodeIfPresent([Medal].self, forKey: .medals)
        self.followingCount = try container.decodeIfPresent(UInt.self, forKey: .followingCount) ?? 0
        self.articleCount = try container.decodeIfPresent(UInt.self, forKey: .articleCount) ?? 0
        self.followerCount = try container.decodeIfPresent(UInt.self, forKey: .followerCount) ?? 0
        self.levelInfo =
            try container.decodeIfPresent(LevelInfo.self, forKey: .levelInfo) ?? .default

        self.favoriteCount = try container.decodeIfPresent(UInt.self, forKey: .favoriteCount)
        self.commentCount = try container.decodeIfPresent(UInt.self, forKey: .commentCount)
        self.balance = try container.decodeIfPresent(UserBalance.self, forKey: .balance)
        self.securityKey = try container.decodeIfPresent(String.self, forKey: .securityKey)
        self._alreadyFollow = try container.decode(LKBool<Bool?>.self, forKey: .alreadyFollow)
        self._alreadyBlock = try container.decode(LKBool<Bool?>.self, forKey: .alreadyBlock)
    }
}

struct LoginRequest: Codable, Sendable {
    var username: String
    var password: String

    enum CodingKeys: String, CodingKey {
        case username = "username"
        case password = "password"
    }
}

struct GetUserInfoRequest: Codable, Sendable {
    var userId: UInt
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case userId = "uid"
        case securityKey = "security_key"
    }
}

struct FollowRequest: Codable, Sendable {
    var userId: UInt
    @LKBool var unFollow: Bool  // false表示关注，true表示取关
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case userId = "uid"
        case unFollow = "act"
        case securityKey = "security_key"
    }
}

public struct UserArticle: Codable, Sendable {
    struct ArticleInfo: Codable {
        var articleId: UInt
        var bannerURL: String
        var commentCount: UInt
        var groupId: GroupId
        var hitCount: UInt
        var createTime: Date
        var title: String
        var userId: UInt
        var coverURL: String
        var coverType: CoverType
        var seriesId: UInt
        var coinCount: UInt
        @LKBool var empty: Bool?

        enum CodingKeys: String, CodingKey {
            case articleId = "aid"
            case bannerURL = "banner"
            case commentCount = "comments"
            case groupId = "gid"
            case hitCount = "hits"
            case createTime = "time"
            case title = "title"
            case userId = "uid"
            case coverURL = "cover"
            case coverType = "cover_type"
            case seriesId = "sid"
            case coinCount = "coins"
            case empty = "empty"
        }
    }

    var list: [ArticleInfo]
    var pageInfo: PageInfo

    enum CodingKeys: String, CodingKey {
        case list = "list"
        case pageInfo = "page_info"
    }
}

struct GetUserArticleRequest: Codable, Sendable {
    var userId: UInt
    var articleType: ArticleType
    let classType: UInt = 1
    var page: UInt
    var pageSize: UInt
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case userId = "uid"
        case articleType = "type"
        case classType = "class"
        case page = "page"
        case pageSize = "page_size"
        case securityKey = "security_key"
    }
}
