public enum OutputAudioPolicy {
    public static func shouldPlayTranslatedAudio(
        mode: TranslationOutputMode,
        route: AudioRouteSnapshot?,
        overrides: PrivateRouteOverrides = .init()
    ) -> Bool {
        switch mode {
        case .read:
            return false
        case .listen:
            return route != nil
        case .automatic:
            guard let route else {
                return false
            }

            return route.outputs.contains { output in
                switch output {
                case .wiredHeadphones, .hearingAid:
                    return true
                case let .bluetooth(identifier), let .other(identifier):
                    return overrides.contains(identifier)
                case .builtInSpeaker:
                    return false
                }
            }
        }
    }
}

