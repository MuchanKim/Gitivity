import os

enum AILogger {
    nonisolated static var availability: Logger { Logger(subsystem: "com.gitivity.ai", category: "availability") }
    nonisolated static var generation: Logger { Logger(subsystem: "com.gitivity.ai", category: "generation") }
    nonisolated static var classification: Logger { Logger(subsystem: "com.gitivity.ai", category: "classification") }
}
