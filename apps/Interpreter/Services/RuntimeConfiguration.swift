import Foundation

enum RuntimeConfigurationError: Error, Equatable {
    case missingTokenServiceBaseURL
    case invalidTokenServiceBaseURL
    case insecureTokenServiceBaseURL
}

struct RuntimeConfiguration: Equatable {
    static let tokenServiceBaseURLKey = "InterpreterTokenServiceBaseURL"

    let tokenServiceBaseURL: URL

    static func load(from dictionary: [String: Any] = Bundle.main.infoDictionary ?? [:]) throws -> Self {
        guard let rawValue = dictionary[tokenServiceBaseURLKey] as? String,
              !rawValue.isEmpty,
              !rawValue.contains("$(") else {
            throw RuntimeConfigurationError.missingTokenServiceBaseURL
        }

        guard let url = URL(string: rawValue),
              let scheme = url.scheme?.lowercased(),
              let host = url.host,
              !host.isEmpty,
              url.user == nil,
              url.password == nil,
              url.query == nil,
              url.fragment == nil else {
            throw RuntimeConfigurationError.invalidTokenServiceBaseURL
        }

        let isLoopback = host == "127.0.0.1" || host == "localhost" || host == "::1"
        guard scheme == "https" || (scheme == "http" && isLoopback) else {
            throw RuntimeConfigurationError.insecureTokenServiceBaseURL
        }

        return Self(tokenServiceBaseURL: url)
    }
}
