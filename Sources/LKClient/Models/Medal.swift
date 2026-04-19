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
    public var parentId: UInt?
    public var status: MedalStatus?

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
    }
    public init(
        medalId: UInt, name: String, desc: String, medalsType: UInt, equip: Bool? = nil,
        expiration: Date? = nil, imgURL: String? = nil, parentId: UInt? = nil,
        status: MedalStatus? = nil
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
    }
}
