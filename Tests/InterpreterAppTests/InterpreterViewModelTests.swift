import InterpreterCore
import Testing
@testable import Interpreter

@MainActor
struct InterpreterViewModelTests {
    @Test
    func startRequestsPermissionAndConfiguresAudio() async {
        let permission = MicrophonePermissionStub(authorization: .undetermined, requestResult: true)
        let audioSession = AudioSessionStub()
        let viewModel = InterpreterViewModel(
            microphonePermission: permission,
            audioSession: audioSession
        )

        await viewModel.startIfPermitted()

        #expect(permission.requestCount == 1)
        #expect(audioSession.configureCount == 1)
        #expect(viewModel.connectionState == .idle)
    }

    @Test
    func backgroundingEnforcesCaptureAndPlaybackPrivacyBoundary() async {
        let transport = TranslationTransportStub()
        let audioSession = AudioSessionStub()
        let viewModel = InterpreterViewModel(
            microphonePermission: MicrophonePermissionStub(authorization: .granted),
            audioSession: audioSession,
            transport: transport
        )
        viewModel.connectionState = .listening

        await viewModel.scenePhaseDidChange(isActive: false)

        #expect(transport.microphoneEnabled == false)
        #expect(transport.translatedAudioEnabled == false)
        #expect(audioSession.deactivateCount == 1)
        #expect(viewModel.connectionState == .paused)
    }

    @Test
    func stopDisconnectsAndClearsTranscript() async {
        let transport = TranslationTransportStub()
        let viewModel = InterpreterViewModel(
            microphonePermission: MicrophonePermissionStub(authorization: .granted),
            audioSession: AudioSessionStub(),
            transport: transport
        )
        viewModel.liveEnglishText = "Private conversation"

        await viewModel.stop()

        #expect(transport.didDisconnect)
        #expect(viewModel.liveEnglishText.isEmpty)
        #expect(viewModel.connectionState == .stopped)
    }
}

@MainActor
private final class MicrophonePermissionStub: MicrophonePermissionProviding {
    var authorization: MicrophoneAuthorization
    var requestResult: Bool
    var requestCount = 0

    init(authorization: MicrophoneAuthorization, requestResult: Bool = false) {
        self.authorization = authorization
        self.requestResult = requestResult
    }

    func requestPermission() async -> Bool {
        requestCount += 1
        return requestResult
    }
}

@MainActor
private final class AudioSessionStub: AudioSessionControlling {
    var configureCount = 0
    var deactivateCount = 0

    func configureForTranslation() throws {
        configureCount += 1
    }

    func deactivate() throws {
        deactivateCount += 1
    }
}

@MainActor
private final class TranslationTransportStub: TranslationTransporting {
    var microphoneEnabled: Bool?
    var translatedAudioEnabled: Bool?
    var didDisconnect = false

    func setMicrophoneEnabled(_ enabled: Bool) async {
        microphoneEnabled = enabled
    }

    func setTranslatedAudioEnabled(_ enabled: Bool) async {
        translatedAudioEnabled = enabled
    }

    func disconnect() async {
        didDisconnect = true
    }
}
