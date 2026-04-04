//
//  Task.swift
//  SwiftLK
//
//  Created by 秋澪 on 2026/1/3.
//

import SwiftUI

public enum TaskType: UInt8, CaseIterable, Codable, Sendable {
    case readArticle = 1  // 阅读一篇帖子
    case collectArticle = 2  // 收藏一篇帖子
    case likeArticle = 3  // 为一篇帖子点赞
    case shareArticle = 5  // 分享一篇帖子
    case coinArticle = 6  // 为一篇帖子投币
    case completeAllTasks = 7  // 完成全部任务
    case checkin = 8  // 每日签到

    public var name: String {
        switch self {
        case .readArticle:
            return "阅读一篇帖子"
        case .collectArticle:
            return "收藏一篇帖子"
        case .likeArticle:
            return "为一篇帖子点赞"
        case .shareArticle:
            return "分享一篇帖子"
        case .coinArticle:
            return "为一篇帖子投币"
        case .checkin:
            return "每日签到"
        case .completeAllTasks:
            return "完成全部任务"
        }
    }

    // var balance: UInt {
    //     switch self {
    //         default:
    //             return 0
    //     }
    // }

    public var coinCount: UInt {
        switch self {
        case .readArticle, .collectArticle, .checkin:
            return 5
        case .shareArticle, .coinArticle, .completeAllTasks:
            return 10
        default:
            return 0
        }
    }

    public var experience: UInt {
        switch self {
        case .readArticle, .collectArticle, .likeArticle, .shareArticle, .completeAllTasks,
            .checkin:
            return 5
        default:
            return 0
        }
    }

    public var image: Image? {
        switch self {
        case .readArticle:
            return Image("task/read")
        case .collectArticle:
            return Image("task/collect")
        case .likeArticle:
            return Image("task/dianzan")
        case .shareArticle:
            return Image("task/share")
        case .coinArticle:
            return Image("task/toubi")
        default:
            return nil
        }
    }
}

extension TaskType: CustomStringConvertible {
    public var description: String {
        return self.name
    }
}

public enum TaskState: UInt8, CaseIterable, Codable, Sendable {
    case uncomplete = 0  // 未完成
    case waitingForReward = 1  // 等待领取奖励
    case rewarded = 2  // 已经领取奖励

    public var description: String {
        switch self {
        case .uncomplete:
            return "未完成"
        case .waitingForReward:
            return "等领取"
        case .rewarded:
            return "已领取"
        }
    }
}

struct TaskListRequest: Codable, Sendable {
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case securityKey = "security_key"
    }
}

public struct TaskList: Codable, Sendable {
    public var compelteAllTaskId: TaskType
    public var compelteAllTaskstate: TaskState
    public var items: [Item]

    public struct Item: Codable, Sendable {
        public var type: TaskType
        public var state: TaskState

        enum CodingKeys: String, CodingKey {
            case type = "id"
            case state = "status"
        }

        public init(type: TaskType, state: TaskState) {
            self.type = type
            self.state = state
        }
    }

    public init(compelteAllTaskId: TaskType, compelteAllTaskstate: TaskState, items: [Item]) {
        self.compelteAllTaskId = compelteAllTaskId
        self.compelteAllTaskstate = compelteAllTaskstate
        self.items = items
    }
    // public init(from decoder: any Decoder) throws {
    //     let container = try decoder.container(keyedBy: CodingKeys.self)
    //     self.compelteAllTaskId = try container.decode(TaskType.self, forKey: .compelteAllTaskId)
    //     self.compelteAllTaskstate = try container.decode(
    //         TaskState.self, forKey: .compelteAllTaskstate)
    //     self.items = try container.decode([Self.Item].self, forKey: .items)
    // }

    enum CodingKeys: String, CodingKey {
        case compelteAllTaskId = "id"
        case compelteAllTaskstate = "status"
        case items = "items"
    }
}

struct TaskCompleteRequest: Codable, Sendable {
    var type: TaskType
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case securityKey = "security_key"
        case type = "id"
    }
}

public struct TaskCompleteResponse: Codable, Sendable {
    public var experience: UInt
    public var coinCount: UInt
    // var balance: UInt

    enum CodingKeys: String, CodingKey {
        case experience = "exp"
        case coinCount = "coin"
        // case balance = "balance"
    }
}
