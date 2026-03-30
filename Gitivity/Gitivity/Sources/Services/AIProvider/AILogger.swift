import os

// nonisolated(unsafe): TaskGroup 등 nonisolated context에서 접근 필요
enum AILogger {
    private nonisolated(unsafe) static let subsystem = "com.gitivity.ai"

    nonisolated(unsafe) static let availability = Logger(subsystem: subsystem, category: "availability")
    nonisolated(unsafe) static let generation = Logger(subsystem: subsystem, category: "generation")
    nonisolated(unsafe) static let classification = Logger(subsystem: subsystem, category: "classification")
}
