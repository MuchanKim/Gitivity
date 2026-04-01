import Foundation
import Testing
@testable import Gitivity

@Suite("LanguageDetector Tests")
struct LanguageDetectorTests {

    @Test("영어 텍스트 감지")
    func detectEnglish() {
        let text = "This pull request adds OAuth authentication and token refresh logic."
        #expect(LanguageDetector.isLikelyEnglish(text))
    }

    @Test("한국어 텍스트 감지")
    func detectKorean() {
        let text = "이 PR은 OAuth 인증과 토큰 갱신 로직을 추가합니다."
        #expect(!LanguageDetector.isLikelyEnglish(text))
    }

    @Test("혼합 텍스트 — 영어 비율 높음")
    func detectMixedMostlyEnglish() {
        let text = "Refactored the authentication flow. Added error handling for token expiration. 일부 UI 수정."
        #expect(LanguageDetector.isLikelyEnglish(text))
    }

    @Test("혼합 텍스트 — 한국어 비율 높음")
    func detectMixedMostlyKorean() {
        let text = "인증 플로우를 리팩토링했습니다. 토큰 만료 에러 핸들링을 추가했습니다. Some minor fixes."
        #expect(!LanguageDetector.isLikelyEnglish(text))
    }

    @Test("빈 텍스트")
    func detectEmpty() {
        #expect(!LanguageDetector.isLikelyEnglish(""))
    }
}
