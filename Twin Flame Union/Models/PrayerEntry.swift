//
//  PrayerEntry.swift
//  Twin Flame Union
//

import Foundation
import SwiftData

@Model
final class PrayerEntry {
    var id: UUID
    var petition: String      // what you are praying for
    var detail: String
    var isAnswered: Bool
    var answeredNote: String  // how it was answered
    var createdAt: Date
    var answeredAt: Date?

    init(petition: String = "", detail: String = "") {
        self.id           = UUID()
        self.petition     = petition
        self.detail       = detail
        self.isAnswered   = false
        self.answeredNote = ""
        self.createdAt    = Date()
        self.answeredAt   = nil
    }
}
