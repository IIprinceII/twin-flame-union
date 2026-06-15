//
//  SoulProfile.swift
//  Twin Flame Union
//
//  Root gamification model — one per user. Tracks XP, level, vibrational score,
//  and per-framework progression.
//

import Foundation
import SwiftData

@Model
final class SoulProfile {
    var id: UUID
    var totalXP: Int
    var vibrationalScore: Double
    var vibrationalGameXP: Int
    var energyEnhancementXP: Int
    var apolluxXP: Int
    var skillLevelsData: Data
    var constitutionRating: String
    var createdAt: Date
    var lastActivityAt: Date

    init() {
        self.id = UUID()
        self.totalXP = 0
        self.vibrationalScore = 0.0
        self.vibrationalGameXP = 0
        self.energyEnhancementXP = 0
        self.apolluxXP = 0
        self.skillLevelsData = Data()
        self.constitutionRating = "A"
        self.createdAt = Date()
        self.lastActivityAt = Date()
    }

    // MARK: - Computed

    var currentLevel: Int {
        // Each level costs level*100+50. Solve for level from total XP.
        var level = 0
        var xpNeeded = 0
        while xpNeeded + (level + 1) * 100 + 50 <= totalXP {
            level += 1
            xpNeeded += level * 100 + 50
        }
        return level
    }

    var xpForCurrentLevel: Int {
        var consumed = 0
        for l in 1...max(1, currentLevel) {
            consumed += l * 100 + 50
        }
        return totalXP - consumed
    }

    var xpToNextLevel: Int {
        (currentLevel + 1) * 100 + 50
    }

    var levelProgress: Double {
        guard xpToNextLevel > 0 else { return 0 }
        return Double(xpForCurrentLevel) / Double(xpToNextLevel)
    }

    var title: String {
        switch currentLevel {
        case 0...4:   return "Awakening Soul"
        case 5...9:   return "Rising Flame"
        case 10...19: return "Sacred Seeker"
        case 20...34: return "Vibrational Adept"
        case 35...49: return "Energy Master"
        default:      return "Divine Architect"
        }
    }

    // MARK: - Skill Levels

    var skillLevels: [String: Int] {
        get {
            (try? JSONDecoder().decode([String: Int].self, from: skillLevelsData)) ?? [:]
        }
        set {
            skillLevelsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    func skillLevel(for nodeID: String) -> Int {
        skillLevels[nodeID] ?? 0
    }
}
