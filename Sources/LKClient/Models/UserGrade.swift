public enum UserGrade: UInt8, CaseIterable, Equatable, Codable, Comparable, Sendable , Identifiable {
    case commoner = 1  // 平民
    case knight = 2  // 骑士
    case lord = 3  // 勋爵
    case viscount = 4  // 子爵
    case earl = 5  // 伯爵
    case marquis = 6  // 侯爵
    case duke = 7  // 公爵
    case prince = 8  // 王爵
    case emperor = 9  // 皇帝
    
    public var id: Self { self }

    /// 等级名称
    public var title: String {
        switch self {
        case .commoner: return "平民"
        case .knight: return "骑士"
        case .lord: return "勋爵"
        case .viscount: return "子爵"
        case .earl: return "伯爵"
        case .marquis: return "侯爵"
        case .duke: return "公爵"
        case .prince: return "王爵"
        case .emperor: return "皇帝"
        }
    }

    public var fullTitle: String {
        return "LV\(self.rawValue) \(self.title)"
    }

    public var description: String {
        return "LKLevel{LV: \(self.rawValue)}"
    }

    /// 达到该等级所需的经验值
    public var requiredExp: UInt {
        switch self {
        case .commoner: return 0
        case .knight: return 251
        case .lord: return 1001
        case .viscount: return 2001
        case .earl: return 4501
        case .marquis: return 8001
        case .duke: return 12501
        case .prince: return 18001
        case .emperor: return 50001
        }
    }

    // 升到下一个等级所需的经验值
    public var nextGradeExp: UInt {
        return nextGrade?.requiredExp ?? Self.emperor.requiredExp  // 皇帝等级没有下一级，返回最高经验值
    }

    // 下一个等级
    public var nextGrade: Self? {
        if self == .emperor {
            return nil
        }
        return Self(rawValue: self.rawValue + 1)
    }

    // 上一个等级
    public var previousGrade: Self? {
        if self == .commoner {
            return nil
        }
        return Self(rawValue: self.rawValue - 1)
    }

    // MARK: - Comparable
    static public func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
