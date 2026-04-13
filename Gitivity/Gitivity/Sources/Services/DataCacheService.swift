import Foundation

actor DataCacheService {
    static let shared = DataCacheService()

    private var entries: [String: CacheEntry] = [:]
    private let defaultTTL: TimeInterval = 300 // 5 minutes

    private struct CacheEntry {
        let value: Any
        let timestamp: Date

        func isStale(ttl: TimeInterval) -> Bool {
            Date().timeIntervalSince(timestamp) > ttl
        }
    }

    // MARK: - Generic Cache Operations

    func get<T>(_ key: String) -> T? {
        guard let entry = entries[key] else { return nil }
        if entry.isStale(ttl: defaultTTL) {
            entries.removeValue(forKey: key)
            return nil
        }
        return entry.value as? T
    }

    func set(_ key: String, value: Any) {
        entries[key] = CacheEntry(value: value, timestamp: Date())
    }

    func invalidate(_ key: String) {
        entries.removeValue(forKey: key)
    }

    func invalidateAll() {
        entries.removeAll()
    }

    func invalidateByPrefix(_ prefix: String) {
        entries = entries.filter { !$0.key.hasPrefix(prefix) }
    }
}

// MARK: - Cache Keys

enum CacheKey {
    // Feed
    static let feedItems = "feed.items"
    static func aiSummary(_ repoName: String) -> String { "ai.summary.\(repoName)" }
    static func categoryDistribution(_ repoName: String) -> String { "ai.category.\(repoName)" }

    // Profile
    static func profileData(_ periodDays: Int) -> String { "profile.data.\(periodDays)" }
    static func profileBadges(_ periodDays: Int) -> String { "profile.badges.\(periodDays)" }
    static func profileCategories(_ periodDays: Int) -> String { "profile.categories.\(periodDays)" }

    // Repo Detail
    static func repoMetadata(_ repoName: String) -> String { "repo.metadata.\(repoName)" }
    static func repoOnepager(_ repoName: String) -> String { "repo.onepager.\(repoName)" }
    static func prAISummary(_ prID: String) -> String { "ai.pr.\(prID)" }
    static func commitTranslation(_ commitID: String) -> String { "ai.commit.\(commitID)" }
}
