import RxSwift
import DataMappingModule
import ErrorModule
import Foundation

public protocol AuthRepository {
    func fetchToken(token:String,type:ProviderType) -> Single<AuthLoginEntity>
    func fetchNaverUserInfo(tokenType:String,accessToken:String) -> Single<NaverUserInfoEntity>

}
