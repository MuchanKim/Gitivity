import Foundation
import FoundationModels
import os

struct CommitClassifier: Sendable {
    private let aiProvider: AIProvider

    init(aiProvider: AIProvider = FoundationProvider()) {
        self.aiProvider = aiProvider
    }

    func classify(_ message: String) async -> CommitCategory {
        if let category = classifyByPrefix(message) {
            return category
        }
        return await classifyByAI(message)
    }

    func classifyBatch(_ messages: [String]) async -> [CommitCategory] {
        await withTaskGroup(of: (Int, CommitCategory).self) { group in
            for (index, message) in messages.enumerated() {
                group.addTask {
                    (index, await classify(message))
                }
            }
            var results = [(Int, CommitCategory)]()
            for await result in group {
                results.append(result)
            }
            return results.sorted { $0.0 < $1.0 }.map(\.1)
        }
    }

    // MARK: - Private

    private func classifyByPrefix(_ message: String) -> CommitCategory? {
        let lowered = message.lowercased().trimmingCharacters(in: .whitespaces)
        let prefixMap: [(String, CommitCategory)] = [
            ("feat:", .feat), ("feat(", .feat),
            ("fix:", .fix), ("fix(", .fix),
            ("refactor:", .refactor), ("refactor(", .refactor),
            ("style:", .style), ("style(", .style),
            ("chore:", .chore), ("chore(", .chore),
            ("docs:", .docs), ("docs(", .docs),
            ("test:", .test), ("test(", .test),
        ]
        for (prefix, category) in prefixMap {
            if lowered.hasPrefix(prefix) { return category }
        }
        return nil
    }

    private func classifyByAI(_ message: String) async -> CommitCategory {
        guard aiProvider.availabilityStatus == .available else {
            AILogger.classification.debug("skipped (model unavailable)")
            return .chore
        }
        do {
            let session = LanguageModelSession(
                instructions: "Classify this git commit message into one category: feat, fix, refactor, style, chore, docs, or test. Respond with only the category."
            )
            let response = try await session.respond(to: message, generating: CommitCategory.self)
            AILogger.classification.debug("classified as \(response.content.rawValue)")
            return response.content
        } catch {
            AILogger.classification.error("failed: \(error)")
            return .chore
        }
    }
}
