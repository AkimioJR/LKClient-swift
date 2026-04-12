//
//  GroupId.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/12/14.
//

import SwiftUI

public enum ParentGroupId: UInt8, CaseIterable, Codable, Comparable, Sendable {
    case all = 0
    case news = 1
    case lightnovel = 3
    case manga = 33
    case anime = 34
    case group35 = 35
    case material = 36
    case gallery = 37
    case other = 40
    case guild = 42

    public static func < (lhs: ParentGroupId, rhs: ParentGroupId) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    public var name: String {
        switch self {
        case .all: return "全部"
        case .news: return "资讯"
        case .lightnovel: return "轻小说"
        case .manga: return "漫画"
        case .anime: return "动画"
        case .group35: return "group35"
        case .material: return "素材"
        case .gallery: return "图坊"
        case .other: return "其它资源"
        case .guild: return "工会大厅"
        }
    }

    public var groupIds: [GroupId] {
        switch self {
        case .all:
            return [.all]
        case .news:
            return [.newsLightNovel, .newsManga, .newsAnime, .newsGame, .newsFigure, .newsOther]
        case .lightnovel:
            return [
                .lightNovelLatest, .lightNovelVolume, .lightNovelDownload, .lightNovelJapanese,
                .lightNovelEpub, .lightNovelOriginal,
            ]
        case .manga:
            return [.mangaPublish, .mangaRepost, .mangaDownload, .mangaAbout]
        case .anime:
            return [.animePublish, .animeRepost]
        case .group35:
            return [.group35Aria]
        case .material:
            return [.materialRepost, .materialTutorial, .materialConcept]
        case .gallery:
            return [.galleryRepost, .galleryOriginal, .galleryOther]
        case .other:
            return [.otherMusic, .otherGame, .otherRadioDrama, .otherOther]
        case .guild:
            return [.guildAria, .guildActivity, .guildDiscussion, .guildColumn]
        }
    }

    public var logo: Image {
        return Image("ParentGroup-Logo/\(self.rawValue)", bundle: .module)
    }
}

extension ParentGroupId: CustomStringConvertible {
    public var description: String {
        return "LKParentGroupId{value: \(self.rawValue), name: (\(self.name))}"
    }
}

public enum GroupId: UInt16, CaseIterable, Codable, Comparable, Sendable {
    case all = 0

    case newsLightNovel = 100
    case newsManga = 101
    case newsAnime = 102
    case newsGame = 103
    case newsFigure = 104
    case newsOther = 105

    case lightNovelLatest = 106
    case lightNovelVolume = 107
    case lightNovelDownload = 108
    case lightNovelJapanese = 109
    case lightNovelEpub = 110
    case lightNovelOriginal = 111

    case mangaPublish = 112
    case mangaRepost = 113
    case mangaDownload = 114
    case mangaAbout = 14175

    case group35Aria = 117

    case animePublish = 115
    case animeRepost = 116

    case materialRepost = 119
    case materialTutorial = 120
    case materialConcept = 121

    case galleryRepost = 122
    case galleryOriginal = 123
    case galleryOther = 124

    case otherMusic = 125
    case otherGame = 126
    case otherRadioDrama = 127
    case otherOther = 128

    case guildAria = 129
    case guildActivity = 130
    case guildDiscussion = 131
    case guildColumn = 132

    public static func < (lhs: GroupId, rhs: GroupId) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    public var name: String {
        switch self {
        case .all: return "全部"

        // 资讯
        case .newsLightNovel: return "轻小说"
        case .newsManga: return "漫画"
        case .newsAnime: return "动漫"
        case .newsGame: return "游戏"
        case .newsFigure: return "手办模型"
        case .newsOther: return "其他"

        // 轻小说
        case .lightNovelLatest: return "最新"
        case .lightNovelVolume: return "整卷"
        case .lightNovelDownload: return "下载"
        case .lightNovelJapanese: return "日文"
        case .lightNovelEpub: return "Epub"
        case .lightNovelOriginal: return "原创"

        // 漫画
        case .mangaPublish: return "发布"
        case .mangaRepost: return "转载"
        case .mangaDownload: return "下载"
        case .mangaAbout: return "漫画相关"

        // 动画
        case .animePublish: return "发布"
        case .animeRepost: return "转载"

        case .group35Aria: return "ARIA之都"

        // 素材
        case .materialRepost: return "科普"
        case .materialTutorial: return "教程"
        case .materialConcept: return "概念设定"

        // 图坊
        case .galleryRepost: return "转载"
        case .galleryOriginal: return "原创"
        case .galleryOther: return "其它"

        // 其它资源
        case .otherMusic: return "音乐"
        case .otherGame: return "游戏"
        case .otherRadioDrama: return "广播剧"
        case .otherOther: return "其它"

        // 公会大厅
        case .guildAria: return "ARIA之都"
        case .guildActivity: return "活动区"
        case .guildDiscussion: return "作品讨论"
        case .guildColumn: return "专栏"
        }
    }

    public var parentGroupId: ParentGroupId {
        switch self {
        case .all: return .all

        // 资讯
        case .newsLightNovel, .newsManga, .newsAnime, .newsGame, .newsFigure, .newsOther:
            return .news

        // 轻小说
        case .lightNovelLatest, .lightNovelVolume, .lightNovelDownload, .lightNovelJapanese,
            .lightNovelEpub, .lightNovelOriginal:
            return .lightnovel

        // 漫画
        case .mangaPublish, .mangaRepost, .mangaDownload, .mangaAbout:
            return .manga

        // 动画
        case .animePublish, .animeRepost:
            return .anime

        case .group35Aria:
            return .group35

        // 素材
        case .materialRepost, .materialTutorial, .materialConcept:
            return .material

        // 图坊
        case .galleryRepost, .galleryOriginal, .galleryOther:
            return .gallery

        // 其它资源
        case .otherMusic, .otherGame, .otherRadioDrama, .otherOther:
            return .other

        // 公会大厅
        case .guildAria, .guildActivity, .guildDiscussion, .guildColumn:
            return .guild
        }
    }
}

extension GroupId: CustomStringConvertible {
    public var description: String {
        return "LKGroupId{value: \(self.rawValue), name: \(self.name)}"
    }
}
