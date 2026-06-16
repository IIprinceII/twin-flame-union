//
//  PrayerEntry.swift
//  Twin Flame Union
//

import Foundation
import SwiftData

@Model
final class PrayerEntry {
    var id: UUID = UUID()
    var petition: String = ""      // what you are praying for
    var detail: String = ""
    var isAnswered: Bool = false
    var answeredNote: String = ""  // how it was answered
    var createdAt: Date = Date()
    var answeredAt: Date? = nil

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
