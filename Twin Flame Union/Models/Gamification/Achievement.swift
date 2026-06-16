//
//  Achievement.swift
//  Twin Flame Union
//
//  Tracks unlocked achievements.
//

import Foundation
import SwiftData

@Model
final class Achievement {
    var id: UUID = UUID()
    var key: String = ""
    var title: String = ""
    var detail: String = ""
    var icon: String = ""
    var rarity: String = "common"
    var framework: String = ""
    var unlockedAt: Date = Date()
    var xpReward: Int = 0

    init(key: String = "", title: String = "", detail: String = "", icon: String = "", rarity: String = "common", framework: String = "", xpReward: Int = 0) {
        self.id = UUID()
        self.key = key
        self.title = title
        self.detail = detail
        self.icon = icon
        self.rarity = rarity
        self.framework = framework
        self.unlockedAt = Date()
        self.xpReward = xpReward
    }
}
