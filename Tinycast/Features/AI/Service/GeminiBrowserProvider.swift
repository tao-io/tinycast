import Foundation

struct GeminiBrowserProvider: AIProvider {
    func stream(_ request: AIRequest) -> AsyncThrowingStream<AIStreamEvent, Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(.text("Opened Google AI Mode (Gemini) in browser."))
            continuation.finish()
        }
    }
}
