import BaseDomain
import BaseDomainInterface
import Foundation
import PlayListDomainInterface
import RxSwift
import SongsDomain
import SongsDomainInterface

public final class RemotePlayListDataSourceImpl: BaseRemoteDataSource<PlayListAPI>, RemotePlayListDataSource {
    public func fetchRecommendPlayList() -> Single<[RecommendPlayListEntity]> {
        request(.fetchRecommendPlayList)
            .map([SingleRecommendPlayListResponseDTO].self)
            .map { $0.map { $0.toDomain() }}
    }

    public func fetchPlayListDetail(id: String, type: PlayListType) -> Single<PlayListDetailEntity> {
        request(.fetchPlayListDetail(id: id, type: type))
            .map(SinglePlayListDetailResponseDTO.self)
            .map { $0.toDomain() }
    }

    public func updateTitleAndPrivate(key: String, title: String?, isPrivate: Bool?) -> Completable {
        request(.updateTitleAndPrivate(id: key, title: title, isPrivate: isPrivate))
            .asCompletable()
    }

    public func createPlayList(title: String) -> Single<PlayListBaseEntity> {
        request(.createPlayList(title: title))
            .map(PlayListBaseResponseDTO.self)
            .map { $0.toDomain() }
    }

    public func fetchPlaylistSongs(id: String) -> Single<[SongEntity]> {
        request(.fetchPlaylistSongs(id: id))
            .map([SingleSongResponseDTO].self)
            .map { $0.map { $0.toDomain() } }
    }

    public func updatePlaylist(key: String, songs: [String]) -> Single<BaseEntity> {
        request(.updatePlaylist(key: key, songs: songs))
            .map(BaseResponseDTO.self)
            .map { $0.toDomain() }
    }

    public func loadPlayList(key: String) -> Single<PlayListBaseEntity> {
        request(.loadPlayList(key: key))
            .map(PlayListBaseResponseDTO.self)
            .map { $0.toDomain() }
    }

    public func addSongIntoPlayList(key: String, songs: [String]) -> Single<AddSongEntity> {
        request(.addSongIntoPlayList(key: key, songs: songs))
            .map(AddSongResponseDTO.self)
            .map { $0.toDomain() }
    }

    public func removeSongs(key: String, songs: [String]) -> Single<BaseEntity> {
        request(.removeSongs(key: key, songs: songs))
            .map(BaseResponseDTO.self)
            .map { $0.toDomain() }
    }
}
