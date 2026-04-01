import Foundation
import Testing
@testable import Gitivity

@Suite("MarkdownStripper Tests")
struct MarkdownStripperTests {

    @Test("헤딩 마커 제거")
    func stripHeadings() {
        #expect(MarkdownStripper.strip("### 제목") == "제목")
        #expect(MarkdownStripper.strip("## 제목") == "제목")
        #expect(MarkdownStripper.strip("# 제목") == "제목")
    }

    @Test("볼드/이탤릭 제거")
    func stripBoldItalic() {
        #expect(MarkdownStripper.strip("**볼드**") == "볼드")
        #expect(MarkdownStripper.strip("*이탤릭*") == "이탤릭")
        #expect(MarkdownStripper.strip("**볼드** 텍스트") == "볼드 텍스트")
    }

    @Test("리스트 마커 제거")
    func stripListMarkers() {
        #expect(MarkdownStripper.strip("- 항목") == "항목")
        #expect(MarkdownStripper.strip("* 항목") == "항목")
    }

    @Test("코드 마커 제거")
    func stripCodeMarkers() {
        #expect(MarkdownStripper.strip("`code`") == "code")
        #expect(MarkdownStripper.strip("```swift\ncode\n```") == "code")
    }

    @Test("복합 마크다운 제거")
    func stripComplex() {
        let input = "### **Error Handling**:\n\n* **Skeleton UI** 도입\n* `FoundationModels` 안정화"
        let result = MarkdownStripper.strip(input)
        #expect(!result.contains("###"))
        #expect(!result.contains("**"))
        #expect(!result.contains("`"))
        #expect(!result.contains("* "))
    }

    @Test("일반 텍스트는 변경 없음")
    func plainTextUnchanged() {
        let input = "에러 핸들링이 개선되었습니다."
        #expect(MarkdownStripper.strip(input) == input)
    }

    @Test("빈 줄 정리")
    func cleanupBlankLines() {
        let input = "첫줄\n\n\n둘째줄"
        let result = MarkdownStripper.strip(input)
        #expect(result == "첫줄\n둘째줄")
    }
}
