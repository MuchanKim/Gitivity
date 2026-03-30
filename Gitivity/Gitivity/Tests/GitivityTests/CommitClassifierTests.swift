import Testing
@testable import Gitivity

struct MockAIProvider: AIProvider {
    var availabilityStatus: AIAvailabilityStatus = .available

    func summarize(prompt: String) async throws(AIProviderError) -> String {
        "mock summary"
    }
}

@Suite("CommitClassifier Tests")
@MainActor
struct CommitClassifierTests {

    @Test("conventional commit prefix — feat")
    func classifyFeat() async {
        let classifier = CommitClassifier(aiProvider: MockAIProvider())
        let result = await classifier.classify("feat: add login")
        #expect(result == .feat)
    }

    @Test("conventional commit prefix — fix with scope")
    func classifyFixWithScope() async {
        let classifier = CommitClassifier(aiProvider: MockAIProvider())
        let result = await classifier.classify("fix(auth): resolve crash")
        #expect(result == .fix)
    }

    @Test("conventional commit prefix — refactor")
    func classifyRefactor() async {
        let classifier = CommitClassifier(aiProvider: MockAIProvider())
        let result = await classifier.classify("refactor: extract method")
        #expect(result == .refactor)
    }

    @Test("conventional commit prefix — docs")
    func classifyDocs() async {
        let classifier = CommitClassifier(aiProvider: MockAIProvider())
        let result = await classifier.classify("docs: update readme")
        #expect(result == .docs)
    }

    @Test("conventional commit prefix — test")
    func classifyTest() async {
        let classifier = CommitClassifier(aiProvider: MockAIProvider())
        let result = await classifier.classify("test: add unit tests")
        #expect(result == .test)
    }

    @Test("conventional commit prefix — style")
    func classifyStyle() async {
        let classifier = CommitClassifier(aiProvider: MockAIProvider())
        let result = await classifier.classify("style: format code")
        #expect(result == .style)
    }

    @Test("conventional commit prefix — chore")
    func classifyChore() async {
        let classifier = CommitClassifier(aiProvider: MockAIProvider())
        let result = await classifier.classify("chore: update deps")
        #expect(result == .chore)
    }

    @Test("AI unavailable — fallback to chore")
    func classifyFallbackWhenUnavailable() async {
        let mock = MockAIProvider(availabilityStatus: .deviceNotEligible)
        let classifier = CommitClassifier(aiProvider: mock)
        let result = await classifier.classify("Add awesome feature")
        #expect(result == .chore)
    }

    @Test("classifyBatch preserves order")
    func classifyBatchOrder() async {
        let classifier = CommitClassifier(aiProvider: MockAIProvider())
        let messages = ["feat: a", "fix: b", "docs: c"]
        let results = await classifier.classifyBatch(messages)
        #expect(results == [.feat, .fix, .docs])
    }
}
