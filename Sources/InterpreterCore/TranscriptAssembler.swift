public struct TranscriptEntry: Equatable, Sendable {
    public let english: String
    public let portuguese: String?

    public init(english: String, portuguese: String? = nil) {
        self.english = english
        self.portuguese = portuguese
    }
}

public struct TranscriptAssembler: Equatable, Sendable {
    public private(set) var liveEnglishText = ""
    public private(set) var livePortugueseText = ""
    public private(set) var history: [TranscriptEntry] = []

    public init() {}

    public mutating func appendEnglishDelta(_ delta: String) {
        liveEnglishText.append(delta)
    }

    public mutating func appendPortugueseDelta(_ delta: String) {
        livePortugueseText.append(delta)
    }

    @discardableResult
    public mutating func completeSegment() -> TranscriptEntry? {
        guard !liveEnglishText.isEmpty else {
            return nil
        }

        let entry = TranscriptEntry(
            english: liveEnglishText,
            portuguese: livePortugueseText.isEmpty ? nil : livePortugueseText
        )
        history.append(entry)
        liveEnglishText = ""
        livePortugueseText = ""
        return entry
    }

    public mutating func clear() {
        liveEnglishText = ""
        livePortugueseText = ""
        history.removeAll(keepingCapacity: false)
    }
}

