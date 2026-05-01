//
//  Discuss.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/11/11.
//

import Foundation

public struct ReplyDTO: Codable, Sendable, Hashable {
    public var topicId: UInt  // 话题ID（是哪条主评论下的回复评论）
    public var replyId: UInt  // 话题下面的第几个回复
    public var articleId: UInt  // 文章ID
    public var parentReplyId: UInt  // 这条评论是回复那一条评论的，0代表回复主评论
    public var repliedUserId: UInt  // 被回复的用户ID
    public var userId: UInt  // 回复者的用户ID
    public var likeCount: UInt
    public var time: Date
    public var content: String
    public var userInfo: UserInfoDTO
    public var replayUserInfo: UserInfoDTO?

    enum CodingKeys: String, CodingKey {
        case topicId = "tid"
        case replyId = "rid"
        case articleId = "pid"
        case parentReplyId = "r_rid"
        case repliedUserId = "r_uid"
        case userId = "uid"
        case likeCount = "likes"
        case time = "time"
        case content = "content"
        case userInfo = "user_info"
        case replayUserInfo = "r_user_info"
    }

    public init(
        topicId: UInt,
        replyId: UInt,
        articleId: UInt,
        parentReplyId: UInt,
        repliedUserId: UInt,
        userId: UInt,
        likeCount: UInt,
        time: Date,
        content: String,
        userInfo: UserInfoDTO,
        replayUserInfo: UserInfoDTO? = nil
    ) {
        self.topicId = topicId
        self.replyId = replyId
        self.articleId = articleId
        self.parentReplyId = parentReplyId
        self.repliedUserId = repliedUserId
        self.userId = userId
        self.likeCount = likeCount
        self.time = time
        self.content = content
        self.userInfo = userInfo
        self.replayUserInfo = replayUserInfo
    }
}

struct FetchArticleTopicReplyRequest: Codable, Sendable {
    var topicId: UInt
    var articleId: UInt
    let page: UInt = 1
    let pageSize: UInt = 20
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case topicId = "tid"
        case articleId = "aid"
        case page = "page"
        case pageSize = "page_size"
        case securityKey = "security_key"
    }
}

public struct TopicDTO: Codable, Sendable, Hashable {
    public var topicId: UInt
    public var articleId: UInt
    public var userId: UInt
    public var createTime: Date  // 该话题(评论)发布时间
    public var updateTime: Date  // 该话题最新评论（回复）时间
    public var content: String
    public var likeCount: UInt
    public var replyCount: UInt
    public var userInfo: UserInfoDTO
    public var replyList: [ReplyDTO]
    @LKBool public var alreadyLike: Bool?  // 是否已点赞

    enum CodingKeys: String, CodingKey {
        case topicId = "tid"
        case articleId = "pid"
        case userId = "uid"
        case createTime = "time"
        case updateTime = "last_time"
        case content = "content"
        case likeCount = "likes"
        case replyCount = "replies"
        case userInfo = "user_info"
        case replyList = "reply_list"
        case alreadyLike = "liked"
    }

    public init(
        topicId: UInt,
        articleId: UInt,
        userId: UInt,
        createTime: Date,
        updateTime: Date,
        content: String,
        likeCount: UInt,
        replyCount: UInt,
        userInfo: UserInfoDTO,
        replyList: [ReplyDTO],
        alreadyLike: Bool? = nil
    ) {
        self.topicId = topicId
        self.articleId = articleId
        self.userId = userId
        self.createTime = createTime
        self.updateTime = updateTime
        self.content = content
        self.likeCount = likeCount
        self.replyCount = replyCount
        self.userInfo = userInfo
        self.replyList = replyList
        self.alreadyLike = alreadyLike
    }
}

struct FetchArticleTopicsRequest: Codable, Sendable {
    var articleId: UInt
    var page: UInt
    var pageSize: UInt
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case articleId = "aid"
        case page = "page"
        case pageSize = "page_size"
        case securityKey = "security_key"
    }
}

public struct PostArticleTopicResponse: Codable, Sendable {
    public var topicId: UInt

    enum CodingKeys: String, CodingKey {
        case topicId = "tid"
    }
}

struct PostArticleTopicRequest: Codable, Sendable {
    var articleId: UInt
    var content: String
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case articleId = "aid"
        case content = "content"
        case securityKey = "security_key"
    }
}

struct LikeTopicRequest: Codable, Sendable {
    var topicId: UInt
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case topicId = "tid"
        case securityKey = "security_key"
    }
}

/// 回复 Topic 或者 Reply 的请求
/// 如果 parentReplyId 和 parentUserId 都为 nil，则表示回复的是 Topic
/// 如果 parentReplyId 和 parentUserId 都不为 nil，则表示回复的是 Reply
public struct PostArticleReplyRequest: Codable, Sendable {
    public var articleId: UInt
    public var topicId: UInt
    public var content: String
    public var parentReplyId: UInt?
    public var parentUserId: UInt?
    public var securityKey: String

    enum CodingKeys: String, CodingKey {
        case articleId = "aid"
        case topicId = "tid"
        case content = "content"
        case parentReplyId = "r_rid"
        case parentUserId = "r_uid"
        case securityKey = "security_key"
    }
}

public struct UploadImageResponse: Codable, Sendable {
    public var resourceId: String
    public var resourcePath: String
    public var resourceURL: String
    public var resourceInfo: ResourceInfo

    public struct ResourceInfo: Codable, Sendable {
        public var width: UInt
        public var height: UInt

        enum CodingKeys: String, CodingKey {
            case width = "width"
            case height = "height"
        }
    }

    enum CodingKeys: String, CodingKey {
        case resourceId = "res_id"
        case resourcePath = "res_path"
        case resourceURL = "res_url"
        case resourceInfo = "res_info"
    }
}

/// MARK: - 评论话题讨论
extension LKClient {

    /// 获取文章评论话题讨论
    public func fetchArticleTopics(_ articleId: UInt, page: UInt, pageSize: UInt = 20)
        async throws(LKError) -> Page<TopicDTO>
    {
        self.logger.debug(
            "正在获取文章评论话题讨论，articleId: \(articleId), page: \(page), pageSize: \(pageSize)")
        let req = FetchArticleTopicsRequest(
            articleId: articleId,
            page: page,
            pageSize: pageSize,
            securityKey: await self.securityKey
        )
        return try await self.sendRequest(
            path: "/api/discuss/get-topic",
            requestData: req,
        )
    }
    /// 发布文章评论话题
    public func postArticleTopic(_ articleId: UInt, content: String) async throws(LKError)
        -> PostArticleTopicResponse
    {
        self.logger.debug("正在发布文章评论话题，articleId: \(articleId), content: \(content)")
        let req = PostArticleTopicRequest(
            articleId: articleId,
            content: content,
            securityKey: await self.securityKey
        )
        return try await self.sendRequest(
            path: "/api/discuss/post-topic",
            requestData: req,
        )
    }

    /// 点赞评论话题
    public func likeArticleTopic(_ topicId: UInt) async throws(LKError) {
        self.logger.debug("正在点赞评论话题，topicId: \(topicId)")
        let req = await LikeTopicRequest(
            topicId: topicId,
            securityKey: self.securityKey
        )
        try await self.sendRequest(
            path: "/api/discuss/like",
            requestData: req,
        )
    }

    /// 获取评论话题回复
    public func featchArticleReply(_ articleId: UInt, topicId: UInt) async throws(LKError)
        -> TopicDTO
    {
        self.logger.debug(
            "正在获取评论话题回复，articleId: \(articleId), topicId: \(topicId)"
        )
        let req = await FetchArticleTopicReplyRequest(
            topicId: topicId,
            articleId: articleId,
            securityKey: self.securityKey
        )
        return try await self.sendRequest(
            path: "/api/discuss/get-reply",
            requestData: req,
        )
    }

    /// 发布评论话题回复
    public func postArticleReply(
        _ articleId: UInt,
        topicId: UInt,
        content: String,
        parentReplyId: UInt? = nil, parentUserId: UInt? = nil
    ) async throws(LKError) {
        self.logger.debug("正在发布评论回复，topicId: \(topicId), content: \(content)")
        let req = await PostArticleReplyRequest(
            articleId: articleId,
            topicId: topicId,
            content: content,
            parentReplyId: parentReplyId,
            parentUserId: parentUserId,
            securityKey: self.securityKey
        )
        try await self.sendRequest(
            path: "/api/discuss/post-reply",
            requestData: req,
        )
    }
}
