//
//  Category.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/11/11.
//

import Foundation

public struct ArticleInfoDTO: Codable, Sendable {
    public var articleId: UInt
    public var title: String
    public var coverURL: String
    public var bannerURL: String
    public var seriesId: UInt
    public var seriesName: String?  // 非集合文章值为nil
    public var hitCount: UInt
    public var commentCount: UInt
    public var userId: UInt
    @FlexibleString public var author: String?  // 某些文章可能没有 author（如系列文章）
    public var avatarURL: String?  // 某些文章可能没有 avatar
    public var createTime: Date  // 文章创建时间
    public var updateTime: Date  // 最后更新时间
    public var groupId: GroupId?  // 某些文章可能没有 groupId（如系列文章）

    public var coverType: CoverType?  // 某些文章可能没有 coverType
    @LKBool public var isTop: Bool?  // 是否是置顶

    enum CodingKeys: String, CodingKey, Sendable {
        case articleId = "aid"
        case title = "title"
        case coverURL = "cover"
        case bannerURL = "banner"
        case seriesId = "sid"
        case seriesName = "series_name"
        case hitCount = "hits"
        case commentCount = "comments"
        case userId = "uid"
        case author = "author"
        case avatarURL = "avatar"
        case createTime = "time"
        case updateTime = "last_time"
        case groupId = "gid"
        case coverType = "cover_type"
        case isTop = "is_top"
    }
}

struct FetchCategoryArticlesInfoRequest: Codable, Sendable {
    var securityKey: String
    var groupId: GroupId
    var parentGroupId: ParentGroupId
    var page: UInt
    var pageSize: UInt

    enum CodingKeys: String, CodingKey {
        case securityKey = "security_key"
        case groupId = "gid"
        case parentGroupId = "parent_gid"
        case page = "page"
        case pageSize = "pageSize"
    }
}

extension LKClient {
    /// 获取分类下文章
    public func fetchCategoryArticles(
        groupId: GroupId, parentGroupId: ParentGroupId, page: UInt, pageSize: UInt = 40
    ) async throws(LKError) -> Page<ArticleInfoDTO> {
        self.logger.debug(
            "正在获取分类下文章，groupId: \(groupId), parentGroupId: \(parentGroupId), page: \(page), pageSize: \(pageSize)"
        )
        let req = FetchCategoryArticlesInfoRequest(
            securityKey: await self.securityKey,
            groupId: groupId,
            parentGroupId: parentGroupId,
            page: page,
            pageSize: pageSize,
        )

        return try await self.sendRequest(
            path: "/api/category/get-article-by-cate",
            requestData: req,
        )
    }
}
