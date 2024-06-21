import BaseDomainInterface
import Foundation
import RxSwift
import SongsDomainInterface

public protocol SearchRepository {
    func fetchSearchSongs(order: SortType, filter: FilterType, text: String, page: Int, limit: Int)
        -> Single<[SongEntity]>
    func fetchSearchPlaylist(order: SortType, text: String, page: Int, limit: Int) -> Single<[SearchPlaylistEntity]>
}