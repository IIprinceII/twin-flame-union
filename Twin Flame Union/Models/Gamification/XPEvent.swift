//
//  XPEvent.swift
//  Twin Flame Union
//
//  Immutable log of every XP-earning action.
//

import Foundation
import SwiftData

@Model
final class XPEvent {
    var id: UUID
    var amount: Int
    var source: String
    var framework: String       // "vibrational", "energy", "apollux", "general"
    var skillKey: String
    var detail: String
    var createdAt: Date

    init(amount: Int = 0, source: String = "", framework: String = "", skillKey: String = "", detail: String = "") {
        self.id = UUID()
        self.amount = amount
        self.source = source
        self.framework = framework
        self.skillKey = skillKey
        self.detail = detail
        self.createdAt = Date()
    }
}
