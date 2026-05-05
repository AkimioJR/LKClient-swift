public struct UnReadNotifyDTO: Codable, Sendable {
    struct MessageCount: Codable, Sendable {
        var count: UInt
        var timestamp: UInt

        enum CodingKeys: String, CodingKey {
            case count = "count"
            case timestamp = "timestamp"
        }
    }

    public var allCount: UInt  // 未读消息总数
    var reply: MessageCount  // 未读回复消息
    var system: MessageCount  // 未读系统消息
    var guild: MessageCount  // 未读公会消息

    public var replyCount: UInt { reply.count }
    public var systemCount: UInt { system.count }
    public var guildCount: UInt { guild.count }

    enum CodingKeys: String, CodingKey {
        case allCount = "all_count"
        case reply = "reply"
        case system = "sys_msg"
        case guild = "guild"
    }
}

struct FetchUnReadNotifyRequest: Codable, Sendable {
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case securityKey = "security_key"
    }
}

public struct SystemMessageDTO: Codable, Sendable {
    public var id: UInt
    public var title: String
    public var message: String
    public var timestamp: UInt

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case message = "msg"
        case timestamp = "timestamp"
    }
}

struct FetchSystemMessagesRequest: Codable, Sendable {
    var securityKey: String
    var page: UInt
    var pageSize: UInt

    enum CodingKeys: String, CodingKey {
        case securityKey = "security_key"
        case page = "page"
        case pageSize = "page_size"
    }
}

/// MARK: - 通知相关
extension LKClient {
    /// 获取未读消息数量
    public func fetchUnReadNotify() async throws(LKError) -> UnReadNotifyDTO {
        let req = await FetchUnReadNotifyRequest(securityKey: self.securityKey)
        return try await self.sendRequest(path: "/api/notify/unread", requestData: req)
    }

    /// 获取系统消息列表
    public func fetchSystemMessages(page: UInt, pageSize: UInt) async throws(LKError)
        -> [SystemMessageDTO]
    {
        let req = await FetchSystemMessagesRequest(
            securityKey: self.securityKey,
            page: page,
            pageSize: pageSize,
        )
        return try await self.sendRequest(path: "/api/sys-msg/get-sys-msg", requestData: req)
    }
}
