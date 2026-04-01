import Foundation
import os

@MainActor
@Observable
final class PRDetailViewModel {
    private(set) var translatedBody: LoadingState<String> = .loading
    private(set) var showOriginal = false
    private(set) var showAllCommits = false

    private let promptBuilder = ActivityPromptBuilder()

    func load(item: RepoDetailItem) async {
        guard !item.body.isEmpty else {
            translatedBody = .loaded("")
            return
        }

        if LanguageDetector.isLikelyEnglish(item.body) {
            await translateBody(item.body)
        } else {
            translatedBody = .loaded(item.body)
        }
    }

    func toggleOriginal() {
        showOriginal.toggle()
    }

    func toggleShowAllCommits() {
        showAllCommits.toggle()
    }

    var isTranslated: Bool {
        if case .loaded = translatedBody {
            return true
        }
        return false
    }

    private func translateBody(_ text: String) async {
        let provider = FoundationProvider()
        let prompt = promptBuilder.buildTranslationPrompt(text)

        do {
            let translated = try await provider.summarize(prompt: prompt)
            translatedBody = .loaded(translated)
        } catch {
            AILogger.generation.error("[PRDetail] translation failed: \(error)")
            translatedBody = .loaded(text)
        }
    }
}
