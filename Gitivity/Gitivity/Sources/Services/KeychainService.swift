import Foundation

enum KeychainService {
    static func save(key: String, value: String) throws {
        // TODO: iOS Keychain 저장
    }

    static func load(key: String) throws -> String? {
        // TODO: iOS Keychain 로드
        return nil
    }

    static func delete(key: String) throws {
        // TODO: iOS Keychain 삭제
    }
}
