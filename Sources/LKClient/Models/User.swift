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

public struct LevelInfo: Codable, Hashable, Sendable {
    static let `default` = LevelInfo(experience: 0, level: .commoner)

    public init(experience: UInt, level: Level) {
        self.experience = experience
        self.level = level
    }

    public var experience: UInt
    public var level: Level
    // var name: String

    // var nextExperience: UInt?

    enum CodingKeys: String, CodingKey {
        case experience = "exp"
        case level = "level"
        // case name = "name"
        // case nextExperience = "next_exp"
    }
}

public struct Medal: Codable, Hashable, Sendable {
    public var medalId: UInt
    public var name: String
    public var desc: String
    public var medalsType: UInt

    @LKBool public var equip: Bool?  // 是否装备？
    public var expiration: Date?  // 过期时间，可能为"0000-00-00 00:00:00"
    public var imgURL: String?

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.medalId = try container.decode(UInt.self, forKey: .medalId)
        self.name = try container.decode(String.self, forKey: .name)
        self.desc = try container.decode(String.self, forKey: .desc)
        self.medalsType = try container.decode(UInt.self, forKey: .medalsType)
        self._equip = try container.decode(LKBool<Bool?>.self, forKey: .equip)
        self.expiration = try container.decodeIfPresent(Date.self, forKey: .expiration)
        self.imgURL = try container.decodeIfPresent(String.self, forKey: .imgURL)
    }
    public init(
        medalId: UInt, name: String, desc: String, medalsType: UInt, equip: Bool? = nil,
        expiration: Date? = nil, imgURL: String? = nil
    ) {
        self.medalId = medalId
        self.name = name
        self.desc = desc
        self.medalsType = medalsType
        self.equip = equip
        self.expiration = expiration
        self.imgURL = imgURL
    }

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

public struct UserBalance: Codable, Hashable, Sendable {
    public var coin: UInt
    public var balance: UInt

    enum CodingKeys: String, CodingKey {
        case coin = "coin"
        case balance = "balance"
    }
}

/// 基础用户信息
/// 搜索接口、集合创作者返回的用户列表使用这个结构体
public struct UserInfo: Codable, Sendable {
    static public let `default` = UserInfo(
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

    public init(
        userId: UInt, nickName: String, avatarURL: String, passer: Bool, gender: GenderType,
        sign: String, status: Bool, bannerURL: String, banEndDate: Date, levelInfo: LevelInfo,
        followingCount: UInt, commentCount: UInt, favoriteCount: UInt, articleCount: UInt,
        followerCount: UInt, medals: [Medal]
    ) {
        self.userId = userId
        self.nickName = nickName
        self.avatarURL = avatarURL
        self.passer = passer
        self.gender = gender
        self.sign = sign
        self.status = status
        self.bannerURL = bannerURL
        self.banEndDate = banEndDate
        self.levelInfo = levelInfo
        self.followingCount = followingCount
        self.commentCount = commentCount
        self.favoriteCount = favoriteCount
        self.articleCount = articleCount
        self.followerCount = followerCount
        self.medals = medals
    }

    public var userId: UInt
    public var nickName: String
    public var avatarURL: String
    @LKBool public var passer: Bool
    public var gender: GenderType
    public var sign: String
    @LKBool public var status: Bool
    public var bannerURL: String
    public var banEndDate: Date
    public var levelInfo: LevelInfo

    public var followingCount: UInt
    public var commentCount: UInt
    public var favoriteCount: UInt
    public var articleCount: UInt
    public var followerCount: UInt
    public var medals: [Medal]

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
    static public let `default` = UserProfileDetail(
        userId: 0,
        nickName: "",
        avatarURL: "",
        passer: false,
        gender: .unknown,
        sign: "",
        status: false,
        bannerURL: "",
        banEndDate: Date(timeIntervalSince1970: 0),
        medals: nil,
        followingCount: 0,
        articleCount: 0,
        followerCount: 0,
        levelInfo: .default,
    )

    public var userId: UInt
    public var nickName: String
    public var avatarURL: String  // Avatar image URL
    @LKBool public var passer: Bool
    public var gender: GenderType
    public var sign: String
    @LKBool public var status: Bool
    public var bannerURL: String  // Banner image URL
    public var banEndDate: Date  // Date when ban ends
    public var medals: [Medal]?  // 搜索结果中获取到的 UserProfileDetail 没有该字段
    public var followingCount: UInt  // Number of users this user is following
    public var articleCount: UInt
    public var followerCount: UInt  // 粉丝数
    public var levelInfo: LevelInfo

    // 文章详情获取到的 UserProfileDetail 没有以下字段
    public var favoriteCount: UInt?
    // var allLevels: [LevelInfo]?

    // 仅能看到自己的信息
    public var commentCount: UInt?
    public var balance: UserBalance?
    public var securityKey: String?  // 仅在登录用户时返回

    // 仅他人信息
    @LKBool public var alreadyFollow: Bool?  // 是否关注
    @LKBool public var alreadyBlock: Bool?  // 是否拉黑

    public init(
        userId: UInt, nickName: String, avatarURL: String, passer: Bool, gender: GenderType,
        sign: String, status: Bool, bannerURL: String, banEndDate: Date, medals: [Medal]? = nil,
        followingCount: UInt, articleCount: UInt, followerCount: UInt, levelInfo: LevelInfo,
        favoriteCount: UInt? = nil, commentCount: UInt? = nil, balance: UserBalance? = nil,
        securityKey: String? = nil, alreadyFollow: Bool? = nil, alreadyBlock: Bool? = nil
    ) {
        self.userId = userId
        self.nickName = nickName
        self.avatarURL = avatarURL
        self.passer = passer
        self.gender = gender
        self.sign = sign
        self.status = status
        self.bannerURL = bannerURL
        self.banEndDate = banEndDate
        self.medals = medals
        self.followingCount = followingCount
        self.articleCount = articleCount
        self.followerCount = followerCount
        self.levelInfo = levelInfo
        self.favoriteCount = favoriteCount
        self.commentCount = commentCount
        self.balance = balance
        self.securityKey = securityKey
        self.alreadyFollow = alreadyFollow
        self.alreadyBlock = alreadyBlock
    }

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
    public struct ArticleInfo: Codable, Sendable {
        public var articleId: UInt
        public var bannerURL: String
        public var commentCount: UInt
        public var groupId: GroupId
        public var hitCount: UInt
        public var createTime: Date
        public var title: String
        public var userId: UInt
        public var coverURL: String
        public var coverType: CoverType
        public var seriesId: UInt
        public var coinCount: UInt
        @LKBool public var empty: Bool?

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

    public var list: [ArticleInfo]
    public var pageInfo: PageInfo

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
