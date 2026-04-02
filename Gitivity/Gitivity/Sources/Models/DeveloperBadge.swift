import SwiftUI

enum DeveloperBadgeType: String, CaseIterable, Identifiable {
    case nightOwl
    case earlyBird
    case consistencyKing
    case builder
    case refactorer
    case prMaster
    case stormCoder
    case weekendWarrior
    case multiPlayer

    var id: String { rawValue }

    var name: String {
        switch self {
        case .nightOwl: "올빼미"
        case .earlyBird: "얼리버드"
        case .consistencyKing: "꾸준함의 왕"
        case .builder: "빌더"
        case .refactorer: "리팩터러"
        case .prMaster: "PR 장인"
        case .stormCoder: "폭풍 코더"
        case .weekendWarrior: "주말 전사"
        case .multiPlayer: "멀티 플레이어"
        }
    }

    var description: String {
        switch self {
        case .nightOwl: "22시~04시에 커밋 50% 이상"
        case .earlyBird: "05시~09시에 커밋 50% 이상"
        case .consistencyKing: "30일 이상 연속 기여"
        case .builder: "추가 코드가 삭제의 3배 이상"
        case .refactorer: "삭제 코드가 추가보다 많음"
        case .prMaster: "PR 50개 이상 merge"
        case .stormCoder: "하루 최대 커밋 10개 이상"
        case .weekendWarrior: "주말 커밋 비율 40% 이상"
        case .multiPlayer: "5개 이상 레포에 동시 기여"
        }
    }

    var systemImage: String {
        switch self {
        case .nightOwl: "moon.stars"
        case .earlyBird: "sunrise"
        case .consistencyKing: "bookmark.fill"
        case .builder: "chart.line.uptrend.xyaxis"
        case .refactorer: "scissors"
        case .prMaster: "arrow.triangle.branch"
        case .stormCoder: "bolt.fill"
        case .weekendWarrior: "briefcase.fill"
        case .multiPlayer: "square.stack.3d.up"
        }
    }

    var gradient: [Color] {
        switch self {
        case .nightOwl: [Color(hex: 0x06B6D4), Color(hex: 0x0891B2)]
        case .earlyBird: [Color(hex: 0xFBBF24), Color(hex: 0xD97706)]
        case .consistencyKing: [Color(hex: 0x34D399), Color(hex: 0x059669)]
        case .builder: [Color(hex: 0xA78BFA), Color(hex: 0x7C3AED)]
        case .refactorer: [Color(hex: 0x64748B), Color(hex: 0x475569)]
        case .prMaster: [Color(hex: 0xFB923C), Color(hex: 0xEA580C)]
        case .stormCoder: [Color(hex: 0x22D3EE), Color(hex: 0x06B6D4)]
        case .weekendWarrior: [Color(hex: 0xF472B6), Color(hex: 0xDB2777)]
        case .multiPlayer: [Color(hex: 0x818CF8), Color(hex: 0x6366F1)]
        }
    }

    var accentColor: Color {
        gradient[0]
    }
}

struct DeveloperBadge: Identifiable {
    let type: DeveloperBadgeType
    let isEarned: Bool
    let progress: Double // 0.0 ~ 1.0
    let detail: String // e.g. "62%" or "34일" or "52 merged"

    var id: String { type.id }
}

struct BadgeCalculator {
    static func calculate(from data: ProfileData) -> [DeveloperBadge] {
        let commits = data.commits
        let calendar = Calendar.current

        // Time-based analysis
        let nightCount = commits.filter {
            let hour = calendar.component(.hour, from: $0.committedDate)
            return hour >= 22 || hour < 4
        }.count
        let morningCount = commits.filter {
            let hour = calendar.component(.hour, from: $0.committedDate)
            return hour >= 5 && hour < 9
        }.count
        let weekendCount = commits.filter {
            let weekday = calendar.component(.weekday, from: $0.committedDate)
            return weekday == 1 || weekday == 7
        }.count
        let total = max(commits.count, 1)
        let nightPct = Double(nightCount) / Double(total)
        let morningPct = Double(morningCount) / Double(total)
        let weekendPct = Double(weekendCount) / Double(total)

        // Code impact
        let totalAdd = commits.reduce(0) { $0 + $1.additions }
        let totalDel = max(commits.reduce(0) { $0 + $1.deletions }, 1)
        let addRatio = Double(totalAdd) / Double(totalAdd + totalDel)

        // Daily max commits
        let commitsByDay = Dictionary(grouping: commits) { calendar.startOfDay(for: $0.committedDate) }
        let maxDaily = commitsByDay.values.map(\.count).max() ?? 0

        // Active repos
        let activeRepos = Set(commits.map(\.repositoryName)).count

        // Streak
        let streak = data.currentStreak

        // Merged PRs
        let mergedPRs = data.totalPRs

        return [
            DeveloperBadge(
                type: .nightOwl, isEarned: nightPct >= 0.5,
                progress: min(nightPct / 0.5, 1.0),
                detail: "\(Int(nightPct * 100))%"
            ),
            DeveloperBadge(
                type: .earlyBird, isEarned: morningPct >= 0.5,
                progress: min(morningPct / 0.5, 1.0),
                detail: "\(Int(morningPct * 100))%"
            ),
            DeveloperBadge(
                type: .consistencyKing, isEarned: streak >= 30,
                progress: min(Double(streak) / 30.0, 1.0),
                detail: "\(streak)일"
            ),
            DeveloperBadge(
                type: .builder, isEarned: totalAdd > totalDel * 3,
                progress: min(addRatio / 0.75, 1.0),
                detail: "\(Int(addRatio * 100))%"
            ),
            DeveloperBadge(
                type: .refactorer, isEarned: totalDel > totalAdd,
                progress: totalDel > totalAdd ? 1.0 : Double(totalDel) / Double(max(totalAdd, 1)),
                detail: "\(Int((1.0 - addRatio) * 100))%"
            ),
            DeveloperBadge(
                type: .prMaster, isEarned: mergedPRs >= 50,
                progress: min(Double(mergedPRs) / 50.0, 1.0),
                detail: "\(mergedPRs)"
            ),
            DeveloperBadge(
                type: .stormCoder, isEarned: maxDaily >= 10,
                progress: min(Double(maxDaily) / 10.0, 1.0),
                detail: "최대 \(maxDaily)/일"
            ),
            DeveloperBadge(
                type: .weekendWarrior, isEarned: weekendPct >= 0.4,
                progress: min(weekendPct / 0.4, 1.0),
                detail: "\(Int(weekendPct * 100))%"
            ),
            DeveloperBadge(
                type: .multiPlayer, isEarned: activeRepos >= 5,
                progress: min(Double(activeRepos) / 5.0, 1.0),
                detail: "\(activeRepos)개 레포"
            ),
        ]
    }
}
