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
    private let logger: Logger
    private let session: URLSession

    @MainActor
    private var securityKey: String

    @MainActor
    public func setSecurityKey(_ key: String) {
        self.securityKey = key
    }

    @MainActor
    public var userId: UInt {
        let paths = self.securityKey.split(separator: ":")
        if paths.count != 3 {
            return 0
        }
        return UInt(paths[1]) ?? 0
    }

    @MainActor
    public var isLoggedIn: Bool {
        return self.userId != 0
    }

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
            if dateString == "0000-00-00 00:00:00" || dateString.isEmpty {
                return Date(timeIntervalSince1970: 0)  // Unix epoch
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
    public var apiEndpoint: String
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
        apiEndpoint: String = "https://api.lightnovel.fun",
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

        self.apiEndpoint = apiEndpoint
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
        guard let url = await URL(string: self.apiEndpoint + path) else {
            throw await LKError.apiEndpointError("Invalid URL: \(self.apiEndpoint + path)")
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
            if R.self == EmptyResponse.self {
                return EmptyResponse() as! R
            } else if let responseData = resp.data {
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
        requestData: T?,
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

    // 获取服务端版本信息
    public func fetchServerVersion() async throws(LKError) -> UInt {
        self.logger.debug("获取服务器版本...")
        return try await self.sendRequest(
            path: "/api/smiley/get-ver"
        )
    }

    // 登录客户端
    public func login(username: String, password: String) async throws(LKError) -> UserProfileDetail
    {
        let loginRequest = LoginRequest(username: username, password: password)

        self.logger.debug("正在登录用户: \(username)")

        let loginResponse: UserProfileDetail = try await self.sendRequest(
            path: "/api/user/login",
            requestData: loginRequest,
        )

        if let key = loginResponse.securityKey {
            await self.setSecurityKey(key)
        }

        return loginResponse
    }

    // 获取用户信息
    public func fetchUserInfo(userId: UInt) async throws(LKError) -> UserProfileDetail {
        let req = GetUserInfoRequest(
            userId: userId,
            securityKey: await self.securityKey,
        )
        self.logger.debug("正在获取用户信息，userId: \(userId)")
        return try await self.sendRequest(
            path: "/api/user/info",
            requestData: req,
        )
    }

    // 关注/取消关注用户
    public func updateFollowStatus(userId: UInt, shouldFollow: Bool) async throws {
        self.logger.debug(
            "\(shouldFollow ? "关注" : "取消关注")用户(userId: \(userId))"
        )
        let req = FollowRequest(
            userId: userId, unFollow: !shouldFollow, securityKey: await self.securityKey)
        try await self.sendRequest(
            path: "/api/user/follow",
            requestData: req
        )
    }

    // 获取用户的文章
    public func fetchUserArticles(
        userId: UInt, articleType: ArticleType, page: UInt, pageSize: UInt = 20
    ) async throws(LKError) -> Page<UserArticleInfo> {
        self.logger.debug(
            "正在获取用户(userId: \(userId))文章: articleType: \(articleType), page: \(page), pageSize: \(pageSize) "
        )

        let req = FecthUserArticleRequest(
            userId: userId,
            articleType: articleType,
            page: page,
            pageSize: pageSize,
            securityKey: await self.securityKey
        )
        return try await self.sendRequest(
            path: "/api/user/get-articles",
            requestData: req,
        )
    }

    // 获取推荐项目
    public func fetchRecommendedGroups(classId: UInt) async throws(LKError) -> [RecommendGroup] {
        self.logger.debug("正在获取推荐项目，classId: \(classId)")
        let req = GetRecommendRequest(securityKey: await self.securityKey, classId: classId)

        return try await self.sendRequest(
            path: "/api/recom/get-recommends",
            requestData: req,
        )
    }
    // 获取用户关注动态
    public func fetchFollowingArticles(page: UInt, pageSize: UInt = 20) async throws
        -> [FollowingArticleInfo]
    {
        self.logger.debug("正在获取用户关注动态，page: \(page), pageSize: \(pageSize)")
        let req = FetchFollowingArticlesRequest(
            page: page,
            pageSize: pageSize,
            securityKey: await self.securityKey
        )

        return try await self.sendRequest(
            path: "/api/recom/get-follows",
            requestData: req,
        )
    }

    // 获取分区信息
    public func fetchParentGroups() async throws(LKError) -> [ParentGroupRecommendItems] {
        self.logger.debug("正在获取分区信息")
        let req = FetchParentGroupRecommendItemsRequest(securityKey: await self.securityKey)
        return try await self.sendRequest(
            path: "/api/group/main",
            requestData: req,
        )
    }

    // 获取分类下文章
    public func fetchCategoryArticles(
        groupId: GroupId, parentGroupId: ParentGroupId, page: UInt, pageSize: UInt = 40
    ) async throws(LKError) -> Page<ArticleInfo> {
        self.logger.debug(
            "正在获取分类下文章，groupId: \(groupId), parentGroupId: \(parentGroupId), page: \(page), pageSize: \(pageSize)"
        )
        let req = FetchCategoryArticlesInfoRequest(
            securityKey: await self.securityKey,
            groupId: groupId,
            parentGroupId: parentGroupId,
            page: page,
            pageSize: pageSize,
        )

        return try await self.sendRequest(
            path: "/api/category/get-article-by-cate",
            requestData: req,
        )
    }

    // 获取文章详情
    public func fetchArticleDetail(articleId: UInt, includeContent: Bool) async throws
        -> ArticleDetail
    {
        self.logger.debug(
            "正在获取文章详情，articleId: \(articleId), includeContent: \(includeContent)"
        )
        let req = FetchArticleDetailRequest(
            securityKey: await self.securityKey,
            articleId: articleId,
            simple: !includeContent,
        )

        return try await self.sendRequest(
            path: "/api/article/get-detail",
            requestData: req,
        )
    }

    // 获取文章 tag
    public func fetchArticleTags(articleId: UInt) async throws(LKError) -> [ArticleTag] {
        self.logger.debug("正在获取文章标签，articleId: \(articleId)")
        let req = ArticleRequest(securityKey: await self.securityKey, articleId: articleId)
        return try await self.sendRequest(
            path: "/api/tag/get-article-tags",
            requestData: req,
        )
    }

    // 点赞文章
    public func likeArticle(articleId: UInt) async throws {
        self.logger.debug("正在点赞文章，articleId: \(articleId)")
        let req = ArticleRequest(securityKey: await self.securityKey, articleId: articleId)
        try await self.sendRequest(
            path: "/api/article/like",
            requestData: req,
        )
    }

    private func applyRecordChange(req: RecordRequest, path: String) async throws {
        try await self.sendRequest(
            path: path,
            requestData: req,
        )
    }

    // 添加历史记录
    public func addHistory(favoriteId: UInt, classType: ClassType) async throws {
        self.logger.debug("正在添加历史记录，favoriteId: \(favoriteId), classType: \(classType)")
        let req = RecordRequest(
            favoriteId: favoriteId,
            classType: classType,
            securityKey: await self.securityKey,
        )
        try await self.applyRecordChange(
            req: req,
            path: "/api/history/add-history"
        )
    }

    // 添加收藏
    public func addFavorite(favoriteId: UInt, classType: ClassType) async throws {
        self.logger.debug("正在添加收藏，favoriteId: \(favoriteId), classType: \(classType)")
        let req = RecordRequest(
            favoriteId: favoriteId,
            classType: classType,
            securityKey: await self.securityKey,
        )
        try await self.applyRecordChange(
            req: req,
            path: "/api/history/add-collection"
        )
    }

    // 删除收藏
    public func deleteFavorite(favoriteId: UInt, classType: ClassType) async throws {
        self.logger.debug("正在删除收藏，favoriteId: \(favoriteId), classType: \(classType)")
        let req = RecordRequest(
            favoriteId: favoriteId,
            classType: classType,
            securityKey: await self.securityKey,
        )
        try await self.applyRecordChange(
            req: req,
            path: "/api/history/del-collection",
        )
    }

    // 查询历史记录
    public func fetchHistoryRecords<T: Decodable>(
        type: ArticleType, classType: ClassType, page: UInt, pageSize: UInt = 40
    ) async throws(LKError) -> Page<T> {
        self.logger.debug(
            "正在查询历史记录，type: \(type), classType: \(classType), page: \(page), pageSize: \(pageSize)"
        )
        let req = FetchRecordRequest(
            type: type,
            classType: classType,
            page: page,
            pageSize: pageSize,
            userId: await self.userId,
            securityKey: await self.securityKey,
        )
        return try await self.sendRequest(
            path: "/api/history/get-history",
            requestData: req,
        )
    }

    // 查询收藏列表
    public func fetchFavoriteRecords<T: Decodable>(
        type: ArticleType, classType: ClassType, page: UInt, pageSize: UInt = 40
    ) async throws(LKError) -> Page<T> {
        self.logger.debug(
            "正在查询收藏记录，type: \(type), classType: \(classType), page: \(page), pageSize: \(pageSize)"
        )
        let req = FetchRecordRequest(
            type: type,
            classType: classType,
            page: page,
            pageSize: pageSize,
            userId: await self.userId,
            securityKey: await self.securityKey,
        )
        return try await self.sendRequest(
            path: "/api/history/get-collections",
            requestData: req,
        )
    }

    // 查询集合信息
    public func fetchSeries(seriesId: UInt) async throws(LKError) -> SeriesInfo {
        self.logger.debug("正在查询集合信息，seriesId: \(seriesId)")
        let req = GetSeriesRequest(seriesId: seriesId, securityKey: await self.securityKey)
        return try await self.sendRequest(
            path: "/api/series/get-info",
            requestData: req,
        )
    }

    // 查询集合评价
    public func fetchSeriesRatings(seriesId: UInt, page: UInt) async throws(LKError)
        -> Page<SeriesRateInfo>
    {
        self.logger.debug("正在查询集合评价，seriesId: \(seriesId), page: \(page)")
        let req = GetSeriesRateRequest(
            seriesId: seriesId, page: page, securityKey: await self.securityKey)
        return try await self.sendRequest(
            path: "/api/series/get-rate-list",
            requestData: req,
        )
    }

    // 获取热门搜索词条
    public func fetchHotSearchTags() async throws(LKError) -> [HotSearchTag] {
        self.logger.debug("正在获取热门搜索词条...")
        return try await self.sendRequest(
            path: "/api/search/get-search-tags"
        )
    }

    // 搜索用户
    public func searchUser(query: String, page: UInt) async throws(LKError) -> Page<
        UserSearchData
    > {
        let req = FetchSearchRequest(
            query: query, type: .user, page: page, securityKey: await self.securityKey)
        return try await self.sendRequest(
            path: "/api/search/search-result",
            requestData: req,
        )
    }
    // 搜索集合
    public func searchSeries(query: String, page: UInt) async throws(LKError) -> Page<
        SeriesSearchData
    > {
        self.logger.debug("正在搜索集合，query: \(query), page: \(page)")
        let req = FetchSearchRequest(
            query: query, type: .series, page: page, securityKey: await self.securityKey)
        return try await self.sendRequest(
            path: "/api/search/search-result",
            requestData: req,
        )
    }
    // 搜索文章
    public func searchArticle(query: String, page: UInt, searchType: SearchType)
        async throws(LKError) -> Page<ArticleSearchData>
    {
        self.logger.debug("正在搜索文章，query: \(query), page: \(page), searchType: \(searchType)")
        let req = FetchSearchRequest(
            query: query, type: searchType, page: page, securityKey: await self.securityKey)
        return try await self.sendRequest(
            path: "/api/search/search-result",
            requestData: req,
        )
    }
    // 搜索资讯
    public func searchNews(query: String, page: UInt) async throws(LKError) -> Page<
        ArticleSearchData
    > {
        return try await self.searchArticle(query: query, page: page, searchType: .news)
    }
    // 搜索动画
    public func searchAnime(query: String, page: UInt) async throws(LKError) -> Page<
        ArticleSearchData
    > {
        return try await self.searchArticle(query: query, page: page, searchType: .anime)
    }
    // 搜索漫画
    public func searchManga(query: String, page: UInt) async throws(LKError) -> Page<
        ArticleSearchData
    > {
        return try await self.searchArticle(query: query, page: page, searchType: .manga)
    }
    // 搜索轻小说
    public func searchLightnovel(query: String, page: UInt) async throws(LKError)
        -> Page<ArticleSearchData>
    {
        return try await self.searchArticle(query: query, page: page, searchType: .lightnovel)
    }

    // 获取文章评论话题讨论
    public func fetchArticleTopics(articleId: UInt, page: UInt, pageSize: UInt = 20) async throws
        -> Page<TopicInfo>
    {
        self.logger.debug(
            "正在获取文章评论话题讨论，articleId: \(articleId), page: \(page), pageSize: \(pageSize)")
        let req = GetDiscussTopicsRequest(
            articleId: articleId,
            page: page,
            pageSize: pageSize,
            securityKey: await self.securityKey
        )
        return try await self.sendRequest(
            path: "/api/discuss/get-topic",
            requestData: req,
        )
    }
    // 发布文章评论话题
    public func postDiscussionTopic(articleId: UInt, content: String) async throws(LKError) -> UInt
    {
        self.logger.debug("正在发布文章评论话题，articleId: \(articleId), content: \(content)")
        let req = PostDiscussTopicRequest(
            articleId: articleId,
            content: content,
            securityKey: await self.securityKey
        )
        return try await self.sendRequest(
            path: "/api/discuss/post-topic",
            requestData: req,
        )
    }
    // 点赞评论话题
    public func likeDiscussionTopic(topicId: UInt) async throws {
        self.logger.debug("正在点赞评论话题，topicId: \(topicId)")
        let req = LikeTopicRequest(
            topicId: topicId,
            securityKey: await self.securityKey
        )
        try await self.sendRequest(
            path: "/api/discuss/like",
            requestData: req,
        )
    }

    // MARK: - 任务 Task
    // 获取任务列表
    public func fetchTaskList() async throws(LKError) -> TaskList {
        self.logger.debug("正在获取任务列表...")
        let req = TaskListRequest(securityKey: await self.securityKey)
        return try await self.sendRequest(
            path: "/api/task/list",
            requestData: req,
        )
    }
    // 完成任务
    public func completeTask(type: TaskType) async throws(LKError) -> TaskCompleteResponse {
        self.logger.debug("正在完成任务，type: \(type)")
        let req = TaskCompleteRequest(type: type, securityKey: await self.securityKey)
        return try await self.sendRequest(
            path: "/api/task/complete",
            requestData: req,
        )
    }

    // 上传图片
    public func uploadImage(data: Data, filename: String, mimeType: String = "image/png")
        async throws -> UploadImageResponse
    {
        // 计算图片的 MD5
        let md5Hash = data.md5

        // 构建上传 URL
        guard let url = URL(string: self.apiEndpoint + "/upload/discuss-image") else {
            throw LKError.apiEndpointError("Invalid upload URL")
        }

        // 创建 boundary
        let boundary = "dart-http-boundary-\(UUID().uuidString)"

        // 构建 multipart/form-data body
        var body = Data()

        // 添加 'd' 字段 (JSON 数据)
        let dJSON = """
            {"md5":"\(md5Hash)","security_key":"\(await self.securityKey)"}
            """
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("content-disposition: form-data; name=\"d\"\r\n\r\n".data(using: .utf8)!)
        body.append(dJSON.data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)

        // 添加 'md5' 字段
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("content-disposition: form-data; name=\"md5\"\r\n\r\n".data(using: .utf8)!)
        body.append(md5Hash.data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)

        // 添加 'file' 字段 (图片文件)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("content-type: \(mimeType)\r\n".data(using: .utf8)!)
        body.append(
            "content-disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n\r\n".data(
                using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)

        // 结束边界
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        // 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        request.httpBody = body

        // 发送请求
        let (data, _) = try await URLSession.shared.data(for: request)

        // 解析响应
        let response = try Self.jsonDecoder.decode(
            LKResponse<UploadImageResponse>.self, from: data)

        guard let responseData = response.data else {
            throw LKError.apiEmptyDataError
        }

        return responseData
    }
}

extension Data {
    var md5: String {
        let digest = Insecure.MD5.hash(data: self)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
