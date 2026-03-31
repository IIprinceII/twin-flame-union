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

    private let service = LoveCoachService()

    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isStreaming else { return }

        inputText = ""
        messages.append(ChatMessage(role: .user, content: text))

        let placeholder = ChatMessage(role: .assistant, content: "")
        messages.append(placeholder)
        let idx = messages.count - 1

        isStreaming = true
        errorMessage = nil

        // Pass history without the empty placeholder
        let history = Array(messages.dropLast())

        do {
            for try await chunk in service.streamMessage(history: history) {
                messages[idx].content += chunk
            }
        } catch {
            messages[idx].content = "Something interrupted our connection. Please try again, dear soul."
            errorMessage = error.localizedDescription
            showError = true
        }

        isStreaming = false
    }
}
