//
//  Discuss.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/11/11.
//

import Foundation

public struct ReplyDetail: Codable, Sendable {
    var topicId: UInt  // 话题ID（是哪条主评论下的回复评论）
    var replyId: UInt  // 话题下面的第几个回复
    var articleId: UInt  // 文章ID
    var parentReplyId: UInt  // 这条评论是回复那一条评论的，0代表回复主评论
    var repliedUserId: UInt  // 被回复的用户ID
    var userId: UInt  // 回复者的用户ID
    var likeCount: UInt
    var time: Date
    var content: String
    var userInfo: UserProfileDetail

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
    }
}

public struct TopicDetail: Codable, Sendable {
    var topicId: UInt
    var articleId: UInt
    var userId: UInt
    var createTime: Date  // 该话题(评论)发布时间
    var updateTime: Date  // 该话题最新评论（回复）时间
    var content: String
    var likeCount: UInt
    var replyCount: UInt
    var userInfo: UserProfileDetail
    var replyList: [ReplyDetail]
    @LKBool var alreadyLike: Bool?  // 是否已点赞

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
}

public struct DiscussInfo: Codable, Sendable {
    var list: [TopicDetail]
    //var hots: [Any]
    var pageInfo: PageInfo?

    enum CodingKeys: String, CodingKey {
        case list = "list"
        case pageInfo = "page_info"
    }
}

struct GetDiscussTopicsRequest: Codable, Sendable {
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

struct PostDiscussTopicsRequest: Codable, Sendable {
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

public struct UploadImageResponse: Codable, Sendable {
    var resourceId: String
    var resourcePath: String
    var resourceURL: String
    var resourceInfo: ResourceInfo

    struct ResourceInfo: Codable, Sendable {
        var width: UInt
        var height: UInt

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
