import SwiftUI

public enum LKEmojiGroup: UInt8, Equatable, CaseIterable, Sendable {
    case neko = 15
    case luck = 10
    case onion = 5
    case df35 = 8
    case father = 9

    public var name: String {
        switch self {
        case .neko: return "猫猫"
        case .luck: return "幸运星"
        case .onion: return "葱白头"
        case .df35: return "东方35"
        case .father: return "father"
        }
    }

    public var url: String {
        switch self {
        case .neko: return "https://static.lightnovel.fun/smiley/neko/83.gif"
        case .luck: return "https://static.lightnovel.fun/smiley/luck/ls12.GIF"
        case .onion: return "https://static.lightnovel.fun/smiley/onion/y6.gif"
        case .df35: return "https://static.lightnovel.fun/smiley/df35/df048.jpg"
        case .father: return "https://static.lightnovel.fun/smiley/father/father07.gif"
        }
    }

    public var logo: Image {
        switch self {
        case .neko: return LKEmoji.neko83.image
        case .luck: return LKEmoji.luck12.image
        case .onion: return LKEmoji.onion6.image
        case .df35: return LKEmoji.df048.image
        case .father: return LKEmoji.father07.image
        }
    }

    public var id: UInt8 {
        return self.rawValue
    }

    public var emojis: Set<LKEmoji> {
        return Set(
            LKEmoji.allCases.filter { emoji in
                return emoji.group == self
            }
        )
    }
}
