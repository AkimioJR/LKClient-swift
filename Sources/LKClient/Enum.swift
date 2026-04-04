public enum PlatformType: String, Codable, Sendable {
    case pc = "pc"
    case ios = "ios"
    case android = "android"
}

public enum ClientType: String, Codable, Sendable {
    case app = "app"
    case web = "web"
}
