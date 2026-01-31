import Foundation
import Security

enum KeychainService: Sendable {
    private static let service = "com.moltview.auth"
    private static let tokenKey = "bearer_token"

    static var token: String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func setToken(_ newValue: String?) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey
        ]
        SecItemDelete(query as CFDictionary)

        guard let newValue, let data = newValue.data(using: .utf8) else { return }
        var attributes = query
        attributes[kSecValueData as String] = data
        SecItemAdd(attributes as CFDictionary, nil)
    }

    static var isAuthenticated: Bool {
        token != nil
    }
}
