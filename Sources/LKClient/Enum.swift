public enum PlatformType: String, Codable, Sendable {
    case pc = "pc"
    case ios = "ios"
    case android = "android"
}

public enum ClientType: String, Codable, Sendable {
    case app = "app"
    case web = "web"
}

public enum GenderType: UInt8, Codable, Hashable, Sendable {
    case unknown = 0
    case male = 1
    case female = 2
}
