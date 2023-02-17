//
//  SearchViewModel.swift
//  SearchFeature
//
//  Created by yongbeomkwak on 2023/01/05.
//  Copyright © 2023 yongbeomkwak. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import BaseFeature
import DomainModule
import Utility
import NaverThirdPartyLogin
import AuthenticationServices
import KeychainModule

public  final class LoginViewModel:NSObject, ViewModelType {
    // 네이버 델리게이트를 받기위한 NSObject 상속
   
    var input = Input()
    var output = Output()
    
    let naverLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    var fetchTokenUseCase: FetchTokenUseCase!
    var fetchNaverUserInfoUseCase: FetchNaverUserInfoUseCase!
    var fetchUserInfoUseCase: FetchUserInfoUseCase!
    
    var disposeBag = DisposeBag()
    var naverToken:PublishSubject<(String,String)> = PublishSubject()
    var appleToken:PublishSubject<String> = PublishSubject()
    var fetchedWMToken: PublishSubject<String> = PublishSubject()
    
    public init(
        fetchTokenUseCase: FetchTokenUseCase,
        fetchNaverUserInfoUseCase: FetchNaverUserInfoUseCase,
        fetchUserInfoUseCase: FetchUserInfoUseCase
    ){
        super.init()
        
        self.naverLoginInstance?.delegate = self
        self.fetchTokenUseCase = fetchTokenUseCase
        self.fetchNaverUserInfoUseCase = fetchNaverUserInfoUseCase
        self.fetchUserInfoUseCase = fetchUserInfoUseCase
        
        DEBUG_LOG("✅ \(Self.self) 생성")
        
        //MARK: 네이버 로그인 및 이벤트
        input.pressNaverLoginButton
            .subscribe(onNext: {
                self.naverLoginInstance?.requestThirdPartyLogin()
                //self.naverLoginInstance?.requestDeleteToken() //로그아웃
        }).disposed(by: disposeBag)
      
        naverToken
            .flatMap{ [weak self] (tokenType:String,accessToken:String) -> Observable<NaverUserInfoEntity> in
                guard let self = self else{
                    return Observable.empty()
                }
                return self.fetchNaverUserInfoUseCase.execute(
                    tokenType: tokenType,
                    accessToken: accessToken
                )
                .asObservable()
                .catchAndReturn(NaverUserInfoEntity(resultcode: "", message: "", id: "", nickname: ""))
            }
            .filter{ !$0.id.isEmpty }
            .map{ $0.id }
            .flatMap { [weak self] (id:String) -> Observable<AuthLoginEntity> in
                guard let self = self else{
                    return Observable.empty()
                }
                return self.fetchTokenUseCase.execute(id: id, type: .naver)
                    .catchAndReturn(AuthLoginEntity(token: ""))
                    .asObservable()
            }
            .map { $0.token }
            .filter { !$0.isEmpty }
            .do(onNext: {
                let keychain = KeychainImpl()
                keychain.save(type: .accessToken, value: $0)
            })
            .bind(to: fetchedWMToken)
            .disposed(by: disposeBag)

        //MARK: 애플로그인 및 이벤트
        input.pressAppleLoginButton.subscribe(onNext: { [weak self] _ in
            guard let self = self else{
                return
            }
            
            let appleIdProvider = ASAuthorizationAppleIDProvider()
            let request = appleIdProvider.createRequest()
            request.requestedScopes = [.fullName,.email]
            
            let auth = ASAuthorizationController(authorizationRequests: [request])
            auth.delegate = self
            auth.presentationContextProvider = self
            auth.performRequests()
            
        }).disposed(by: disposeBag)
        
        appleToken
            .filter{ !$0.isEmpty }
            .flatMap { [weak self] (id:String) -> Observable<AuthLoginEntity> in
                guard let self = self else{
                    return Observable.empty()
                }
                
                return self.fetchTokenUseCase.execute(id: id, type: .apple)
                        .catchAndReturn(AuthLoginEntity(token: ""))
                        .asObservable()
            }
            .map { $0.token }
            .filter { !$0.isEmpty }
            .do(onNext: {
                let keychain = KeychainImpl()
                keychain.save(type: .accessToken, value: $0)
            })
            .bind(to: fetchedWMToken)
            .disposed(by: disposeBag)
                
        //MARK: WM 로그인 이후 얻은 토큰으로 유저 정보 조회 및 저장
        fetchedWMToken
            .flatMap { (token) -> Observable<AuthUserInfoEntity> in
                return self.fetchUserInfoUseCase.execute(token: token)
                    .catchAndReturn(AuthUserInfoEntity(
                        id: "",
                        platform: "",
                        displayName: "",
                        first_login_time: 0,
                        first: false,
                        profile: "")
                    )
                    .asObservable()
            }
            .subscribe(onNext: {
                DEBUG_LOG($0)
                PreferenceManager.shared.setUserInfo(
                    ID: $0.id,
                    platform: $0.platform,
                    profile: $0.profile,
                    displayName: $0.displayName,
                    firstLoginTime: $0.first_login_time,
                    first: $0.first
                )
            })
            .disposed(by: disposeBag)
    }

    public struct Input {
        let pressNaverLoginButton:PublishRelay<Void> = PublishRelay()
        let pressAppleLoginButton:PublishRelay<Void> = PublishRelay()
    }

    public struct Output {
     
    }
    
    public func transform(from input: Input) -> Output {
        let output = Output()
        return output
    }
}

extension LoginViewModel :NaverThirdPartyLoginConnectionDelegate{
        
    public func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
    
        guard let accessToken = naverLoginInstance?.isValidAccessTokenExpireTimeNow() else { return }
                
        if !accessToken {
          return
        }
                
        guard let tokenType = naverLoginInstance?.tokenType else { return }
        guard let accessToken = naverLoginInstance?.accessToken else { return }
        
        naverToken.onNext((tokenType, accessToken))
    }
    
    public func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        
        guard let accessToken = naverLoginInstance?.isValidAccessTokenExpireTimeNow() else { return }
                
        if !accessToken {
          return
        }
                
        guard let tokenType = naverLoginInstance?.tokenType else { return }
        guard let accessToken = naverLoginInstance?.accessToken else { return }
        
        naverToken.onNext((tokenType, accessToken))
    }
    
    public func oauth20ConnectionDidFinishDeleteToken() {
        DEBUG_LOG("네이버 로그아웃")
    }
    
    public func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        DEBUG_LOG("에러 = \(error.localizedDescription)")
    }
}

extension LoginViewModel:ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding{

    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.last!
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {

            let userIdentifer = credential.user
            let username = credential.fullName! // 무작위 유저네임
            
            DEBUG_LOG(userIdentifer)
            appleToken.onNext(userIdentifer)
        }
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        DEBUG_LOG("Apple Login Fail")
    }
}
