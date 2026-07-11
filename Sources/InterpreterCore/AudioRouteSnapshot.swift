public enum AudioOutputKind: Equatable, Sendable {
    case builtInSpeaker
    case wiredHeadphones
    case hearingAid
    case bluetooth(identifier: String)
    case other(identifier: String)
}

public struct AudioRouteSnapshot: Equatable, Sendable {
    public let inputName: String
    public let outputs: [AudioOutputKind]

    public init(inputName: String, outputs: [AudioOutputKind]) {
        self.inputName = inputName
        self.outputs = outputs
    }
}

public struct PrivateRouteOverrides: Equatable, Sendable {
    private let privateIdentifiers: Set<String>

    public init(privateIdentifiers: Set<String> = []) {
        self.privateIdentifiers = privateIdentifiers
    }

    public func contains(_ identifier: String) -> Bool {
        privateIdentifiers.contains(identifier)
    }
}

