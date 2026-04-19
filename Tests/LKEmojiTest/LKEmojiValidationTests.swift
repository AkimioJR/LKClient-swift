import XCTest

@testable import LKEmoji

class LKEmojiValidationTests: XCTestCase {
    typealias OriginalEmoji = (code: String, url: String, groupId: UInt8)

    struct EmojiItem: Codable {
        var id: UInt16
        var code: String
        var url: String
    }
    struct EmojiGroup: Codable {
        var id: UInt8
        var name: String
        // var type: UInt8
        var icon: String
        var items: [EmojiItem]
    }

    private static let originalEmojiMap: [UInt16: OriginalEmoji] = {
        guard let jsonURL = Bundle.module.url(forResource: "lk_images", withExtension: "json")
        else {
            fatalError("无法找到测试资源lk_images.json；请检查 LKEmojiTests 的 resources 配置")
        }

        do {
            let jsonData = try Data(contentsOf: jsonURL)
            let groups = try JSONDecoder().decode([EmojiGroup].self, from: jsonData)
            var map: [UInt16: OriginalEmoji] = [:]

            for group in groups {
                let groupId = group.id
                if groupId == 12 || groupId == 13 {
                    continue
                }
                for item in group.items {
                    map[item.id] = (item.code, item.url, group.id)
                }
            }

            return map
        } catch {
            fatalError("解析lk_images.json失败: \(error)")
        }
    }()

    func testAllCases_shouldMatchOriginalJSONData() throws {
        var originalEmojiMap = Self.originalEmojiMap

        // 遍历所有的枚举case，逐个校验
        for emoji in LKEmoji.allCases {
            let emojiId = emoji.id

            // 1. 检查原始数据中是否存在这个id
            guard let original = originalEmojiMap[emojiId] else {
                XCTFail("枚举中存在原始JSON没有的表情，id: \(emojiId), case: \(emoji)")
                continue
            }

            // 2. 校验code
            XCTAssertEqual(
                emoji.code,
                original.code,
                "表情id\(emojiId)的code不匹配，枚举: \(emoji.code), 原始: \(original.code)"
            )

            // 3. 校验url
            XCTAssertEqual(
                emoji.url,
                original.url,
                "表情id\(emojiId)的url不匹配，枚举: \(emoji.url), 原始: \(original.url)"
            )

            // 4. 校验group
            XCTAssertEqual(
                emoji.group.id,
                original.groupId,
                "表情id\(emojiId)的groupId不匹配，枚举: \(emoji.group.id), 原始: \(original.groupId)"
            )

            // 5. 校验初始化方法
            XCTAssertEqual(
                LKEmoji(code: emoji.code),
                emoji,
                "表情id\(emojiId)的code初始化方法不匹配"
            )
            XCTAssertEqual(
                LKEmoji(url: emoji.url),
                emoji,
                "表情id\(emojiId)的url初始化方法不匹配"
            )

            // 移除已校验的项，最后检查遗漏
            originalEmojiMap.removeValue(forKey: emojiId)
        }

        // 检查是否有原始JSON里的表情，没有在枚举中
        if !originalEmojiMap.isEmpty {
            XCTFail(
                "原始JSON中存在\(originalEmojiMap.count)个表情，没有在枚举中，缺失的id: \(originalEmojiMap.keys.sorted())"
            )
        }
    }

    func testInitWithURL_shouldReturnMatchingEmojiForAllOriginalEntries() throws {
        for (id, emoji) in Self.originalEmojiMap {
            guard let initializedEmoji = LKEmoji(url: emoji.url) else {
                XCTFail("无法通过url初始化表情，url: \(emoji.url), id: \(id)")
                continue
            }
            XCTAssertEqual(
                initializedEmoji.id,
                id,
                "通过url初始化的表情id不匹配，url: \(emoji.url), 期望id: \(id), 实际id: \(initializedEmoji.id)"
            )
        }
    }
    func testInitWithCode_shouldReturnMatchingEmojiForAllOriginalEntries() throws {
        for (id, emoji) in Self.originalEmojiMap {
            guard let initializedEmoji = LKEmoji(code: emoji.code) else {
                XCTFail("无法通过code初始化表情，code: \(emoji.code), id: \(id)")
                continue
            }
            XCTAssertEqual(
                initializedEmoji.id,
                id,
                "通过code初始化的表情id不匹配，code: \(emoji.code), 期望id: \(id), 实际id: \(initializedEmoji.id)"
            )
        }
    }
}
