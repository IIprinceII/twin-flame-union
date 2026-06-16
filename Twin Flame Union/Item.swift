//
//  JournalEntry.swift
//  Twin Flame Union
//
//  SwiftData model for Soul Journal entries.
//

import Foundation
import SwiftData

@Model
final class JournalEntry {
    var id: UUID = UUID()
    var title: String = ""
    var content: String = ""
    var mood: String = "Hopeful"
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    init(title: String = "", content: String = "", mood: String = "Hopeful") {
        self.id = UUID()
        self.title = title
        self.content = content
        self.mood = mood
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
