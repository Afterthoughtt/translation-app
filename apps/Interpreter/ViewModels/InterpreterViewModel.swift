import Observation
import InterpreterCore

@MainActor
@Observable
final class InterpreterViewModel {
    var connectionState: TranslationConnectionState = .idle
    var outputMode: TranslationOutputMode = .automatic
    var liveEnglishText = ""

    private let microphonePermission: any MicrophonePermissionProviding
    private let audioSession: any AudioSessionControlling
    private let transport: any TranslationTransporting
    private var isForeground = true
    private var userStopped = false
    private var userPaused = false
    private var isStarting = false

    init(
        microphonePermission: any MicrophonePermissionProviding = SystemMicrophonePermissionService(),
        audioSession: any AudioSessionControlling = SystemAudioSessionController(),
        transport: any TranslationTransporting = UnavailableTranslationTransport()
    ) {
        self.microphonePermission = microphonePermission
        self.audioSession = audioSession
        self.transport = transport
    }

    var isListening: Bool { connectionState == .listening }
    var isPaused: Bool { connectionState == .paused }
    var canTogglePause: Bool { isListening || isPaused }

    var statusText: String {
        switch connectionState {
        case .idle: "Ready"
        case .requestingMicrophonePermission: "Microphone permission required"
        case .configuringAudio, .requestingToken: "Starting…"
        case .connecting: "Connecting…"
        case .listening: "Listening"
        case .paused: "Paused"
        case .reconnecting: "Reconnecting…"
        case .waitingForNetworkOrUser: "No network"
        case let .failed(message): message
        case .stopped: "Stopped"
        }
    }

    func startIfPermitted() async {
        guard isForeground, !userStopped, !userPaused, !isStarting else { return }
        isStarting = true
        defer { isStarting = false }

        connectionState = .requestingMicrophonePermission
        let permissionGranted: Bool
        switch microphonePermission.authorization {
        case .granted:
            permissionGranted = true
        case .denied:
            permissionGranted = false
        case .undetermined:
            permissionGranted = await microphonePermission.requestPermission()
        }

        guard isForeground, !userStopped, !userPaused else { return }
        guard permissionGranted else {
            connectionState = .failed(message: "Microphone access is required")
            return
        }

        connectionState = .configuringAudio
        do {
            try audioSession.configureForTranslation()
            connectionState = .idle
        } catch {
            connectionState = .failed(message: "Audio setup failed")
        }
    }

    func togglePause() async {
        if isPaused {
            guard isForeground, !userStopped else { return }
            do {
                try audioSession.configureForTranslation()
                await transport.setTranslatedAudioEnabled(false)
                await transport.setMicrophoneEnabled(true)
                userPaused = false
                connectionState = .listening
            } catch {
                connectionState = .failed(message: "Audio setup failed")
            }
        } else {
            userPaused = true
            await pauseForPrivacy()
        }
    }

    func stop() async {
        userStopped = true
        userPaused = false
        await transport.setMicrophoneEnabled(false)
        await transport.setTranslatedAudioEnabled(false)
        await transport.disconnect()
        try? audioSession.deactivate()
        liveEnglishText = ""
        connectionState = .stopped
    }

    func scenePhaseDidChange(isActive: Bool) async {
        isForeground = isActive
        if isActive {
            await startIfPermitted()
        } else if connectionState != .stopped {
            await pauseForPrivacy(deactivateAudioSession: true)
        }
    }

    private func pauseForPrivacy(deactivateAudioSession: Bool = false) async {
        await transport.setMicrophoneEnabled(false)
        await transport.setTranslatedAudioEnabled(false)
        if deactivateAudioSession {
            try? audioSession.deactivate()
        }
        connectionState = .paused
    }
}
