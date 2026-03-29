import Testing
@testable import Gitivity

@Suite("KeychainService Tests")
@MainActor
struct KeychainServiceTests {
    let keychain = KeychainService()

    @Test("토큰 저장 후 읽기")
    func saveAndRead() throws {
        try keychain.save(key: "test_token", value: "abc123")
        let result = try keychain.read(key: "test_token")
        #expect(result == "abc123")
        try keychain.delete(key: "test_token")
    }

    @Test("존재하지 않는 키 읽기")
    func readNonExistent() {
        let result = try? keychain.read(key: "nonexistent_key_xyz")
        #expect(result == nil)
    }

    @Test("토큰 삭제")
    func deleteToken() throws {
        try keychain.save(key: "delete_test", value: "value")
        try keychain.delete(key: "delete_test")
        let result = try? keychain.read(key: "delete_test")
        #expect(result == nil)
    }

    @Test("토큰 덮어쓰기")
    func overwrite() throws {
        try keychain.save(key: "overwrite_test", value: "old")
        try keychain.save(key: "overwrite_test", value: "new")
        let result = try keychain.read(key: "overwrite_test")
        #expect(result == "new")
        try keychain.delete(key: "overwrite_test")
    }
}
