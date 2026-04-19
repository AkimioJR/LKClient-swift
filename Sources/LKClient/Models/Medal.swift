import Foundation

public struct Medal: Codable, Hashable, Sendable {
    public var medalId: UInt
    public var name: String
    public var desc: String
    public var medalsType: UInt

    @LKBool public var equip: Bool?  // 是否装备？
    public var expiration: Date?  // 过期时间，可能为"0000-00-00 00:00:00"
    public var imgURL: String?

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.medalId = try container.decode(UInt.self, forKey: .medalId)
        self.name = try container.decode(String.self, forKey: .name)
        self.desc = try container.decode(String.self, forKey: .desc)
        self.medalsType = try container.decode(UInt.self, forKey: .medalsType)
        self._equip = try container.decode(LKBool<Bool?>.self, forKey: .equip)
        self.expiration = try container.decodeIfPresent(Date.self, forKey: .expiration)
        self.imgURL = try container.decodeIfPresent(String.self, forKey: .imgURL)
    }
    public init(
        medalId: UInt, name: String, desc: String, medalsType: UInt, equip: Bool? = nil,
        expiration: Date? = nil, imgURL: String? = nil
    ) {
        self.medalId = medalId
        self.name = name
        self.desc = desc
        self.medalsType = medalsType
        self.equip = equip
        self.expiration = expiration
        self.imgURL = imgURL
    }

    enum CodingKeys: String, CodingKey {
        case medalId = "medal_id"
        case name = "name"
        case desc = "desc"
        case medalsType = "type"
        case equip = "equip"
        case expiration = "expiration"
        case imgURL = "img"
    }
}
