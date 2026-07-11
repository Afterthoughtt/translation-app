import Testing
@testable import InterpreterCore

@Test func transcriptDeltasAreAppendedExactly() {
    var assembler = TranscriptAssembler()
    assembler.appendEnglishDelta("Good")
    assembler.appendEnglishDelta(" morning")

    #expect(assembler.liveEnglishText == "Good morning")
}

@Test func completingSegmentPreservesSourceAndTargetText() {
    var assembler = TranscriptAssembler()
    assembler.appendEnglishDelta("Good morning")
    assembler.appendPortugueseDelta("Bom dia")

    let entry = assembler.completeSegment()

    #expect(entry == TranscriptEntry(english: "Good morning", portuguese: "Bom dia"))
    #expect(
        assembler.history == [
            TranscriptEntry(english: "Good morning", portuguese: "Bom dia")
        ]
    )
    #expect(assembler.liveEnglishText.isEmpty)
    #expect(assembler.livePortugueseText.isEmpty)
}
