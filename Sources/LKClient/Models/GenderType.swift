public enum GenderType: UInt8, Codable, Hashable, Sendable {
    case unknown = 0
    case male = 1
    case female = 2

    public var name: String {
        switch self {
        case .unknown: return "未知"
        case .male: return "男"
        case .female: return "女"
        }
    }
}
