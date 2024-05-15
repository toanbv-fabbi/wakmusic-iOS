//
//  RecommendPlayListResponseDTO.swift
//  DataMappingModuleTests
//
//  Created by yongbeomkwak on 2023/02/10.
//  Copyright © 2023 yongbeomkwak. All rights reserved.
//

import Foundation
import PlayListDomainInterface
import SongsDomain
import SongsDomainInterface
import Utility

public struct SinglePlayListDetailResponseDTO: Decodable {
    public let key: String?
    public let title: String
    public let songs: [SingleSongResponseDTO]?
    public let image: SinglePlayListDetailResponseDTO.Image
}

public extension SinglePlayListDetailResponseDTO {
    struct Image: Decodable {
        public let round: Int?
        public let square: Int?
        public let name: String?
        public let version: Int?
    }
}

public extension SinglePlayListDetailResponseDTO {
    func toDomain() -> PlayListDetailEntity {
        PlayListDetailEntity(
            key: key ?? "",
            title: title,
            songs: (songs ?? []).map { dto in
                return SongEntity(
                    id: dto.songID,
                    title: dto.title,
                    artist: dto.artists.joined(separator: ", "),
                    remix: "",
                    reaction: "",
                    views: dto.views,
                    last: 0,
                    date: dto.date.changeDateFormat(origin: "yyMMdd", result: "yyyy.MM.dd")
                )
            },
            image: image.name ?? "",
            image_square_version: image.square ?? 0,
            image_round_version: image.round ?? 0,
            version: image.version ?? 0
        )
    }
}
