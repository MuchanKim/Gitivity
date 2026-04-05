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
    let currentStreak: Int

    var totalContributions: Int {
        totalCommits + totalPRs + totalReviews + totalIssues
    }

    static func calculateStreak(from contributions: [ContributionDay]) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        var countByDate: [Date: Int] = [:]
        for day in contributions {
            countByDate[calendar.startOfDay(for: day.date)] = day.count
        }

        guard (countByDate[yesterday] ?? 0) > 0 else {
            return (countByDate[today] ?? 0) > 0 ? 1 : 0
        }

        var streak = 0
        var checkDate = yesterday
        while (countByDate[checkDate] ?? 0) > 0 {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }

        if (countByDate[today] ?? 0) > 0 {
            streak += 1
        }

        return streak
    }
}
