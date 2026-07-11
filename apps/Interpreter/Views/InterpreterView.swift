import SwiftUI
import InterpreterCore

struct InterpreterView: View {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("hasAcknowledgedMicrophoneDisclosure") private var hasAcknowledgedMicrophoneDisclosure = false
    @State private var showsMicrophoneDisclosure = false
    @State private var viewModel = InterpreterViewModel()

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text(viewModel.statusText)
                    .font(.headline)
                Spacer()
                Circle()
                    .fill(viewModel.isListening ? .green : .secondary)
                    .frame(width: 10, height: 10)
                    .accessibilityHidden(true)
            }

            ScrollView {
                Text(viewModel.liveEnglishText.isEmpty ? "English captions will appear here." : viewModel.liveEnglishText)
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel("English translation")
            }

            Picker("Output mode", selection: $viewModel.outputMode) {
                Text("Auto").tag(TranslationOutputMode.automatic)
                Text("Listen").tag(TranslationOutputMode.listen)
                Text("Read").tag(TranslationOutputMode.read)
            }
            .pickerStyle(.segmented)

            HStack {
                Button(viewModel.isPaused ? "Resume" : "Pause") {
                    Task { await viewModel.togglePause() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canTogglePause)

                Button("Stop", role: .destructive) {
                    Task { await viewModel.stop() }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .task {
            if hasAcknowledgedMicrophoneDisclosure {
                await viewModel.startIfPermitted()
            } else {
                showsMicrophoneDisclosure = true
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            Task {
                guard hasAcknowledgedMicrophoneDisclosure else { return }
                await viewModel.scenePhaseDidChange(isActive: newPhase == .active)
            }
        }
        .sheet(isPresented: $showsMicrophoneDisclosure) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Live translation uses your microphone")
                    .font(.title2.bold())
                Text("While you are listening, nearby speech is sent to OpenAI for live Portuguese-to-English translation. Conversation audio and captions are not saved by default.")
                Text("English captions stay visible in every output mode. Automatic mode keeps translated audio muted unless a private output route is confirmed.")
                Button("Continue") {
                    hasAcknowledgedMicrophoneDisclosure = true
                    showsMicrophoneDisclosure = false
                    Task { await viewModel.startIfPermitted() }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
            .interactiveDismissDisabled()
        }
    }
}
