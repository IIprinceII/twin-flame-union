//
//  ConnectionMoment.swift
//  Twin Flame Union
//
//  SwiftData model for connection timeline entries.
//

import Foundation
import SwiftData

@Model
final class ConnectionMoment {
    var id: UUID
    var title: String
    var detail: String
    var category: String   // "First Contact", "Separation", "Sign", etc.
    var date: Date
    var createdAt: Date

    init(title: String = "", detail: String = "",
         category: String = "Milestone", date: Date = Date()) {
        self.id        = UUID()
        self.title     = title
        self.detail    = detail
        self.category  = category
        self.date      = date
        self.createdAt = Date()
    }
}
