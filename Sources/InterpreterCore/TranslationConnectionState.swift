public enum TranslationConnectionState: Equatable, Sendable {
    case idle
    case requestingMicrophonePermission
    case configuringAudio
    case requestingToken
    case connecting
    case listening
    case paused
    case reconnecting(attempt: Int)
    case waitingForNetworkOrUser
    case failed(message: String)
    case stopped
}

