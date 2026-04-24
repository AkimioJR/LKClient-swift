import Foundation

public struct UserBalance: Codable, Hashable, Sendable {
    public var coin: UInt
    public var balance: UInt

    enum CodingKeys: String, CodingKey {
        case coin = "coin"
        case balance = "balance"
    }
}

/// 基础用户信息，除了专门的用户信息接口外，其他接口中返回的用户信息都用这个结构体表示
///
/// **banner** 字段所有用户一致，全部舍弃
///
///  ### 🔴 高风险：必导致反序列化失败的字段缺失
///  #### 1. `/api/article/get-detail.data.author`
///  **缺失字段**：`comments`、`favorites`
///  你的模型中：
///  ```swift
///  public var commentCount: UInt    // 非可选，对应 JSON "comments"
///  public var favoriteCount: UInt   // 非可选，对应 JSON "favorites"
///  ```
///  该接口的 JSON 中**完全没有这两个 key**，会导致整个 `UserInfoDTO` 反序列化直接抛出错误。
///  #### 2. `/api/search/search-result.data.list.1.editors.1`（搜索集合里的编辑）
///  **缺失字段**：`comments`、`favorites`、`articles`、`followers`、`medals`
///  这是最精简的一个用户信息，除了基础信息外，统计数据和徽章数组**全部缺失**。
///  你的模型中：
///  ```swift
///  public var commentCount: UInt    // 缺失
///  public var favoriteCount: UInt   // 缺失
///  public var medals: [Medal]       // 缺失（非可选数组）
///  ```
///  同样会导致反序列化失败。
///
/// ### 🟡 零值情况（字段存在，值为 0，无风险）
/// 以下接口中虽然值为 0，但**字段完整存在**，可以正常反序列化到你的 `UInt` 类型：
/// - `/api/discuss/get-topic.data.list.1.user_info`: `comments: 0`, `favorites: 0`, `articles: 0`, `followers: 0`
/// - `/api/discuss/get-topic.data.list.1.reply_list.1.user_info`: `comments: 0`, `favorites: 0`
/// - `/api/series/get-info.data.editors.1`: `comments: 0`, `favorites: 0`
/// - `/api/series/get-rate-list.data.list.1.user_info`: `following: 0`, `comments: 0`, `favorites: 0`, `articles: 0`, `followers: 0`
/// - `/api/recom/get-follows.data.1.author`: `comments: 0`, `favorites: 0`
/// - `/api/search/search-result.data.list.1`（搜索用户）: `comments: 0`, `favorites: 0`
public struct UserInfoDTO: Codable, Sendable, Hashable {

    public var userId: UInt
    @FlexibleString public var nickname: String
    public var avatarURL: String
    @LKBool public var passer: Bool
    public var gender: GenderType
    @FlexibleString public var sign: String
    @LKBool public var isBanned: Bool
    // public var bannerURL: String
    public var banEndDate: Date
    public var level: UserProgress

    public var followingCount: UInt?
    public var followerCount: UInt?
    public var articleCount: UInt?

    public var medals: [MedalDTO] = []

    /// /api/user/info 接口中存在但数值始终为0，推测其他接口有数据但也始终为0
    // @NoMeaningOptional public var commentCount: UInt?
    // @NoMeaningOptional public var favoriteCount: UInt?

    enum CodingKeys: String, CodingKey {
        case userId = "uid"
        case nickname = "nickname"
        case avatarURL = "avatar"
        case passer = "passer"
        case gender = "gender"
        case sign = "sign"
        case isBanned = "status"
        // case bannerURL = "banner"
        case banEndDate = "ban_end_date"
        case level = "level"

        case followingCount = "following"
        case followerCount = "followers"
        case articleCount = "articles"

        case medals = "medals"

        // case commentCount = "comments"
        // case favoriteCount = "favorites"
    }

    public init(
        userId: UInt,
        nickname: String,
        avatarURL: String,
        passer: Bool,
        gender: GenderType,
        sign: String,
        isBanned: Bool,
        banEndDate: Date,
        level: UserProgress,
        followingCount: UInt? = nil,
        followerCount: UInt? = nil,
        articleCount: UInt? = nil,
        medals: [MedalDTO]
    ) {
        self.userId = userId
        self.nickname = nickname
        self.avatarURL = avatarURL
        self.passer = passer
        self.gender = gender
        self.sign = sign
        self.isBanned = isBanned
        self.banEndDate = banEndDate
        self.level = level
        self.followingCount = followingCount
        self.followerCount = followerCount
        self.articleCount = articleCount
        self.medals = medals
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(UInt.self, forKey: .userId)
        self._nickname = try container.decode(FlexibleString<String>.self, forKey: .nickname)
        self.avatarURL = try container.decode(String.self, forKey: .avatarURL)
        self._passer = try container.decode(LKBool<Bool>.self, forKey: .passer)
        self.gender = try container.decode(GenderType.self, forKey: .gender)
        self._sign = try container.decode(FlexibleString<String>.self, forKey: .sign)
        self._isBanned = try container.decode(LKBool<Bool>.self, forKey: .isBanned)
        self.banEndDate = try container.decode(Date.self, forKey: .banEndDate)
        self.level = try container.decode(UserProgress.self, forKey: .level)
        if let followingCount = try container.decodeIfPresent(UInt.self, forKey: .followingCount),
            followingCount != 0
        {
            self.followingCount = followingCount
        }
        if let followerCount = try container.decodeIfPresent(UInt.self, forKey: .followerCount),
            followerCount != 0
        {
            self.followerCount = followerCount
        }
        if let articleCount = try container.decodeIfPresent(UInt.self, forKey: .articleCount),
            articleCount != 0
        {
            self.articleCount = articleCount
        }
        self.medals = try container.decodeIfPresent([MedalDTO].self, forKey: .medals) ?? []
    }
}

/// 用户信息接口返回的完整用户信息结构体
/// 包含了 `UserInfoDTO` 中的所有字段，以及一些仅在用户信息接口中返回的字段
/// /api/user/info
public struct UserProfileDTO: Codable, Hashable, Sendable {
    public var userId: UInt
    @FlexibleString public var nickname: String
    public var avatarURL: String  // Avatar image URL
    @LKBool public var passer: Bool
    public var gender: GenderType
    @FlexibleString public var sign: String
    @LKBool public var isBanned: Bool
    // public var bannerURL: String  // Banner image URL
    public var banEndDate: Date  // Date when ban ends
    public var medals: [MedalDTO]
    public var followingCount: UInt  // 该用户关注其他用户的数量
    public var followerCount: UInt  // 粉丝数
    public var articleCount: UInt
    public var level: UserProgress

    // @NoMeaningOptional public var commentCount: UInt? 似乎始终为 0
    // @NoMeaningOptional public var favoriteCount: UInt? 似乎始终为 0

    // 仅能看到自己的信息
    public var balance: UserBalance?
    var securityKey: String?  // 仅在登录用户时返回

    // 仅他人信息
    @LKBool public var alreadyFollow: Bool?  // 是否关注
    @LKBool public var alreadyBlock: Bool?  // 是否拉黑

    enum CodingKeys: String, CodingKey {
        case userId = "uid"
        case nickname = "nickname"
        case avatarURL = "avatar"
        case passer = "passer"
        case gender = "gender"
        case sign = "sign"
        case isBanned = "status"
        // case bannerURL = "banner"
        case banEndDate = "ban_end_date"
        case medals = "medals"
        case followingCount = "following"
        case followerCount = "followers"
        case articleCount = "articles"
        case level = "level"

        // case commentCount = "comments"
        // case favoriteCount = "favorites"

        // case allLevels = "all_level" // 仅自己返回，但接口数据固定，暂不建模

        case balance = "balance"
        case securityKey = "security_key"

        case alreadyFollow = "followed"
        case alreadyBlock = "blocked"
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

struct FetchUserProfileDTORequest: Codable, Sendable {
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
    public func fetchUserProfile(_ userId: UInt) async throws(LKError) -> UserProfileDTO {
        let req = FetchUserProfileDTORequest(
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
    public func updateFollowStatus(_ userId: UInt, shouldFollow: Bool) async throws {
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
        _ userId: UInt,
        articleType: ArticleType,
        page: UInt,
        pageSize: UInt = 20
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
