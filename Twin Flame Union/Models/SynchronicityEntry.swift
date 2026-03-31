//
//  SynchronicityEntry.swift
//  Twin Flame Union
//
//  SwiftData model for tracking synchronicity signs and cosmic signals.
//

import Foundation
import SwiftData

@Model
final class SynchronicityEntry {
    var id: UUID
    var type: String      // e.g. "Angel Number", "Thought of Them"
    var detail: String    // e.g. "444", "Our Song", specific detail
    var note: String      // optional free-text note
    var createdAt: Date

    init(type: String, detail: String = "", note: String = "", createdAt: Date = Date()) {
        self.id = UUID()
        self.type = type
        self.detail = detail
        self.note = note
        self.createdAt = createdAt
    }
}
