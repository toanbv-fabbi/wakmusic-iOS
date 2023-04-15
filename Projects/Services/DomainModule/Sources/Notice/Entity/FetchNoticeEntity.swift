//
//  FetchNoticeEntity.swift
//  DomainModuleTests
//
//  Created by KTH on 2023/04/08.
//  Copyright © 2023 yongbeomkwak. All rights reserved.
//

import Foundation

public struct FetchNoticeEntity: Codable {
    public init (
        id: Int,
        category: String,
        title: String,
        content: String?,
        images: [String],
        createAt: Double,
        startAt: Double,
        endAt: Double
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.content = content
        self.images = images
        self.createAt = createAt
        self.startAt = startAt
        self.endAt = endAt
    }

    public let id: Int
    public let category, title: String
    public let content: String?
    public let images: [String]
    public let createAt, startAt, endAt: Double
}