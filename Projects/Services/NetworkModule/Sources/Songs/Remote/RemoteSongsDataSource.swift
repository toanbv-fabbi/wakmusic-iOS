import DataMappingModule
import ErrorModule
import DomainModule
import RxSwift
import Foundation

public protocol RemoteSongsDataSource {
    func fetchSearchSong(keyword: String) -> Single<SearchResultEntity>
    func fetchLyrics(id: String) -> Single<[LyricsEntity]>
    func fetchNewSongs(type: NewSongGroupType, page: Int, limit: Int) -> Single<[NewSongsEntity]>
}
