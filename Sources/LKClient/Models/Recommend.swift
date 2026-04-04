//
//  Recommend.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/11/9.
//
import Foundation

public struct RecommendGroup: Codable, Sendable {
    var type: GroupType
    var itemType: ItemType
    var rows: UInt
    var columns: UInt
    var more: String
    var moreType: MoreType
    var moreParams: UInt
    var items: [Item]

    enum GroupType: UInt8, Codable, CustomStringConvertible {
        case banner = 1  // 推荐置顶横幅
        case hot = 2  // 热门
        case news = 3  // 资讯
        case anime = 6  // 动画
        case manga = 7  // 漫画
        case other = 8  // 其他
        case lightnovel = 9  // 轻小说

        var description: String {
            switch self {
            case .banner:
                return "推荐置顶横幅"
            case .hot:
                return "热门"
            case .news:
                return "资讯"
            case .anime:
                return "动画"
            case .manga:
                return "漫画"
            case .other:
                return "其他"
            case .lightnovel:
                return "轻小说"
            }
        }
    }

    enum ItemType: UInt8, Codable, Sendable {
        case banner = 1  // 置顶横幅
        case normal = 2  // 普通内容
    }

    enum MoreType: UInt8, Codable, Sendable {
        case noMore = 0  // 没有更多内容
        case parentGroup = 1  // moreParams 是 parentGroupId
    }

    // 自定义解码
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.type = try container.decode(GroupType.self, forKey: .type)
        self.itemType = try container.decode(ItemType.self, forKey: .itemType)
        self.rows = try container.decode(UInt.self, forKey: .rows)
        self.columns = try container.decode(UInt.self, forKey: .columns)
        self.more = try container.decode(String.self, forKey: .more)
        self.moreType = try container.decode(MoreType.self, forKey: .moreType)
        self.items = try container.decode([Item].self, forKey: .items)

        // 根据 moreType 解析 moreParams
        if self.moreType == .parentGroup {
            self.moreParams = try container.decode(UInt.self, forKey: .moreParams)
        } else {
            self.moreParams = 0
        }
    }

    init(
        type: GroupType, itemType: ItemType, rows: UInt, columns: UInt, more: String,
        moreType: MoreType, moreParams: UInt, items: [Item]
    ) {
        self.type = type
        self.itemType = itemType
        self.rows = rows
        self.columns = columns
        self.more = more
        self.moreType = moreType
        self.moreParams = moreParams
        self.items = items
    }

    public struct Item: Codable, Identifiable, Sendable {
        public var id: UInt
        var type: UInt
        var title: String
        var actionType: ClassType
        var actionParams: UInt
        var pictureUrl: String
        var commentCount: UInt
        var hitCount: UInt

        // 当 actionType 为 .acticle 或者 .series 时有这些数据
        var groupId: GroupId?

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.id = try container.decode(UInt.self, forKey: RecommendGroup.Item.CodingKeys.id)
            self.type = try container.decode(UInt.self, forKey: RecommendGroup.Item.CodingKeys.type)
            self.title = try container.decode(
                String.self, forKey: RecommendGroup.Item.CodingKeys.title)
            self.actionType = try container.decode(
                ClassType.self, forKey: RecommendGroup.Item.CodingKeys.actionType)
            switch self.actionType {
            case .article, .series:
                self.actionParams = try container.decode(
                    UInt.self, forKey: RecommendGroup.Item.CodingKeys.actionParams)
            case .themereply:
                // 先尝试解析为 UInt
                if let id = try? container.decode(
                    UInt.self, forKey: RecommendGroup.Item.CodingKeys.actionParams)
                {
                    self.actionParams = id
                } else {
                    // 否则尝试解析为 URL 字符串并提取 ID
                    // https://www.lightnovel.fun/cn/themereply/1142391
                    let urlStr = try container.decode(
                        String.self, forKey: RecommendGroup.Item.CodingKeys.actionParams)
                    guard let lastComponent = urlStr.components(separatedBy: "/").last,
                        let id = UInt(lastComponent)
                    else {
                        throw DecodingError.dataCorruptedError(
                            forKey: .actionParams,
                            in: container,
                            debugDescription: "Cannot extract a valid ID from \(urlStr)"
                        )
                    }
                    self.actionParams = id
                }
            }

            self.pictureUrl = try container.decode(
                String.self, forKey: RecommendGroup.Item.CodingKeys.pictureUrl)
            self.groupId = try container.decodeIfPresent(
                GroupId.self, forKey: RecommendGroup.Item.CodingKeys.groupId)
            self.commentCount = try container.decode(
                UInt.self, forKey: RecommendGroup.Item.CodingKeys.commentCount)
            self.hitCount = try container.decode(
                UInt.self, forKey: RecommendGroup.Item.CodingKeys.hitCount)
        }

        init(
            id: UInt, type: UInt, title: String, actionType: ClassType, actionParams: UInt,
            pictureUrl: String, commentCount: UInt, hitCount: UInt, groupId: GroupId? = nil
        ) {
            self.id = id
            self.type = type
            self.title = title
            self.actionType = actionType
            self.actionParams = actionParams
            self.pictureUrl = pictureUrl
            self.commentCount = commentCount
            self.hitCount = hitCount
            self.groupId = groupId
        }

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case type = "type"
            case title = "title"
            case actionType = "action_type"
            case actionParams = "action_params"
            case pictureUrl = "pic_url"
            case groupId = "gid"
            case commentCount = "comments"
            case hitCount = "hits"
        }
    }

    enum CodingKeys: String, CodingKey {
        case type = "gid"
        case itemType = "type"
        case rows = "rows"
        case columns = "columns"
        case more = "more"
        case moreType = "more_type"
        case moreParams = "more_params"
        case items = "items"
    }
}

struct GetRecommendRequest: Codable, Sendable {
    var securityKey: String
    var classId: UInt

    enum CodingKeys: String, CodingKey {
        case securityKey = "security_key"
        case classId = "class"
    }
}

public struct FollowingArticle: Codable, Hashable, Sendable {
    var acticleId: UInt
    var seriesId: UInt
    var title: String
    var bannerURL: String
    var userId: UInt
    var hitCount: UInt
    var commentCount: UInt
    var createTime: Date
    var updateTime: Date
    var shareCount: UInt
    var favoriteCount: UInt
    var coinCount: UInt
    var likeCount: UInt
    var coverURL: String
    var coverType: CoverType
    var groupId: GroupId
    //var parentGroupId: ParentGroupId
    var author: UserProfileDetail
    var seriesName: String?

    enum CodingKeys: String, CodingKey {
        case acticleId = "aid"
        case seriesId = "sid"
        case title = "title"
        case bannerURL = "banner"
        case userId = "uid"
        case hitCount = "hits"
        case commentCount = "comments"
        case createTime = "time"
        case updateTime = "last_time"
        case shareCount = "shares"
        case favoriteCount = "favorites"
        case coinCount = "coins"
        case likeCount = "likes"
        case coverURL = "cover"
        case coverType = "cover_type"
        case groupId = "gid"
        //case parentGroupId = "parent_gid"
        case author = "author"
        case seriesName = "series_name"
    }
}

struct GetFollowingArticlesRequest: Codable, Sendable {
    var page: UInt
    var pageSize: UInt
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case page = "page"
        case pageSize = "page_size"
        case securityKey = "security_key"
    }
}
