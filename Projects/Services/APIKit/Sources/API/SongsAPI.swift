import Moya
import DataMappingModule
import ErrorModule
import Foundation

public enum SongsAPI {
    case fetchSearchSong(type: SearchType,keyword: String)
    case fetchLyrics(id: String)
}

extension SongsAPI: WMAPI {

    public var domain: WMDomain {
        .songs
    }

    public var urlPath: String {
        switch self {
        case .fetchSearchSong:
            return "/search"
        case .fetchLyrics(id: let id):
            return "/lyrics/\(id)"
        }
    }
        
        public var method: Moya.Method {
            return .get
        }
        
        public var task: Moya.Task {
            switch self {
            case let .fetchSearchSong(type,keyword):
                return .requestParameters(parameters: [
                    "type": type.rawValue,
                    "sort": "popular", //기본 인기순으로
                    "keyword": keyword
                ], encoding: URLEncoding.queryString)
                
                
            case .fetchLyrics:
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
