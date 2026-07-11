import Testing
@testable import InterpreterCore

@Test func automaticModeStartsMutedBeforeRouteResolution() {
    #expect(!OutputAudioPolicy.shouldPlayTranslatedAudio(mode: .automatic, route: nil))
}

@Test func automaticModeTreatsAmbiguousBluetoothAsPublicByDefault() {
    let route = AudioRouteSnapshot(
        inputName: "Built-in microphone",
        outputs: [.bluetooth(identifier: "car-audio")]
    )

    #expect(!OutputAudioPolicy.shouldPlayTranslatedAudio(mode: .automatic, route: route))
}

@Test func automaticModeHonorsPrivateRouteOverride() {
    let route = AudioRouteSnapshot(
        inputName: "Built-in microphone",
        outputs: [.bluetooth(identifier: "personal-headphones")]
    )
    let overrides = PrivateRouteOverrides(privateIdentifiers: ["personal-headphones"])

    #expect(
        OutputAudioPolicy.shouldPlayTranslatedAudio(
            mode: .automatic,
            route: route,
            overrides: overrides
        )
    )
}

@Test func readModeNeverPlaysAudio() {
    let route = AudioRouteSnapshot(
        inputName: "Built-in microphone",
        outputs: [.wiredHeadphones]
    )

    #expect(!OutputAudioPolicy.shouldPlayTranslatedAudio(mode: .read, route: route))
}

