import Foundation
import InterpreterCore

enum TokenServiceClientError: Error, Equatable {
    case invalidConfiguration
    case invalidDeviceID
    case invalidResponse
    case responseTooLarge
    case unauthorized
    case rateLimited
    case serviceUnavailable
}

actor TokenServiceClient: TranslationTokenProviding {
    private static let maximumResponseBytes = 16_384

    private let endpoint: URL
    private let session: URLSession
    private let accessTokenProvider: any AccessTokenProviding
    private let now: @Sendable () -> Date

    init(
        baseURL: URL,
        session: URLSession = .shared,
        accessTokenProvider: any AccessTokenProviding = KeychainAccessTokenProvider(),
        now: @escaping @Sendable () -> Date = Date.init
    ) throws {
        let endpoint = baseURL.appendingPathComponent("api/translation-token")
        self.endpoint = endpoint
        self.session = session
        self.accessTokenProvider = accessTokenProvider
        self.now = now
    }

    func fetchClientSecret(
        noiseReduction: NoiseReduction,
        deviceID: String
    ) async throws -> TranslationClientSecret {
        guard (16...128).contains(deviceID.count),
              deviceID.allSatisfy({ $0.isASCII && ($0.isLetter || $0.isNumber || "._-".contains($0)) }) else {
            throw TokenServiceClientError.invalidDeviceID
        }

        let accessToken = try await accessTokenProvider.accessToken()
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 10
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(TokenRequest(
            noiseReduction: noiseReduction.rawValue,
            deviceId: deviceID
        ))

        let (data, response) = try await session.data(for: request)
        try Task.checkCancellation()

        guard data.count <= Self.maximumResponseBytes else {
            throw TokenServiceClientError.responseTooLarge
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TokenServiceClientError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw TokenServiceClientError.unauthorized
        case 429:
            throw TokenServiceClientError.rateLimited
        case 500...599:
            throw TokenServiceClientError.serviceUnavailable
        default:
            throw TokenServiceClientError.invalidResponse
        }

        guard httpResponse.value(forHTTPHeaderField: "Content-Type")?
            .lowercased().hasPrefix("application/json") == true,
              let object = try? JSONSerialization.jsonObject(with: data),
              let dictionary = object as? [String: Any],
              Set(dictionary.keys) == Set(["clientSecret", "expiresAt"]),
              let decoded = try? JSONDecoder().decode(TokenResponse.self, from: data),
              decoded.clientSecret.hasPrefix("ek_"),
              decoded.clientSecret.count <= 2_048,
              !decoded.clientSecret.contains(where: \Character.isWhitespace),
              decoded.expiresAt.isFinite,
              decoded.expiresAt > now().timeIntervalSince1970 else {
            throw TokenServiceClientError.invalidResponse
        }

        return TranslationClientSecret(
            value: decoded.clientSecret,
            expiresAt: Date(timeIntervalSince1970: decoded.expiresAt)
        )
    }
}

private struct TokenRequest: Encodable {
    let noiseReduction: String
    let deviceId: String
}

private struct TokenResponse: Decodable {
    let clientSecret: String
    let expiresAt: TimeInterval
}
