public enum CoinUsage: UInt8, Codable, Sendable {
    case payForArticle = 1  // 投币支付
    case rewardArticle = 2  // 打赏文章
    case redeemMedal = 5  // 兑换勋章
}

struct UseCoinRequest: Codable, Sendable {
    var usage: CoinUsage
    var params: UInt
    var number: UInt
    var price: UInt
    var totalPrice: UInt
    var securityKey: String

    enum CodingKeys: String, CodingKey {
        case usage = "goods_id"
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
        for usage: CoinUsage,
        params: UInt,
        number: UInt,
        price: UInt,
    ) async throws(LKError) {
        let totalPrice = number * price
        self.logger.debug(
            "正在使用投币，usage: \(String(describing: usage)), params: \(params), number: \(number), price: \(price), totalPrice: \(totalPrice)"
        )
        let req = await UseCoinRequest(
            usage: usage,
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
    public func useCoin(
        for usage: CoinUsage,
        params: UInt,
        number: UInt,
    ) async throws(LKError) {
        try await self.useCoin(
            for: usage,
            params: params,
            number: number,
            price: 1
        )
    }
    public func useCoin(
        for usage: CoinUsage,
        params: UInt,
        price: UInt,
    ) async throws(LKError) {
        try await self.useCoin(
            for: usage,
            params: params,
            number: 1,
            price: price,
        )
    }

    /// 打赏文章
    public func rewardedArticle(for articleId: UInt, count: UInt) async throws(LKError) {
        try await self.useCoin(
            for: .rewardArticle,
            params: articleId,
            number: count,
        )
    }

    /// 投币支付
    public func payArticle(for articleId: UInt, price: UInt) async throws(LKError) {
        try await self.useCoin(
            for: .payForArticle,
            params: articleId,
            price: price,
        )
    }
    /// 兑换勋章
    public func redeemMedal(for medalId: UInt, price: UInt) async throws(LKError) {
        try await self.useCoin(
            for: .redeemMedal,
            params: medalId,
            price: price,
        )
    }
}
