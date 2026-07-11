import Foundation
import InterpreterCore

enum MicrophoneAuthorization: Equatable, Sendable {
    case undetermined
    case denied
    case granted
}

@MainActor
protocol MicrophonePermissionProviding {
    var authorization: MicrophoneAuthorization { get }
    func requestPermission() async -> Bool
}

@MainActor
protocol AudioSessionControlling {
    func configureForTranslation() throws
    func deactivate() throws
}

struct TranslationClientSecret: Equatable, Sendable {
    let value: String
    let expiresAt: Date
}

protocol TranslationTokenProviding: Sendable {
    func fetchClientSecret(
        noiseReduction: NoiseReduction,
        deviceID: String
    ) async throws -> TranslationClientSecret
}

protocol AccessTokenProviding: Sendable {
    func accessToken() async throws -> String
}

@MainActor
protocol TranslationTransporting {
    func setMicrophoneEnabled(_ enabled: Bool) async
    func setTranslatedAudioEnabled(_ enabled: Bool) async
    func disconnect() async
}

@MainActor
struct UnavailableTranslationTransport: TranslationTransporting {
    func setMicrophoneEnabled(_: Bool) async {}
    func setTranslatedAudioEnabled(_: Bool) async {}
    func disconnect() async {}
}
