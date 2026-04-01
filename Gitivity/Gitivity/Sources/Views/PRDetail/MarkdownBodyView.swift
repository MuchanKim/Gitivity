import SwiftUI

struct MarkdownBodyView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(parseBlocks().enumerated()), id: \.offset) { _, block in
                blockView(block)
            }
        }
    }

    @ViewBuilder
    private func blockView(_ block: MarkdownBlock) -> some View {
        switch block {
        case .heading(let level, let text):
            Text(inlineMarkdown(text))
                .font(headingFont(level))
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .padding(.top, level == 2 ? 4 : 0)

        case .listItem(let text):
            HStack(alignment: .top, spacing: 8) {
                Text("•")
                    .font(.system(size: 15))
                    .foregroundStyle(AppTheme.Colors.textTertiary)
                Text(inlineMarkdown(text))
                    .font(.system(size: 15))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .lineSpacing(5)
            }

        case .codeBlock(let code):
            Text(code)
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .lineSpacing(3)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.Colors.aiCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppTheme.Colors.border, lineWidth: 1)
                )

        case .paragraph(let text):
            Text(inlineMarkdown(text))
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .lineSpacing(5)
        }
    }

    private func headingFont(_ level: Int) -> Font {
        switch level {
        case 1: .system(size: 20, weight: .bold)
        case 2: .system(size: 17, weight: .bold)
        case 3: .system(size: 15, weight: .bold)
        case 4: .system(size: 15, weight: .semibold)
        case 5: .system(size: 14, weight: .semibold)
        case 6: .system(size: 13, weight: .semibold)
        default: .system(size: 15, weight: .semibold)
        }
    }

    // MARK: - Inline Markdown

    private func inlineMarkdown(_ text: String) -> AttributedString {
        // AttributedString(markdown:)는 bold, italic, code, link, strikethrough 지원
        if let attributed = try? AttributedString(markdown: text, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
            return attributed
        }
        return AttributedString(text)
    }

    // MARK: - Block Parsing

    private func parseBlocks() -> [MarkdownBlock] {
        let lines = text.components(separatedBy: .newlines)
        var blocks: [MarkdownBlock] = []
        var inCodeBlock = false
        var codeLines: [String] = []
        var pendingParagraphLines: [String] = []

        func flushParagraph() {
            let joined = pendingParagraphLines.joined(separator: " ").trimmingCharacters(in: .whitespaces)
            if !joined.isEmpty {
                blocks.append(.paragraph(joined))
            }
            pendingParagraphLines = []
        }

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Code fence
            if trimmed.hasPrefix("```") {
                if inCodeBlock {
                    blocks.append(.codeBlock(codeLines.joined(separator: "\n")))
                    codeLines = []
                    inCodeBlock = false
                } else {
                    flushParagraph()
                    inCodeBlock = true
                }
                continue
            }

            if inCodeBlock {
                codeLines.append(line)
                continue
            }

            // Empty line
            if trimmed.isEmpty {
                flushParagraph()
                continue
            }

            // Heading
            if let match = trimmed.firstMatch(of: /^(#{1,6})\s+(.+)/) {
                flushParagraph()
                let level = match.1.count
                let content = String(match.2)
                blocks.append(.heading(level: level, text: content))
                continue
            }

            // List item
            if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") {
                flushParagraph()
                let content = String(trimmed.dropFirst(2))
                blocks.append(.listItem(text: content))
                continue
            }

            // Regular text — accumulate for paragraph
            pendingParagraphLines.append(trimmed)
        }

        // Flush remaining
        if inCodeBlock {
            blocks.append(.codeBlock(codeLines.joined(separator: "\n")))
        }
        flushParagraph()

        return blocks
    }
}

private enum MarkdownBlock {
    case heading(level: Int, text: String)
    case listItem(text: String)
    case codeBlock(String)
    case paragraph(String)
}
