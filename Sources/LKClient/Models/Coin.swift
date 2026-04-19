public enum UseCoinType: UInt8, Codable, Sendable {
    case payForArticle = 1  // 投币支付
    case rewardArticle = 2  // 打赏文章
}

struct UseCoinRequest: Codable, Sendable {
    var type: UseCoinType
    var params: UInt
    var number: UInt
    var price: UInt
    var totalPrice: UInt
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case type = "goods_id"
        case number = "number"
        case params = "params"
        case price = "price"
        case totalPrice = "total_price"
        case securityKey = "security_key"
    }
}

/// MARK: - 硬币相关
extension LKClient {
    /// 使用硬币
    public func useCoin(
        type: UseCoinType,
        params: UInt,
        number: UInt = 1,
        price: UInt = 1,
    ) async throws(LKError) {
        let totalPrice = number * price
        self.logger.debug(
            "正在使用投币，type: \(String(describing: type)), params: \(params), number: \(number), price: \(price), totalPrice: \(totalPrice)"
        )
        let req = await UseCoinRequest(
            type: type,
            params: params,
            number: number,
            price: price,
            totalPrice: totalPrice,
            securityKey: self.securityKey
        )

        try await self.sendRequest(
            path: "/api/coin/use",
            requestData: req,
        )
    }

    /// 打赏文章
    public func rewardedArticle(for articleId: UInt, count: UInt) async throws(LKError) {
        try await self.useCoin(
            type: .rewardArticle,
            params: articleId,
            number: count,
            price: 1,
        )
    }

    /// 投币支付
    public func payForArticle(articleId: UInt, price: UInt) async throws(LKError) {
        try await self.useCoin(
            type: .payForArticle,
            params: articleId,
            number: 1,
            price: price,
        )
    }
}
