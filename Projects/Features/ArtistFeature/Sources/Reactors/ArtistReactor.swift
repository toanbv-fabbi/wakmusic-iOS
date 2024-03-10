import ArtistDomainInterface
import ReactorKit
import Utility

public final class ArtistReactor: Reactor {
    public enum Action {
        case viewDidLoad
    }

    public enum Mutation {
        case updateArtistList([ArtistListEntity])
    }

    public struct State {
        var artistList: [ArtistListEntity]
    }

    public var initialState: State

    private let fetchArtistListUseCase: any FetchArtistListUseCase

    init(
        fetchArtistListUseCase: any FetchArtistListUseCase
    ) {
        self.fetchArtistListUseCase = fetchArtistListUseCase
        self.initialState = .init(
            artistList: []
        )
    }

    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return fetchArtistListUseCase.execute()
                .catchAndReturn([])
                .asObservable()
                .map { [weak self] artistList in
                    guard let self, !artistList.isEmpty else {
                        DEBUG_LOG("데이터가 없습니다.")
                        return artistList
                    }
                    var newArtistList = artistList

                    if newArtistList.count == 1 {
                        let hiddenItem: ArtistListEntity = self.makeHiddenArtistEntity()
                        newArtistList.append(hiddenItem)
                    } else {
                        newArtistList.swapAt(0, 1)
                    }
                    return newArtistList
                }
                .map(Mutation.updateArtistList)

        default:
            return .empty()
        }
    }

    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .updateArtistList(artistList):
            newState.artistList = artistList
        }
        return newState
    }
}

private extension ArtistReactor {
    func makeHiddenArtistEntity() -> ArtistListEntity {
        ArtistListEntity(
            artistId: "",
            name: "",
            short: "",
            group: "",
            title: "",
            description: "",
            color: [],
            youtube: "",
            twitch: "",
            instagram: "",
            imageRoundVersion: 0,
            imageSquareVersion: 0,
            graduated: false,
            isHiddenItem: true
        )
    }
}
