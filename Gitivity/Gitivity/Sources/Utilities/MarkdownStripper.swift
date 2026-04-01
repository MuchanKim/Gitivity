import Foundation

nonisolated enum MarkdownStripper {
    static func strip(_ text: String) -> String {
        var lines = text.components(separatedBy: .newlines)

        lines = lines.map { line in
            var l = line

            // 헤딩 마커 제거: ### , ## , #
            if let range = l.range(of: #"^#{1,6}\s+"#, options: .regularExpression) {
                l.removeSubrange(range)
            }

            // 리스트 마커 제거: - , *  (줄 시작)
            if let range = l.range(of: #"^[\-\*]\s+"#, options: .regularExpression) {
                l.removeSubrange(range)
            }

            // 코드 펜스 제거: ```swift 등
            if l.hasPrefix("```") { return "" }

            // 인라인 코드: `text` → text
            l = l.replacingOccurrences(of: #"`([^`]+)`"#, with: "$1", options: .regularExpression)

            // 볼드: **text** → text
            l = l.replacingOccurrences(of: #"\*\*([^\*]+)\*\*"#, with: "$1", options: .regularExpression)

            // 이탤릭: *text* → text (볼드 처리 후)
            l = l.replacingOccurrences(of: #"\*([^\*]+)\*"#, with: "$1", options: .regularExpression)

            return l
        }

        // 빈 줄 정리: 연속 빈 줄 제거
        var result: [String] = []
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                if let last = result.last, !last.trimmingCharacters(in: .whitespaces).isEmpty {
                    continue
                }
                continue
            }
            result.append(trimmed)
        }

        return result.joined(separator: "\n")
    }
}
