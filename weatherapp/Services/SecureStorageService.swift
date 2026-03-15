import Foundation
import Security

protocol SecureStorageProtocol {
    func save(value: String, for key: String) throws
    func readValue(for key: String) throws -> String?
    func deleteValue(for key: String) throws
}

enum SecureStorageKey {
    static let weatherAPIKey = "weather.apiKey"
}

// ключ API храним в Keychain, не в UserDefaults
class KeychainSecureStorage: SecureStorageProtocol {
    private let serviceName: String

    init(serviceName: String = Bundle.main.bundleIdentifier ?? "weatherapp") {
        self.serviceName = serviceName
    }

    func save(value: String, for key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw SecureStorageError.encodingFailed
        }
        try deleteValue(for: key)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SecureStorageError.saveFailed(status)
        }
    }

    func readValue(for key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            throw SecureStorageError.readFailed(status)
        }
        return string
    }

    func deleteValue(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw SecureStorageError.deleteFailed(status)
        }
    }
}

enum SecureStorageError: LocalizedError {
    case encodingFailed
    case saveFailed(OSStatus)
    case readFailed(OSStatus)
    case deleteFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode value."
        case .saveFailed, .readFailed, .deleteFailed:
            return "Secure storage operation failed."
        }
    }
}
