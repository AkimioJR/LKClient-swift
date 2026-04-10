//
//  HTTP.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/11/9.
//

import Foundation

struct LKRequest<T: Encodable & Sendable>: Encodable, Sendable {
    @LKBool var gz: Bool
    @LKBool var isEncrypted: Bool
    var client: ClientType
    var platform: PlatformType
    var data: T?
    var versionName: String
    var versionCode: UInt
    var sign: String

    init(
        data: T? = nil,
        _ gz: Bool = false,
        _ isEncrypted: Bool = false,
        _ client: ClientType = .app,
        _ platform: PlatformType = .ios,
        _ versionName: String = "0.11.51",
        _ versionCode: UInt = 191,
        _ sign: String = "",
    ) {
        self.gz = gz
        self.isEncrypted = isEncrypted
        self.client = client
        self.platform = platform
        self.data = data
        self.versionName = versionName
        self.versionCode = versionCode
        self.sign = sign
    }

    enum CodingKeys: String, CodingKey {
        case gz = "gz"
        case isEncrypted = "is_encrypted"
        case client = "client"
        case platform = "platform"
        case data = "d"
        case versionName = "ver_name"
        case versionCode = "ver_code"
        case sign = "sign"
    }
}

struct LKResponse<T: Decodable & Sendable>: Decodable, Sendable {
    var code: UInt
    var time: Date
    var data: T?

    enum CodingKeys: String, CodingKey {
        case code = "code"
        case timeStamp = "t"
        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // 首先解析 code 和 timeStamp
        self.code = try container.decode(UInt.self, forKey: .code)

        // 根据 code 处理不同情况
        switch self.code {
        case 0:  // 成功
            let timestamp = try container.decode(UInt64.self, forKey: .timeStamp)
            self.time = Date(timeIntervalSince1970: TimeInterval(timestamp))
            self.data = try container.decodeIfPresent(T.self, forKey: .data)

        default:  // 错误
            self.data = nil
            throw LKError.apiError(code: self.code)
        }
    }
}
