import Foundation

public enum MedalType: UInt8, Equatable, CaseIterable, Sendable, Codable, Identifiable {
    case task = 1
    case exchange = 2

    public var id: UInt8 {
        return self.rawValue
    }

    public var name: String {
        switch self {
        case .task: return "任务勋章"
        case .exchange: return "兑换勋章"
        }
    }
}

public enum MedalStatus: UInt8, Equatable, CaseIterable, Sendable, Codable {
    case unachieved = 0
    case achieved = 1
    case claimed = 2

    public var name: String {
        switch self {
        case .unachieved: return "未达成"
        case .achieved: return "已达成"
        case .claimed: return "已领取"
        }
    }
}

public struct MedalGroup: Sendable, Codable, Identifiable {
    public var id: UInt8
    public var desc: String
    public var items: [Medal]
}

public struct Medal: Codable, Hashable, Sendable {
    public var medalId: UInt
    public var name: String
    public var desc: String
    public var medalsType: UInt

    @LKBool public var equip: Bool?  // 是否装备？
    public var expiration: Date?  // 过期时间，可能为"0000-00-00 00:00:00"
    public var imgURL: String?

    /// 仅在 /medal/list 接口中返回
    /// 任务勋章
    public var parentId: UInt?
    public var status: MedalStatus?
    /// 兑换勋章
    public var priceType: UInt8?  // 0 -> 轻币
    public var rechargeNum: Int?
    public var price: UInt?  // 轻币数量
    public var stock: Int?  // 库存数量 -1 表示不限量
    public var endTime: Date?  // 有效期截止时间，"0000-00-00 00:00:00" 为永久有效
    public var levelLimit: Level?  // 兑换勋章的等级限制
    // public var levelLimitName: String?

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.medalId = try container.decode(UInt.self, forKey: .medalId)
        self.name = try container.decode(String.self, forKey: .name)
        self.desc = try container.decode(String.self, forKey: .desc)
        self.medalsType = try container.decode(UInt.self, forKey: .medalsType)
        self._equip = try container.decode(LKBool<Bool?>.self, forKey: .equip)
        self.expiration = try container.decodeIfPresent(Date.self, forKey: .expiration)
        self.imgURL = try container.decodeIfPresent(String.self, forKey: .imgURL)
        self.parentId = try container.decodeIfPresent(UInt.self, forKey: .parentId)
        self.status = try container.decodeIfPresent(MedalStatus.self, forKey: .status)
        self.priceType = try container.decodeIfPresent(UInt8.self, forKey: .priceType)
        self.rechargeNum = try container.decodeIfPresent(Int.self, forKey: .rechargeNum)
        self.price = try container.decodeIfPresent(UInt.self, forKey: .price)
        self.stock = try container.decodeIfPresent(Int.self, forKey: .stock)
        self.endTime = try container.decodeIfPresent(Date.self, forKey: .endTime)
        self.levelLimit = try container.decodeIfPresent(Level.self, forKey: .levelLimit)
    }
    public init(
        medalId: UInt, name: String, desc: String, medalsType: UInt, equip: Bool? = nil,
        expiration: Date? = nil, imgURL: String? = nil, parentId: UInt? = nil,
        status: MedalStatus? = nil, priceType: UInt8? = nil, rechargeNum: Int? = nil,
        price: UInt? = nil, stock: Int? = nil, endTime: Date? = nil, levelLimit: Level? = nil
    ) {
        self.medalId = medalId
        self.name = name
        self.desc = desc
        self.medalsType = medalsType
        self.equip = equip
        self.expiration = expiration
        self.imgURL = imgURL
        self.parentId = parentId
        self.status = status
        self.priceType = priceType
        self.rechargeNum = rechargeNum
        self.price = price
        self.stock = stock
        self.endTime = endTime
        self.levelLimit = levelLimit
    }

    enum CodingKeys: String, CodingKey {
        case medalId = "medal_id"
        case name = "name"
        case desc = "desc"
        case medalsType = "type"
        case equip = "equip"
        case expiration = "expiration"
        case imgURL = "img"
        case parentId = "parent_id"
        case status = "status"
        case priceType = "price_type"
        case rechargeNum = "recharge_num"
        case price = "price"
        case stock = "stock"
        case endTime = "end_time"
        case levelLimit = "level_limit"
    }
}

struct FetchMedalListRequest: Encodable {
    let page: UInt = 0

    var type: MedalType
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case page = "page"
        case type = "type"
        case securityKey = "security_key"
    }
}

struct FetchTaskMedalListResponse: Decodable {
    var title: String
    var type: MedalType
    var list: [MedalGroup]

    enum CodingKeys: String, CodingKey {
        case title = "title"
        case type = "type"
        case list = "list"
    }
}

/// MARK: - 勋章中心 API
extension LKClient {
    /// 获取勋章列表
    func fetchTaskMedalList<T: Decodable & Sendable>(for type: MedalType) async throws -> T {
        self.logger.debug("正在获取 \(type.name) 勋章列表...")
        let request = await FetchMedalListRequest(type: .task, securityKey: self.securityKey)
        return try await self.sendRequest(path: "/api/medal/list", requestData: request)
    }

    /// 获取任务勋章列表
    public func fetchTaskMedalList() async throws -> [MedalGroup] {
        let resp: FetchTaskMedalListResponse = try await self.fetchTaskMedalList(for: .task)
        return resp.list
    }
    /// 获取兑换勋章列表
    public func fetchExchangeMedalList() async throws -> Page<MedalGroup> {
        return try await self.fetchTaskMedalList(for: .exchange)
    }
}
