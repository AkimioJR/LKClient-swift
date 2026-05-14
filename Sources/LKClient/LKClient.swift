//
//  LKClient.swift
//  SwiftLK
//
//  Created by 秋澪 on 2025/11/8.
//

import CryptoKit
import Foundation
import OSLog

public actor LKClient {
    let logger: Logger
    private let session: URLSession

    @MainActor var securityKey: String
    @MainActor public func setSecurityKey(_ key: String) { self.securityKey = key }
    @MainActor public var userId: UInt {
        let paths = self.securityKey.split(separator: ":")
        if paths.count != 3 {
            return 0
        }
        return UInt(paths[1]) ?? 0
    }
    @MainActor public var isLoggedIn: Bool { return self.userId != 0 }

    static private let jsonDecoder = {
        let jd = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        jd.dateDecodingStrategy = .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()

            // 尝试解码为字符串
            let dateString = try container.decode(String.self)

            // 处理特殊的空值情况
            if dateString == "0000-00-00 00:00:00" {
                return .invalid
            }

            if let parsedDate = formatter.date(from: dateString) {
                return parsedDate
            } else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "日期字符串格式错误，期望格式: yyyy-MM-dd HH:mm:ss，实际: \(dateString)"
                )
            }
        }
        return jd
    }()

    // Configuration
    public var baseURL: String
    public var userAgent: String
    public var gzip: Bool
    public var encrypted: Bool
    public var client: ClientType
    public var platform: PlatformType
    public var versionName: String
    public var versionCode: UInt
    public var sign: String

    public init(
        securityKey: String = "",
        baseURL: String = "https://api.lightnovel.fun/api",
        userAgent: String = "Dart/2.10 (dart:io)",
        gzip: Bool = true,
        // encrypted: Bool = false,
        client: ClientType = .app,
        platform: PlatformType = .ios,
        versionName: String = "0.11.51",
        versionCode: UInt = 191,
        // sign: String = ""
        logger: Logger = Logger(
            subsystem: "github.com.AkimioJR.LKClient-swift", category: "LKClient"),
        session: URLSession = URLSession(configuration: .default)
    ) {
        self.securityKey = securityKey

        self.baseURL = baseURL
        self.userAgent = userAgent
        self.gzip = gzip
        self.encrypted = false
        self.client = client
        self.platform = platform
        self.versionName = versionName
        self.versionCode = versionCode
        self.sign = ""
        self.logger = logger
        self.session = session
    }

    @MainActor
    public func logout() {
        self.securityKey = ""
    }

    static private func decompress(_ data: Data) throws(LKError) -> Data {
        guard let compressedData = Data(base64Encoded: data) else {
            throw LKError.base64DecodingError
        }
        let dataWithoutHeader = compressedData.dropFirst(2)

        guard let nsData = try? (dataWithoutHeader as NSData).decompressed(using: .zlib) else {
            throw LKError.zlibDecompressionError
        }

        return nsData as Data
    }

    @concurrent
    nonisolated func sendRequest<T: Encodable & Sendable, R: Decodable & Sendable>(
        path: String,
        requestData: T?,
        client: ClientType? = nil,
        platform: PlatformType? = nil
    ) async throws(LKError) -> R {
        guard let url = await URL(string: self.baseURL + path) else {
            throw await LKError.apiEndpointError("Invalid URL: \(self.baseURL + path)")
        }

        var request = LKRequest(data: requestData)
        if let c = client {
            request.client = c
        }
        if let p = platform {
            request.platform = p
        }
        request.gz = await self.gzip
        request.isEncrypted = await self.encrypted

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(await self.userAgent, forHTTPHeaderField: "User-Agent")

        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
        } catch {
            throw .decodingError(error)
        }

        var data: Data
        do {
            (data, _) = try await self.session.data(for: urlRequest)
        } catch {
            throw .networkError(error)
        }

        if request.gz {
            data = try Self.decompress(data)
        }

        do {
            let resp = try Self.jsonDecoder.decode(LKResponse<R>.self, from: data)
            if let responseData = resp.data {
                return responseData
            } else {
                throw LKError.apiEmptyDataError
            }
        } catch {
            print("request path: \(path)")
            print(
                "request data: \(String(data: urlRequest.httpBody ?? Data(), encoding: .utf8) ?? "nil")"
            )
            print("response data: \(String(data: data, encoding: .utf8) ?? "nil")")
            print("error: \(error)")
            throw .decodingError(error)
        }
    }
    /// 重载版本
    /// 适用于不需要请求体的API调用
    @concurrent
    nonisolated func sendRequest<R: Decodable & Sendable>(
        path: String,
        client: ClientType? = nil,
        platform: PlatformType? = nil
    ) async throws(LKError) -> R {
        try await self.sendRequest(
            path: path,
            requestData: Optional<EmptyRequest>.none,
            client: client,
            platform: platform
        )
    }
    /// 重载版本
    /// 适用于需要请求体且不关心响应体的API调用
    @concurrent
    nonisolated func sendRequest<T: Encodable & Sendable>(
        path: String,
        requestData: T,
        client: ClientType? = nil,
        platform: PlatformType? = nil
    ) async throws(LKError) {
        _ =
            try await self.sendRequest(
                path: path,
                requestData: requestData,
                client: client,
                platform: platform
            ) as EmptyResponse
    }
    /// 重载版本
    /// 适用于不需要请求体且不关心响应体的API调用
    @concurrent
    nonisolated func sendRequest(
        path: String,
        client: ClientType? = nil,
        platform: PlatformType? = nil
    ) async throws(LKError) {
        try await self.sendRequest(
            path: path,
            requestData: Optional<EmptyRequest>.none,
            client: client,
            platform: platform
        )
    }

    /// 获取服务端版本信息
    public func fetchServerVersion() async throws(LKError) -> UInt {
        self.logger.debug("获取服务器版本...")
        return try await self.sendRequest(
            path: "/smiley/get-ver"
        )
    }
}
