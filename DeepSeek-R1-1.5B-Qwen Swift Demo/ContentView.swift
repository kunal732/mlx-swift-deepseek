
import SwiftUI
import MLXModelManager
import MarkdownUI

struct ContentView: View {
    @StateObject var DeepSeekManager = ModelManager(modelPath: "mlx-community/deepseek-r1-distill-qwen-1.5b")
    
    @State var prompt = "what is superposition in physics"
    
    var body: some View {
        VStack(alignment: .leading) {
            
            // Top controls: progress indicators
            HStack {
                Spacer()
                
                if DeepSeekManager.isLoading {
                    VStack {
                        ProgressView(
                            value: Double(DeepSeekManager.progressPercent),
                            total: 100
                        ) {
                            Text("Downloading Model...")
                        }
                        .frame(maxWidth: 200)
                        
                        Text("\(DeepSeekManager.progressPercent)%")
                            .font(.subheadline)
                    }
                }
                
                Spacer()
            }
            
            // Scrollable output (Markdown only)
            ScrollView(.vertical) {
                ScrollViewReader { scrollProxy in
                    Markdown(DeepSeekManager.output)
                        .textSelection(.enabled)
                        .onChange(of: DeepSeekManager.output) { _, _ in
                            scrollProxy.scrollTo("bottom", anchor: .bottom)
                        }
                    
                    // "Bottom" spacer
                    Spacer()
                        .frame(width: 1, height: 1)
                        .id("bottom")
                }
            }
            
            // Prompt input + "Answer Prompt" button
            HStack {
                TextField("prompt", text: $prompt)
                    .onSubmit { answerPrompt() }
                    .disabled(DeepSeekManager.isGenerating || DeepSeekManager.isLoading)
                    .textFieldStyle(.roundedBorder)
                
                Button("Answer Prompt") {
                    answerPrompt()
                }
                .disabled(DeepSeekManager.isGenerating || DeepSeekManager.isLoading)
            }
        }
        .padding()
        .task {
            // Optionally pre-load the model on launch
            do {
                try await DeepSeekManager.loadModel()
            } catch {
                print("Failed to load model: \(error)")
            }
        }
    }
    
    /// Trigger text generation using the current prompt
    private func answerPrompt() {
        Task {
            try await DeepSeekManager.loadModel()
            await DeepSeekManager.generate(prompt: prompt)
        }
    }
}

#Preview {
    ContentView()
}
