//
//  FetchArtistListUseCaseImpl.swift
//  DataModule
//
//  Created by KTH on 2023/02/08.
//  Copyright © 2023 yongbeomkwak. All rights reserved.
//

import Foundation
import RxSwift
import DataMappingModule
import DomainModule
import ErrorModule

public struct FetchNaverUserInfoUseCaseImpl: FetchNaverUserInfoUseCase {
    
    
    
    private let authRepository: any AuthRepository
    
    public init(authRepository: any AuthRepository) {
        self.authRepository = authRepository
    }
    

    public func execute(tokenType: String, accessToken: String) ->Single<NaverUserInfoEntity> {
        authRepository.fetchNaverUserInfo(tokenType: tokenType, accessToken: accessToken)
    }
   
    
    


}
