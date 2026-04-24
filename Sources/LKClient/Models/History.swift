//
//  History.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/11/18.
//

import Foundation

// 添加/删除收藏请求
struct RecordRequest: Codable, Sendable {
    var favoriteId: UInt
    var classType: ClassType
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case favoriteId = "fid"
        case classType = "class"
        case securityKey = "security_key"
    }
}

public protocol RecordDTO: Codable, Sendable {}

public struct ArticleRecordDTO: RecordDTO {
    public var articleId: UInt
    public var title: String
    public var bannerURL: String
    public var userId: UInt
    public var hitCount: UInt
    public var commentCount: UInt
    public var createTime: Date
    public var updateTime: Date
    public var coverURL: String
    public var coverType: CoverType
    public var groupId: GroupId
    public var parentGroupId: ParentGroupId
    public var seriesId: UInt

    enum CodingKeys: String, CodingKey {
        case articleId = "aid"
        case title = "title"
        case bannerURL = "banner"
        case userId = "uid"
        case hitCount = "hits"
        case commentCount = "comments"
        case createTime = "time"
        case updateTime = "last_time"
        case coverURL = "cover"
        case coverType = "cover_type"
        case groupId = "gid"
        case parentGroupId = "parent_gid"
        case seriesId = "sid"
    }
}

public struct SeriesRecordDTO: RecordDTO {
    public var seriesId: UInt
    public var name: String
    public var author: String
    public var bannerURL: String
    public var coverURL: String
    public var coverType: CoverType
    public var rateCount: UInt
    public var updateTime: Date
    public var groupId: GroupId
    public var parentGroupId: ParentGroupId
    public var editors: [UserInfoDTO]

    enum CodingKeys: String, CodingKey {
        case seriesId = "sid"
        case name = "name"
        case author = "author"
        case bannerURL = "banner"
        case coverURL = "cover"
        case coverType = "cover_type"
        case rateCount = "rates"
        case updateTime = "last_time"
        case groupId = "gid"
        case parentGroupId = "parent_gid"
        case editors = "editors"
    }
}

struct FetchRecordRequest: Codable, Sendable {
    var type: ArticleType
    var classType: ClassType
    var page: UInt
    var pageSize: UInt
    var userId: UInt
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case classType = "class"
        case page = "page"
        case pageSize = "page_size"
        case userId = "uid"
        case securityKey = "security_key"
    }
}

/// MARK: - 历史记录和收藏记录相关
extension LKClient {
    private func applyRecordChange(req: RecordRequest, path: String) async throws {
        try await self.sendRequest(
            path: path,
            requestData: req,
        )
    }

    /// 添加历史记录
    public func addHistory(favoriteId: UInt, classType: ClassType) async throws {
        self.logger.debug("正在添加历史记录，favoriteId: \(favoriteId), classType: \(classType)")
        let req = RecordRequest(
            favoriteId: favoriteId,
            classType: classType,
            securityKey: await self.securityKey,
        )
        try await self.applyRecordChange(
            req: req,
            path: "/api/history/add-history"
        )
    }

    /// 添加收藏
    public func addFavorite(favoriteId: UInt, classType: ClassType) async throws {
        self.logger.debug("正在添加收藏，favoriteId: \(favoriteId), classType: \(classType)")
        let req = RecordRequest(
            favoriteId: favoriteId,
            classType: classType,
            securityKey: await self.securityKey,
        )
        try await self.applyRecordChange(
            req: req,
            path: "/api/history/add-collection"
        )
    }

    /// 删除收藏
    public func deleteFavorite(favoriteId: UInt, classType: ClassType) async throws {
        self.logger.debug("正在删除收藏，favoriteId: \(favoriteId), classType: \(classType)")
        let req = RecordRequest(
            favoriteId: favoriteId,
            classType: classType,
            securityKey: await self.securityKey,
        )
        try await self.applyRecordChange(
            req: req,
            path: "/api/history/del-collection",
        )
    }

    /// 查询历史记录
    public func fetchHistoryRecords<T: RecordDTO>(
        type: ArticleType, classType: ClassType, page: UInt, pageSize: UInt = 40
    ) async throws(LKError) -> Page<T> {
        self.logger.debug(
            "正在查询历史记录，type: \(type), classType: \(classType), page: \(page), pageSize: \(pageSize)"
        )
        let req = FetchRecordRequest(
            type: type,
            classType: classType,
            page: page,
            pageSize: pageSize,
            userId: await self.userId,
            securityKey: await self.securityKey,
        )
        return try await self.sendRequest(
            path: "/api/history/get-history",
            requestData: req,
        )
    }

    // 查询收藏列表
    public func fetchFavoriteRecords<T: RecordDTO>(
        type: ArticleType, classType: ClassType, page: UInt, pageSize: UInt = 40
    ) async throws(LKError) -> Page<T> {
        self.logger.debug(
            "正在查询收藏记录，type: \(type), classType: \(classType), page: \(page), pageSize: \(pageSize)"
        )
        let req = FetchRecordRequest(
            type: type,
            classType: classType,
            page: page,
            pageSize: pageSize,
            userId: await self.userId,
            securityKey: await self.securityKey,
        )
        return try await self.sendRequest(
            path: "/api/history/get-collections",
            requestData: req,
        )
    }
}
