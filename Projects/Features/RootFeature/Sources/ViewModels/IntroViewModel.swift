//
//  IntroViewModel.swift
//  RootFeature
//
//  Created by KTH on 2023/03/24.
//  Copyright © 2023 yongbeomkwak. All rights reserved.
//

import AppDomainInterface
import AuthDomainInterface
import BaseFeature
import ErrorModule
import Foundation
import LogManager
import RxCocoa
import RxSwift
import UserDomainInterface
import Utility

public final class IntroViewModel: ViewModelType {
    private let fetchUserInfoUseCase: FetchUserInfoUseCase
    private let fetchAppCheckUseCase: FetchAppCheckUseCase
    private let logoutUseCase: any LogoutUseCase
    private let checkIsExistAccessTokenUseCase: any CheckIsExistAccessTokenUseCase
    private let disposeBag = DisposeBag()

    public struct Input {
        let fetchPermissionCheck: PublishSubject<Void> = PublishSubject()
        let fetchAppCheck: PublishSubject<Void> = PublishSubject()
        let fetchUserInfoCheck: PublishSubject<Void> = PublishSubject()
        let endedLottieAnimation: PublishSubject<Void> = PublishSubject()
    }

    public struct Output {
        let permissionResult: PublishSubject<Bool?> = PublishSubject()
        let appInfoResult: PublishSubject<Result<AppCheckEntity, Error>> = PublishSubject()
        let userInfoResult: PublishSubject<Result<String, Error>> = PublishSubject()
        let endedLottieAnimation: PublishSubject<Void> = PublishSubject()
    }

    public init(
        fetchUserInfoUseCase: FetchUserInfoUseCase,
        fetchAppCheckUseCase: FetchAppCheckUseCase,
        logoutUseCase: any LogoutUseCase,
        checkIsExistAccessTokenUseCase: any CheckIsExistAccessTokenUseCase
    ) {
        self.fetchUserInfoUseCase = fetchUserInfoUseCase
        self.fetchAppCheckUseCase = fetchAppCheckUseCase
        self.logoutUseCase = logoutUseCase
        self.checkIsExistAccessTokenUseCase = checkIsExistAccessTokenUseCase
    }

    public func transform(from input: Input) -> Output {
        let output = Output()

        Observable.combineLatest(
            input.fetchPermissionCheck,
            Utility.PreferenceManager.$appPermissionChecked
        ) { _, permission -> Bool? in
            return permission
        }
        .bind(to: output.permissionResult)
        .disposed(by: disposeBag)

        input.endedLottieAnimation
            .bind(to: output.endedLottieAnimation)
            .disposed(by: disposeBag)

        input.fetchAppCheck
            .flatMap { [weak self] _ -> Observable<AppCheckEntity> in
                guard let self else { return Observable.empty() }
                return self.fetchAppCheckUseCase.execute()
                    .catch { error -> Single<AppCheckEntity> in
                        let wmError = error.asWMError
                        if wmError == .offline {
                            return Single<AppCheckEntity>.create { single in
                                single(
                                    .success(
                                        AppCheckEntity(
                                            flag: .offline,
                                            title: "",
                                            description: wmError.errorDescription ?? "",
                                            version: "",
                                            specialLogo: false
                                        )
                                    )
                                )
                                return Disposables.create()
                            }
                        } else {
                            return Single.error(error)
                        }
                    }
                    .asObservable()
            }
            .debug("✅ Intro > fetchCheckAppUseCase")
            .subscribe(onNext: { model in
                output.appInfoResult.onNext(.success(model))
            }, onError: { error in
                output.appInfoResult.onNext(.failure(error))
            })
            .disposed(by: disposeBag)

        input.fetchUserInfoCheck
            .withLatestFrom(Utility.PreferenceManager.$userInfo)
            .flatMap { [logoutUseCase, checkIsExistAccessTokenUseCase] userInfo in
                guard userInfo != nil else {
                    // 비로그인 상태인데, 키체인에 저장된 엑세스 토큰이 살아있다는건 로그인 상태로 앱을 삭제한 유저임
                    return checkIsExistAccessTokenUseCase.execute()
                        .asObservable()
                        .flatMap { isExist in
                            output.userInfoResult.onNext(.success(""))
                            if isExist {
                                return logoutUseCase.execute()
                                    .andThen(Observable.just(false))
                            } else {
                                return Observable.just(false)
                            }
                        }
                        .asObservable()
                }
                return Observable.just(true)
            }
            .filter { $0 }
            .flatMap { [fetchUserInfoUseCase] _ -> Observable<UserInfoEntity> in
                return fetchUserInfoUseCase.execute()
                    .asObservable()
            }
            .debug("✅ Intro > fetchUserInfoUseCase")
            .subscribe(
                onNext: { entity in
                    output.userInfoResult.onNext(.success(""))
                },
                onError: { error in
                    output.userInfoResult.onNext(.failure(error))
                }
            )
            .disposed(by: disposeBag)

        return output
    }
}
