import ReactorKit

final class SongSearchResultReactor: Reactor {
    #warning("유즈케이스는 추후 연결")
    enum Action {}

    enum Mutation {}

    struct State {}

    var initialState: State

    init() {
        self.initialState = State(
        )
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {}
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {}

        return newState
    }
}

extension SongSearchResultReactor {}
