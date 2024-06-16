import AuthDomainInterface
import BaseDomain
import ErrorModule
import Foundation
import Moya

public enum AuthAPI {
    case fetchToken(providerType: ProviderType, token: String)
    case reGenerateAccessToken
}

private struct FetchTokenRequestParameters: Encodable {
    var provider: String
    var token: String
}

extension AuthAPI: WMAPI {
    public var baseURL: URL {
        return URL(string: BASE_URL())!
    }

    public var domain: WMDomain {
        return .auth
    }

    public var urlPath: String {
        switch self {
        case .fetchToken:
            return "/app"
        case .reGenerateAccessToken:
            return "/token"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .fetchToken:
            return .post
        case .reGenerateAccessToken:
            return .post
        }
    }

    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }

    public var task: Moya.Task {
        switch self {
        case let .fetchToken(providerType: providerType, token: id):
            return .requestJSONEncodable(
                FetchTokenRequestParameters(
                    provider: providerType.rawValue,
                    token: id
                )
            )
        case .reGenerateAccessToken:
            return .requestPlain
        }
    }

    public var jwtTokenType: JwtTokenType {
        return .none
    }

    public var errorMap: [Int: WMError] {
        switch self {
        default:
            return [
                400: .badRequest,
                401: .tokenExpired,
                404: .notFound,
                429: .tooManyRequest,
                500: .internalServerError
            ]
        }
    }
}
