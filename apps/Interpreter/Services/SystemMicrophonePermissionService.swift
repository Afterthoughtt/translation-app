import AVFoundation

@MainActor
final class SystemMicrophonePermissionService: MicrophonePermissionProviding {
    var authorization: MicrophoneAuthorization {
        switch AVAudioApplication.shared.recordPermission {
        case .undetermined:
            .undetermined
        case .denied:
            .denied
        case .granted:
            .granted
        @unknown default:
            .denied
        }
    }

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
