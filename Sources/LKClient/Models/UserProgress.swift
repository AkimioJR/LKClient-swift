public struct UserProgress: Codable, Hashable, Sendable {
    public var experience: UInt
    public var grade: UserGrade {
        UserGrade.allCases.last { $0.requiredExp <= self.experience } ?? .emperor
    }

    enum CodingKeys: String, CodingKey {
        case experience = "exp"
    }
}
