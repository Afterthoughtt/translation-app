import AVFoundation

@MainActor
final class SystemAudioSessionController: AudioSessionControlling {
    private let session: AVAudioSession

    init(session: AVAudioSession = .sharedInstance()) {
        self.session = session
    }

    func configureForTranslation() throws {
        try session.setCategory(
            .playAndRecord,
            mode: .videoChat,
            options: [.allowBluetoothHFP, .allowBluetoothA2DP]
        )

        if let builtInMicrophone = session.availableInputs?.first(where: {
            $0.portType == .builtInMic
        }) {
            try session.setPreferredInput(builtInMicrophone)
        }

        try session.setActive(true)
    }

    func deactivate() throws {
        try session.setActive(false, options: [.notifyOthersOnDeactivation])
    }
}
