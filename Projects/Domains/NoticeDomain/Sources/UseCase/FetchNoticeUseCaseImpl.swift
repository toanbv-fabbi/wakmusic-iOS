//
//  FetchNoticeUseCaseImpl.swift
//  DataModule
//
//  Created by KTH on 2023/04/08.
//  Copyright © 2023 yongbeomkwak. All rights reserved.
//

import Foundation
import RxSwift
import NoticeDomainInterface

public struct FetchNoticeUseCaseImpl: FetchNoticeUseCase {
    private let noticeRepository: any NoticeRepository

    public init(
        noticeRepository: NoticeRepository
    ) {
        self.noticeRepository = noticeRepository
    }

    public func execute(type: NoticeType) -> Single<[FetchNoticeEntity]> {
        noticeRepository.fetchNotice(type: type)
    }
}