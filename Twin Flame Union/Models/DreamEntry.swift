//
//  DreamEntry.swift
//  Twin Flame Union
//
//  SwiftData model for dream journal entries.
//

import Foundation
import SwiftData

@Model
final class DreamEntry {
    var id: UUID
    var title: String
    var content: String
    var people: String       // who appeared, free text
    var symbols: String      // comma-separated symbol tags
    var wakeFeeling: String  // emoji + label e.g. "✨ Hopeful"
    var isLucid: Bool
    var isTwinFlameDream: Bool
    var createdAt: Date

    init(title: String = "", content: String = "", people: String = "",
         symbols: String = "", wakeFeeling: String = "", isLucid: Bool = false,
         isTwinFlameDream: Bool = false, createdAt: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.people = people
        self.symbols = symbols
        self.wakeFeeling = wakeFeeling
        self.isLucid = isLucid
        self.isTwinFlameDream = isTwinFlameDream
        self.createdAt = createdAt
    }
}
