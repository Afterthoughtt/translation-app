import Observation
import InterpreterCore

@MainActor
@Observable
final class InterpreterViewModel {
    var connectionState: TranslationConnectionState = .idle
    var outputMode: TranslationOutputMode = .automatic
    var liveEnglishText = ""

    var isListening: Bool { connectionState == .listening }
    var isPaused: Bool { connectionState == .paused }

    var statusText: String {
        switch connectionState {
        case .idle: "Starting…"
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
        // Phase 1 connects this state transition to microphone permission,
        // AVAudioSession, token retrieval, and the pinned WebRTC transport.
        connectionState = .idle
    }

    func togglePause() {
        connectionState = isPaused ? .listening : .paused
    }

    func stop() {
        liveEnglishText = ""
        connectionState = .stopped
    }
}

