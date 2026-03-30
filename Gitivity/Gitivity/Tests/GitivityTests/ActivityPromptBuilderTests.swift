import Foundation
import Testing
@testable import Gitivity

@Suite("ActivityPromptBuilder Tests")
struct ActivityPromptBuilderTests {

    @Test("buildRepoSummaryPrompt — PR과 커밋 포함")
    func repoSummaryWithPRsAndCommits() {
        let builder = ActivityPromptBuilder()
        let pr = PullRequest(
            id: "1",
            title: "feat: add login",
            body: "",
            url: "https://github.com/test/repo/pull/1",
            createdAt: Date(),
            mergedAt: nil,
            additions: 10,
            deletions: 5,
            changedFiles: 3,
            repositoryName: "TestRepo"
        )
        let commit = Commit(
            id: "abc",
            message: "initial commit",
            url: "https://github.com/test/repo/commit/abc",
            committedDate: Date(),
            additions: 5,
            deletions: 2,
            repositoryName: "TestRepo"
        )
        let result = builder.buildRepoSummaryPrompt(
            repoName: "TestRepo",
            pullRequests: [pr],
            commits: [commit]
        )
        #expect(result.contains("TestRepo"))
        #expect(result.contains("feat: add login"))
        #expect(result.contains("initial commit"))
        #expect(result.contains("한국어"))
    }

    @Test("buildCommitTranslationPrompt — 메시지 포함")
    func commitTranslation() {
        let builder = ActivityPromptBuilder()
        let result = builder.buildCommitTranslationPrompt("fix: null crash")
        #expect(result.contains("fix: null crash"))
        #expect(result.contains("한국어"))
    }
}
