//
//  ChatMessage.swift
//  Twin Flame Union
//
//  Message model for the AI Love Coach chat.
//

import Foundation

struct ChatMessage: Identifiable, Codable, Sendable {
    let id: UUID
    let role: Role
    var content: String
    let timestamp: Date

    enum Role: String, Codable, Sendable {
        case user
        case assistant
    }

    init(role: Role, content: String) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
    }
}

// MARK: - Chat Persistence

enum ChatStorage {
    private static let key = "coachChatHistory"
    private static let maxMessages = 100

    static func save(_ messages: [ChatMessage]) {
        guard let data = try? JSONEncoder().encode(Array(messages.suffix(maxMessages))) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func load() -> [ChatMessage] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let messages = try? JSONDecoder().decode([ChatMessage].self, from: data)
        else { return [] }
        return messages
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
