import Testing
@testable import Gitivity

@Suite("LoadingState Tests")
struct LoadingStateTests {

    @Test("loading state reports isLoading true")
    func loadingIsLoading() {
        let state: LoadingState<String> = .loading
        #expect(state.isLoading == true)
        #expect(state.value == nil)
    }

    @Test("loaded state holds value")
    func loadedValue() {
        let state: LoadingState<String> = .loaded("hello")
        #expect(state.isLoading == false)
        #expect(state.value == "hello")
    }

    @Test("error state reports isLoading false and nil value")
    func errorState() {
        let state: LoadingState<String> = .error(GitHubAPIError.invalidResponse)
        #expect(state.isLoading == false)
        #expect(state.value == nil)
    }
}
