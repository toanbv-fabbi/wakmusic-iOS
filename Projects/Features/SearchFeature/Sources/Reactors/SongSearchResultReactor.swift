import LogManager
import ReactorKit
import SearchDomainInterface
import SongsDomainInterface

final class SongSearchResultReactor: Reactor {
    enum Action {
        case viewDidLoad
        case changeSortType(SortType)
        case changeFilterType(FilterType)
        case askLoadMore
    }

    enum Mutation {
        case updateSortType(SortType)
        case updateFilterType(FilterType)
        case updateDataSource(dataSource: [SongEntity], canLoad: Bool)
        case updateSelectedCount(Int)
        case updateLoadingState(Bool)
        case updateScrollPage(Int)
    }

    struct State {
        var isLoading: Bool
        var sortType: SortType
        var filterType: FilterType
        var selectedCount: Int
        var scrollPage: Int
        var dataSource: [SongEntity]
        var canLoad: Bool
    }

    var initialState: State

    private let fetchSearchSongsUseCase: any FetchSearchSongsUseCase
    private let text: String
    private let limit: Int = 20

    init(text: String, fetchSearchSongsUseCase: any FetchSearchSongsUseCase) {
        self.initialState = State(
            isLoading: true,
            sortType: .latest,
            filterType: .all,
            selectedCount: 0,
            scrollPage: 1,
            dataSource: [],
            canLoad: true
        )

        self.text = text
        self.fetchSearchSongsUseCase = fetchSearchSongsUseCase
    }

    func mutate(action: Action) -> Observable<Mutation> {
        let state = self.currentState

        switch action {
        case .viewDidLoad, .askLoadMore:
            return updateDataSource(
                order: state.sortType,
                filter: state.filterType,
                text: self.text,
                scrollPage: state.scrollPage
            )
        case let .changeSortType(type):
            return updateSortType(type)
        case let .changeFilterType(type):
            return updateFilterType(type)
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case let .updateSortType(type):
            newState.sortType = type
        case let .updateFilterType(type):
            newState.filterType = type
        case let .updateDataSource(dataSource, canLoad):
            newState.dataSource = dataSource
            newState.canLoad = canLoad

        case let .updateSelectedCount(count):
            break

        case let .updateLoadingState(isLoading):
            newState.isLoading = isLoading

        case let .updateScrollPage(page):
            newState.scrollPage = page
        }

        return newState
    }
}

extension SongSearchResultReactor {
    private func updateSortType(_ type: SortType) -> Observable<Mutation> {
        let state = self.currentState

        return .concat([
            .just(.updateSortType(type)),
            updateDataSource(order: type, filter: state.filterType, text: self.text, scrollPage: 1, byOption: true)
        ])
    }

    private func updateFilterType(_ type: FilterType) -> Observable<Mutation> {
        let state = self.currentState

        return .concat([
            .just(.updateFilterType(type)),
            updateDataSource(order: state.sortType, filter: type, text: self.text, scrollPage: 1, byOption: true)
        ])
    }

    private func updateDataSource(
        order: SortType,
        filter: FilterType,
        text: String,
        scrollPage: Int,
        byOption: Bool = false // 필터또는 옵션으로 리프래쉬 하나 , 아니면 스크롤이냐
    ) -> Observable<Mutation> {
        
        var prev: [SongEntity] = byOption ? [] : self.currentState.dataSource
        
        return .concat([
            .just(Mutation.updateLoadingState(true)), // 로딩
            fetchSearchSongsUseCase
                .execute(order: order, filter: filter, text: text, page: scrollPage, limit: limit)
                .asObservable()
                .map { [limit] dataSource -> Mutation in
                    return Mutation.updateDataSource(dataSource: prev + dataSource, canLoad: dataSource.count == limit)
                },
            .just(Mutation.updateScrollPage(scrollPage + 1)), // 스크롤 페이지 증가
            .just(Mutation.updateLoadingState(false)) // 로딩 종료
        ])
    }
}
