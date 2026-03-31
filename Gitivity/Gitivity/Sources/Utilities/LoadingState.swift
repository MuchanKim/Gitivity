import Foundation

nonisolated enum LoadingState<T> {
    case loading
    case loaded(T)
    case error(Error)

    var isLoading: Bool {
        if case .loading = self { return true } else { return false }
    }

    var value: T? {
        if case .loaded(let v) = self { return v } else { return nil }
    }
}
