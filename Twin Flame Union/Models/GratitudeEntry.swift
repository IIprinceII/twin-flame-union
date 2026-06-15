//
//  GratitudeEntry.swift
//  Twin Flame Union
//

import Foundation
import SwiftData

@Model
final class GratitudeEntry {
    var id: UUID
    var date: Date
    var items: String   // newline-separated gratitude items (up to 5)

    init(date: Date = Date(), items: String = "") {
        self.id    = UUID()
        self.date  = date
        self.items = items
    }
}
