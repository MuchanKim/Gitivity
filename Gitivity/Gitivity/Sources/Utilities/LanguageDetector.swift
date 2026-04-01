import Foundation

nonisolated enum LanguageDetector {
    /// ASCII 알파벳 비율이 60% 이상이면 영어로 간주.
    static func isLikelyEnglish(_ text: String) -> Bool {
        let stripped = text.filter { !$0.isWhitespace && !$0.isPunctuation && !$0.isNewline }
        guard !stripped.isEmpty else { return false }
        let asciiLetters = stripped.filter { $0.isASCII && $0.isLetter }
        let ratio = Double(asciiLetters.count) / Double(stripped.count)
        return ratio >= 0.6
    }
}
