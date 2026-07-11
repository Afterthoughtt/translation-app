import SwiftUI
import InterpreterCore

struct InterpreterView: View {
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
                    viewModel.togglePause()
                }
                .buttonStyle(.borderedProminent)

                Button("Stop", role: .destructive) {
                    viewModel.stop()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .task {
            await viewModel.startIfPermitted()
        }
    }
}
