import Foundation
import FoundationModels

@Generable
enum CommitCategory: String, Sendable, CaseIterable {
    case feat
    case fix
    case refactor
    case style
    case chore
    case docs
    case test
}
