//
//  LoveCoachViewModel.swift
//  Twin Flame Union
//

import SwiftUI

@Observable
@MainActor
final class LoveCoachViewModel {

    var messages: [ChatMessage] = []
    var inputText = ""
    var isStreaming = false
    var errorMessage: String?
    var showError = false
    var canRetry = false

    private let service: ChatStreaming

    init(service: ChatStreaming = LoveCoachService()) {
        self.service = service
    }

    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isStreaming else { return }
        inputText = ""
        messages.append(ChatMessage(role: .user, content: text))
        await streamReply()
    }

    /// Re-send after a failure WITHOUT making the user retype. Drops the failed
    /// assistant bubble and streams again against the preserved history.
    func retry() async {
        guard canRetry, !isStreaming else { return }
        if messages.last?.role == .assistant { messages.removeLast() }
        await streamReply()
    }

    private func streamReply() async {
        canRetry = false
        let placeholder = ChatMessage(role: .assistant, content: "")
        messages.append(placeholder)
        let idx = messages.count - 1
        isStreaming = true
        errorMessage = nil

        let history = Array(messages.dropLast())   // history excludes the empty placeholder
        do {
            for try await chunk in service.streamMessage(history: history) {
                messages[idx].content += chunk
            }
        } catch {
            messages[idx].content = "Something interrupted our connection. Tap to retry, dear soul."
            errorMessage = error.localizedDescription
            showError = true
            canRetry = true
        }
        isStreaming = false
    }
}
