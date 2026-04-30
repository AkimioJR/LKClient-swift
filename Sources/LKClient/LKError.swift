//
//  LKError.swift
//  SwiftLK
//
//  Created by 秋澪 on 2026/1/1.
//

import Foundation

public enum LKError: Error, Sendable {
    static let missingRequestParameter: LKError = .apiError(code: 3)
    static let notSignedIn: LKError = .apiError(code: 5)

    case apiError(code: UInt)

    case apiEndpointError(String)
    case decodingError(Error)
    case networkError(Error)
    case base64DecodingError
    case zlibDecompressionError
    case apiEmptyDataError

    case unkownError(Error)
}

extension LKError {
    public var isCancelled: Bool {
        switch self {
        case .networkError(let err):
            return err is CancellationError || (err as? URLError)?.code == .cancelled
        case .unkownError(let err):
            return err is CancellationError
        default:
            return false
        }
    }
}

// MARK: - LocalizedError
extension LKError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .apiError(let code):
            switch code {
            // case 1: retunrn "" // 提交 aid 为0 导致的错误，不确定具体含义
            // case 2: retunrn "" // 登陆时密码错误
            case 3:
                return "缺少请求参数"
            case 5:
                return "未登录"
            // case 6: retunrn "未完成" // 可能是，不确定，从task api猜测
            // case 5001: // 文章不存在
            case 5002:
                return "已达到最大投币数"
            default:
                return "API 错误 (错误码: \(code))"
            }

        case .apiEndpointError(let message):
            return "API 地址错误: \(message)"

        case .apiEmptyDataError:
            return "服务器返回数据为空"

        case .base64DecodingError:
            return "Base64 解码失败"

        case .zlibDecompressionError:
            return "数据解压缩失败"

        case .decodingError(let error):
            return "数据解析失败: \(error.localizedDescription)"

        case .networkError(let error):
            return "网络请求失败: \(error.localizedDescription)"

        case .unkownError(let error):
            return "未知错误: \(error.localizedDescription)"
        }
    }
}
