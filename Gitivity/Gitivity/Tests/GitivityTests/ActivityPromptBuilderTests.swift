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

    private func makeCommit(message: String = "initial commit", additions: Int = 5, deletions: Int = 2) -> Commit {
        Commit(
            id: UUID().uuidString, message: message,
            url: "https://github.com/test/repo/commit/abc",
            committedDate: Date(), additions: additions, deletions: deletions,
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
        #expect(result.contains("· "))
        #expect(result.contains("정확히 2줄"))
    }

    @Test("buildRepoSummaryPrompt — 상위 2개 커밋만 포함")
    func repoSummaryTopCommitsOnly() {
        let commits = [
            makeCommit(message: "small change", additions: 1, deletions: 0),
            makeCommit(message: "big refactor", additions: 100, deletions: 50),
            makeCommit(message: "medium fix", additions: 20, deletions: 10),
            makeCommit(message: "huge feature", additions: 200, deletions: 30),
        ]
        let result = builder.buildRepoSummaryPrompt(
            repoName: "TestRepo",
            pullRequests: [],
            commits: commits
        )
        #expect(result.contains("huge feature"))
        #expect(result.contains("big refactor"))
        #expect(!result.contains("small change"))
        #expect(!result.contains("medium fix"))
    }

    @Test("buildRepoSummaryPrompt — 커밋 2개 이하면 전부 포함")
    func repoSummaryFewCommits() {
        let commits = [
            makeCommit(message: "only commit", additions: 5, deletions: 2),
        ]
        let result = builder.buildRepoSummaryPrompt(
            repoName: "TestRepo",
            pullRequests: [],
            commits: commits
        )
        #expect(result.contains("only commit"))
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

    @Test("buildPRSummaryPrompt — 상위 2개 커밋만 포함")
    func prSummaryTopCommitsOnly() {
        let commits = [
            makeCommit(message: "tiny fix", additions: 1, deletions: 0),
            makeCommit(message: "core implementation", additions: 80, deletions: 20),
            makeCommit(message: "docs update", additions: 5, deletions: 3),
            makeCommit(message: "huge refactor", additions: 150, deletions: 60),
        ]
        let result = builder.buildPRSummaryPrompt(
            title: "feat: add login",
            body: "",
            commits: commits
        )
        #expect(result.contains("core implementation"))
        #expect(result.contains("huge refactor"))
        #expect(!result.contains("tiny fix"))
        #expect(!result.contains("docs update"))
        #expect(result.contains("feat: add login"))
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

    @Test("buildCommitDescriptionPrompt — 코드 변경 설명")
    func commitDescription() {
        let result = builder.buildCommitDescriptionPrompt("fix: resolve null crash on login")
        #expect(result.contains("fix: resolve null crash on login"))
        #expect(result.contains("코드베이스"))
        #expect(result.contains("1줄"))
    }

    @Test("buildRepoOnepagerPrompt — 기본 포맷")
    func repoOnepagerFormat() {
        let result = builder.buildRepoOnepagerPrompt(
            repoName: "MuchanKim/Gitivity",
            description: "GitHub activity viewer",
            readmeExcerpt: "# Gitivity\nAn iOS app that summarizes your GitHub activity.",
            languages: ["Swift", "JavaScript"],
            recentActivity: "최근 AI 요약 파이프라인 개선, 에러 핸들링 구조 변경"
        )
        #expect(result.contains("MuchanKim/Gitivity"))
        #expect(result.contains("GitHub activity viewer"))
        #expect(result.contains("Gitivity"))
        #expect(result.contains("Swift"))
        #expect(result.contains("3줄"))
    }

    @Test("buildRepoOnepagerPrompt — description 없을 때")
    func repoOnepagerNoDescription() {
        let result = builder.buildRepoOnepagerPrompt(
            repoName: "MuchanKim/Gitivity",
            description: nil,
            readmeExcerpt: "# Gitivity\nSome readme content.",
            languages: ["Swift"],
            recentActivity: "커밋 5건"
        )
        #expect(!result.contains("[설명]"))
        #expect(result.contains("Gitivity"))
    }

    @Test("buildRepoOnepagerPrompt — README 없을 때")
    func repoOnepagerNoReadme() {
        let result = builder.buildRepoOnepagerPrompt(
            repoName: "MuchanKim/Gitivity",
            description: "An app",
            readmeExcerpt: nil,
            languages: [],
            recentActivity: "커밋 3건"
        )
        #expect(!result.contains("[README]"))
        #expect(result.contains("An app"))
    }

    @Test("buildTranslationPrompt — 번역 프롬프트 포맷")
    func translationPromptFormat() {
        let result = builder.buildTranslationPrompt(
            "This PR adds OAuth authentication with token refresh."
        )
        #expect(result.contains("OAuth authentication"))
        #expect(result.contains("한국어"))
        #expect(result.contains("마크다운"))
    }

    @Test("buildTranslationPrompt — 긴 텍스트 truncation")
    func translationPromptTruncation() {
        let longText = String(repeating: "A", count: 5000)
        let result = builder.buildTranslationPrompt(longText)
        #expect(result.count < 4000)
    }
}
