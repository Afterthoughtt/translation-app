import Foundation
import Security

enum KeychainAccessTokenError: Error {
    case missing
    case unreadable(OSStatus)
}

struct KeychainAccessTokenProvider: AccessTokenProviding {
    static let account = "translation-token-service-access-token"

    let service: String

    init(service: String = Bundle.main.bundleIdentifier ?? "Interpreter") {
        self.service = service
    }

    func accessToken() async throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: Self.account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else {
            throw KeychainAccessTokenError.missing
        }
        guard status == errSecSuccess,
              let data = item as? Data,
              let token = String(data: data, encoding: .utf8),
              !token.isEmpty else {
            throw KeychainAccessTokenError.unreadable(status)
        }
        return token
    }
}
