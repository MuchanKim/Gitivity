import Foundation
import Testing
@testable import Gitivity

@Suite("ActivityPromptBuilder Tests")
struct ActivityPromptBuilderTests {

    private let builder = ActivityPromptBuilder()

    private func makePR(title: String = "feat: add login", body: String = "", merged: Bool = false) -> PullRequest {
        PullRequest(
            id: "1", title: title, body: body,
            url: "https://github.com/test/repo/pull/1",
            createdAt: Date(), mergedAt: merged ? Date() : nil,
            additions: 10, deletions: 5, changedFiles: 3,
            repositoryName: "TestRepo"
        )
    }

    private func makeCommit(message: String = "initial commit") -> Commit {
        Commit(
            id: "abc", message: message,
            url: "https://github.com/test/repo/commit/abc",
            committedDate: Date(), additions: 5, deletions: 2,
            repositoryName: "TestRepo"
        )
    }

    @Test("buildRepoSummaryPrompt — 불릿 2줄 포맷 지정")
    func repoSummaryFormat() {
        let result = builder.buildRepoSummaryPrompt(
            repoName: "TestRepo",
            pullRequests: [makePR()],
            commits: [makeCommit()]
        )
        #expect(result.contains("TestRepo"))
        #expect(result.contains("feat: add login"))
        #expect(result.contains("initial commit"))
        #expect(result.contains("· "))
        #expect(result.contains("정확히 2줄"))
    }

    @Test("buildRepoSummaryPrompt — PR body 포함")
    func repoSummaryIncludesPRBody() {
        let result = builder.buildRepoSummaryPrompt(
            repoName: "TestRepo",
            pullRequests: [makePR(body: "OAuth 인증 구현")],
            commits: []
        )
        #expect(result.contains("OAuth 인증 구현"))
    }

    @Test("buildRepoSummaryPrompt — 머지 상태 표시")
    func repoSummaryMergeStatus() {
        let result = builder.buildRepoSummaryPrompt(
            repoName: "TestRepo",
            pullRequests: [makePR(merged: true)],
            commits: []
        )
        #expect(result.contains("머지됨"))
    }

    @Test("buildPRSummaryPrompt — 불릿 2줄 포맷 지정")
    func prSummaryFormat() {
        let result = builder.buildPRSummaryPrompt(
            title: "feat: add login",
            body: "OAuth 로그인 구현",
            commits: [makeCommit()]
        )
        #expect(result.contains("feat: add login"))
        #expect(result.contains("OAuth 로그인 구현"))
        #expect(result.contains("· "))
        #expect(result.contains("정확히 2줄"))
    }

    @Test("buildCommitDescriptionPrompt — 코드 변경 설명")
    func commitDescription() {
        let result = builder.buildCommitDescriptionPrompt("fix: resolve null crash on login")
        #expect(result.contains("fix: resolve null crash on login"))
        #expect(result.contains("코드베이스"))
        #expect(result.contains("1줄"))
    }
}
