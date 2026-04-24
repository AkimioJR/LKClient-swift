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

    public var name: String {
        switch self {
        case .unknown: return "未知"
        case .male: return "男"
        case .female: return "女"
        }
    }
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
public struct UserInfo: Codable, Sendable, Hashable {
    static public let `default` = UserInfo(
        userId: 0,
        nickName: "",
        avatarURL: "",
        passer: false,
        gender: .unknown,
        sign: "",
        status: false,
        bannerURL: "",
        banEndDate: .invalidDate,
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
    @FlexibleString public var nickName: String
    public var avatarURL: String
    @LKBool public var passer: Bool
    public var gender: GenderType
    @FlexibleString public var sign: String
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

public struct UserProfileDTO: Codable, Hashable, Sendable {
    static public let `default` = UserProfileDTO(
        userId: 0,
        nickName: "",
        avatarURL: "",
        passer: false,
        gender: .unknown,
        sign: "",
        status: false,
        // bannerURL: "",
        banEndDate: .invalidDate,
        medals: [],
        followingCount: 0,
        articleCount: 0,
        followerCount: 0,
        levelInfo: .default,
    )

    public var userId: UInt
    @FlexibleString public var nickName: String
    public var avatarURL: String  // Avatar image URL
    @LKBool public var passer: Bool
    public var gender: GenderType
    @FlexibleString public var sign: String
    @LKBool public var status: Bool
    // public var bannerURL: String  // Banner image URL
    public var banEndDate: Date  // Date when ban ends
    public var medals: [Medal]
    public var followingCount: UInt  // Number of users this user is following
    public var articleCount: UInt
    public var followerCount: UInt  // 粉丝数
    public var levelInfo: LevelInfo

    // 文章详情获取到的 UserProfileDTO 没有以下字段
    public var favoriteCount: UInt?
    // var allLevels: [LevelInfo]?

    // 仅能看到自己的信息
    public var commentCount: UInt?
    public var balance: UserBalance?
    var securityKey: String?  // 仅在登录用户时返回

    // 仅他人信息
    @LKBool public var alreadyFollow: Bool?  // 是否关注
    @LKBool public var alreadyBlock: Bool?  // 是否拉黑

    public init(
        userId: UInt, nickName: String, avatarURL: String, passer: Bool, gender: GenderType,
        sign: String, status: Bool, banEndDate: Date, medals: [Medal] = [],
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
        // self.bannerURL = bannerURL
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
        // case bannerURL = "banner"
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

extension UserProfileDTO {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.userId = try container.decode(UInt.self, forKey: .userId)
        self._nickName = try container.decode(FlexibleString<String>.self, forKey: .nickName)
        self.avatarURL = try container.decode(String.self, forKey: .avatarURL)
        self._passer = try container.decode(LKBool<Bool>.self, forKey: .passer)
        self.gender = try container.decode(GenderType.self, forKey: .gender)
        self._sign = try container.decode(FlexibleString<String>.self, forKey: .sign)
        self._status = try container.decode(LKBool<Bool>.self, forKey: .status)
        // self.bannerURL = try container.decode(String.self, forKey: .bannerURL)
        self.banEndDate = try container.decode(Date.self, forKey: .banEndDate)
        self.medals = try container.decode([Medal].self, forKey: .medals)
        self.followingCount = try container.decode(UInt.self, forKey: .followingCount)
        self.articleCount = try container.decode(UInt.self, forKey: .articleCount)
        self.followerCount = try container.decode(UInt.self, forKey: .followerCount)
        self.levelInfo = try container.decode(LevelInfo.self, forKey: .levelInfo)
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

public struct UserArticleInfo: Codable, Sendable {
    public var articleId: UInt
    public var bannerURL: String
    // public var commentCount: UInt // 接口返回的全是 0
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
        // case commentCount = "comments"
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
struct FecthUserArticleRequest: Codable, Sendable {
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

extension LKClient {
    /// 登录客户端
    public func login(username: String, password: String, saveSecurityKey: Bool = true)
        async throws(LKError) -> (UserProfileDTO, String)
    {
        let loginRequest = LoginRequest(username: username, password: password)

        self.logger.debug("正在登录用户: \(username)")

        let loginResponse: UserProfileDTO = try await self.sendRequest(
            path: "/api/user/login",
            requestData: loginRequest,
        )

        guard let securityKey = loginResponse.securityKey else {
            throw .apiEmptyDataError
        }

        if saveSecurityKey {
            await self.setSecurityKey(securityKey)
        }

        return (loginResponse, securityKey)
    }

    /// 获取用户信息
    public func fetchUserInfo(userId: UInt) async throws(LKError) -> UserProfileDTO {
        let req = GetUserInfoRequest(
            userId: userId,
            securityKey: await self.securityKey,
        )
        self.logger.debug("正在获取用户信息，userId: \(userId)")
        return try await self.sendRequest(
            path: "/api/user/info",
            requestData: req,
        )
    }

    /// 关注/取消关注用户
    public func updateFollowStatus(userId: UInt, shouldFollow: Bool) async throws {
        self.logger.debug(
            "\(shouldFollow ? "关注" : "取消关注")用户(userId: \(userId))"
        )
        let req = FollowRequest(
            userId: userId, unFollow: !shouldFollow, securityKey: await self.securityKey)
        try await self.sendRequest(
            path: "/api/user/follow",
            requestData: req
        )
    }

    /// 获取用户的文章
    public func fetchUserArticles(
        userId: UInt, articleType: ArticleType, page: UInt, pageSize: UInt = 20
    ) async throws(LKError) -> Page<UserArticleInfo> {
        self.logger.debug(
            "正在获取用户(userId: \(userId))文章: articleType: \(articleType), page: \(page), pageSize: \(pageSize) "
        )

        let req = FecthUserArticleRequest(
            userId: userId,
            articleType: articleType,
            page: page,
            pageSize: pageSize,
            securityKey: await self.securityKey
        )
        return try await self.sendRequest(
            path: "/api/user/get-articles",
            requestData: req,
        )
    }
}
