//
//  DailyChallenge.swift
//  Twin Flame Union
//
//  Daily rotating challenges that award bonus XP.
//

import Foundation
import SwiftData

@Model
final class DailyChallenge {
    var id: UUID
    var date: Date
    var challengeKey: String
    var title: String
    var detail: String
    var xpReward: Int
    var isCompleted: Bool
    var completedAt: Date?

    init(date: Date = Date(), challengeKey: String = "", title: String = "", detail: String = "", xpReward: Int = 50) {
        self.id = UUID()
        self.date = date
        self.challengeKey = challengeKey
        self.title = title
        self.detail = detail
        self.xpReward = xpReward
        self.isCompleted = false
        self.completedAt = nil
    }
}
