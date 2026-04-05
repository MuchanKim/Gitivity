import Foundation

struct ProfileData {
    let user: GitHubUser
    let contributions: [ContributionDay]
    let totalCommits: Int
    let totalPRs: Int
    let totalReviews: Int
    let totalIssues: Int
    let activeRepos: Int
    let totalStars: Int
    let topRepoName: String
    let topRepoStars: Int
    let commits: [Commit]

    var totalContributions: Int {
        totalCommits + totalPRs + totalReviews + totalIssues
    }

    var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        // 날짜별 기여 수를 딕셔너리로
        var countByDate: [Date: Int] = [:]
        for day in contributions {
            let key = calendar.startOfDay(for: day.date)
            countByDate[key] = day.count
        }

        // 어제 활동이 없으면 streak = 0 (오늘 활동 여부와 무관)
        guard (countByDate[yesterday] ?? 0) > 0 else {
            // 오늘만 활동했으면 1, 아니면 0
            return (countByDate[today] ?? 0) > 0 ? 1 : 0
        }

        // 어제부터 역산
        var streak = 0
        var checkDate = yesterday
        while (countByDate[checkDate] ?? 0) > 0 {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }

        // 오늘도 활동했으면 +1
        if (countByDate[today] ?? 0) > 0 {
            streak += 1
        }

        return streak
    }
}
