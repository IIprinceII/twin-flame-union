//
//  GamificationService.swift
//  Twin Flame Union
//
//  Central gamification engine. Awards XP, checks achievements,
//  calculates vibrational score, and manages skill progression.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
@MainActor
final class GamificationService {

    static let shared = GamificationService()

    // MARK: - State

    var profile: SoulProfile?
    var recentXPGain: Int = 0
    var showLevelUp: Bool = false
    var newLevel: Int = 0
    var showAchievement: AchievementDef?
    var todayChallenge: DailyChallenge?

    private var modelContext: ModelContext?
    private var todayFrameworks: Set<String> = []

    // MARK: - Setup

    func configure(with context: ModelContext) {
        self.modelContext = context
        loadOrCreateProfile()
        loadOrCreateDailyChallenge()
    }

    private func loadOrCreateProfile() {
        guard let ctx = modelContext else { return }
        let descriptor = FetchDescriptor<SoulProfile>()
        if let existing = try? ctx.fetch(descriptor).first {
            profile = existing
        } else {
            let p = SoulProfile()
            ctx.insert(p)
            try? ctx.save()
            profile = p
        }
    }

    private func loadOrCreateDailyChallenge() {
        guard let ctx = modelContext else { return }
        let today = Calendar.current.startOfDay(for: Date())
        var descriptor = FetchDescriptor<DailyChallenge>(
            predicate: #Predicate { $0.date >= today }
        )
        descriptor.fetchLimit = 1
        if let existing = try? ctx.fetch(descriptor).first {
            todayChallenge = existing
        } else {
            let template = DailyChallengeTemplates.forToday()
            let challenge = DailyChallenge()
            challenge.date = today
            challenge.challengeKey = template.key
            challenge.title = template.title
            challenge.detail = template.detail
            challenge.xpReward = template.xpReward
            ctx.insert(challenge)
            try? ctx.save()
            todayChallenge = challenge
        }
    }

    // MARK: - Award XP

    func awardXP(
        amount: Int,
        source: String,
        framework: SacredFramework? = nil,
        skillKey: String = "",
        detail: String = ""
    ) {
        guard let profile, let ctx = modelContext else { return }

        let multiplier = currentMultiplier()
        let finalAmount = Int(Double(amount) * multiplier)

        // Log event
        let event = XPEvent()
        event.amount = finalAmount
        event.source = source
        event.framework = framework?.rawValue ?? "general"
        event.skillKey = skillKey
        event.detail = detail
        ctx.insert(event)

        // Update profile
        let previousLevel = profile.currentLevel
        profile.totalXP += finalAmount
        profile.lastActivityAt = Date()

        // Per-framework XP
        if let fw = framework {
            switch fw {
            case .vibrationalGame:   profile.vibrationalGameXP += finalAmount
            case .energyEnhancement: profile.energyEnhancementXP += finalAmount
            case .apollux:           profile.apolluxXP += finalAmount
            }
            todayFrameworks.insert(fw.rawValue)
        }

        // Skill progression
        if !skillKey.isEmpty {
            var levels = profile.skillLevels
            let currentSkillXP = (levels[skillKey + "_xp"] ?? 0) + finalAmount
            levels[skillKey + "_xp"] = currentSkillXP

            // Find the node to get xpPerLevel
            let allNodes = SacredFramework.allCases.flatMap { $0.nodes }
            if let node = allNodes.first(where: { $0.id == skillKey }) {
                let newLevel = min(currentSkillXP / node.xpPerLevel, node.maxLevel)
                levels[skillKey] = newLevel
            }
            profile.skillLevels = levels
        }

        // Check level up
        if profile.currentLevel > previousLevel {
            newLevel = profile.currentLevel
            showLevelUp = true
        }

        // Animate XP gain
        recentXPGain = finalAmount

        // Recalculate vibrational score
        recalculateVibrationalScore()

        // Check achievements
        checkAchievements()

        // Check daily challenge
        checkDailyChallengeCompletion(source: source)

        try? ctx.save()
    }

    // MARK: - Vibrational Score

    func recalculateVibrationalScore() {
        guard let profile, let ctx = modelContext else { return }

        // Base level from lifetime XP (caps at 300)
        let baseLevel = min(300.0, Double(profile.totalXP) / 100.0)

        // Recent activity: XP earned in last 7 days (caps at 400)
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let descriptor = FetchDescriptor<XPEvent>(
            predicate: #Predicate { $0.createdAt >= sevenDaysAgo }
        )
        let recentXP = (try? ctx.fetch(descriptor))?.reduce(0) { $0 + $1.amount } ?? 0
        let recentActivity = min(400.0, Double(recentXP) * 0.5)

        // Streak bonus (caps at 100)
        let streak = UserDefaults.standard.integer(forKey: "streakCount")
        let streakBonus = min(100.0, Double(streak) * 5.0)

        // Balance bonus: ratio of smallest to largest framework XP (caps at 200)
        let fwXPs = [profile.vibrationalGameXP, profile.energyEnhancementXP, profile.apolluxXP]
        let maxFW = Double(fwXPs.max() ?? 1)
        let minFW = Double(fwXPs.min() ?? 0)
        let balanceMultiplier = maxFW > 0 ? minFW / maxFW : 0
        let balanceBonus = balanceMultiplier * 200.0

        let score = min(1000.0, baseLevel + recentActivity + streakBonus + balanceBonus)
        profile.vibrationalScore = score

        // Constitution rating
        switch score {
        case 0..<334:   profile.constitutionRating = "A"
        case 334..<667: profile.constitutionRating = "B"
        default:        profile.constitutionRating = "C"
        }
    }

    // MARK: - Multipliers

    func currentMultiplier() -> Double {
        var mult = 1.0

        // Streak multiplier: up to 1.6x at 30-day streak
        let streak = UserDefaults.standard.integer(forKey: "streakCount")
        mult += Double(min(streak, 30)) * 0.02

        // 11:11 PM window (11:00-11:30 PM): 1.5x
        let hour = Calendar.current.component(.hour, from: Date())
        let minute = Calendar.current.component(.minute, from: Date())
        if hour == 23 && minute >= 0 && minute <= 30 {
            mult += 0.5
        }

        // 11th or 22nd of month
        let day = Calendar.current.component(.day, from: Date())
        if day == 11 || day == 22 {
            mult += 0.25
        }

        return mult
    }

    // MARK: - Achievements

    private func checkAchievements() {
        guard let profile, let ctx = modelContext else { return }

        // Get already unlocked keys
        let descriptor = FetchDescriptor<Achievement>()
        let unlocked = Set((try? ctx.fetch(descriptor))?.map(\.key) ?? [])

        for def in AchievementCatalog.all {
            guard !unlocked.contains(def.key) else { continue }
            if shouldUnlock(def) {
                let achievement = Achievement()
                achievement.key = def.key
                achievement.title = def.title
                achievement.detail = def.detail
                achievement.icon = def.icon
                achievement.rarity = def.rarity
                achievement.framework = def.framework
                achievement.xpReward = def.xpReward
                ctx.insert(achievement)

                // Award bonus XP (without re-triggering achievement check)
                profile.totalXP += def.xpReward

                showAchievement = def
            }
        }
    }

    private func shouldUnlock(_ def: AchievementDef) -> Bool {
        guard let profile else { return false }

        switch def.key {
        case "first_flame":           return profile.totalXP > 0
        case "sacred_spark":          return profile.currentLevel >= 5
        case "rising_phoenix":        return profile.currentLevel >= 15
        case "divine_architect":      return profile.currentLevel >= 50
        case "week_devotion":
            return UserDefaults.standard.integer(forKey: "streakCount") >= 7
        case "moon_cycle":
            return UserDefaults.standard.integer(forKey: "streakCount") >= 30
        case "eternal_flame":
            return UserDefaults.standard.integer(forKey: "streakCount") >= 100
        case "trinity_balance":
            return todayFrameworks.count >= 3
        case "constitution_awakened":
            return profile.skillLevels["ee_constitution_xp"] ?? 0 > 0
        case "intent_set":
            return profile.skillLevels["ap_intent_xp"] ?? 0 > 0
        default:
            return false
        }
    }

    // MARK: - Daily Challenge

    private func checkDailyChallengeCompletion(source: String) {
        guard let challenge = todayChallenge, !challenge.isCompleted else { return }

        // Simplified: mark complete if the source matches part of the challenge key
        let key = challenge.challengeKey
        var shouldComplete = false

        switch key {
        case "journal_meditate":     shouldComplete = source == "journal" || source == "meditation"
        case "chakra_solfeggio":     shouldComplete = source == "chakra" || source == "solfeggio"
        case "gratitude_prayer":     shouldComplete = source == "gratitude" || source == "prayer"
        case "dream_sync":           shouldComplete = source == "dream" || source == "synchronicity"
        case "triple_framework":     shouldComplete = todayFrameworks.count >= 3
        case "energy_clear":         shouldComplete = source == "cord_cutting" || source == "meditation"
        case "mind_body":            shouldComplete = source == "mind_practice" || source == "chakra"
        case "seraphina_journal":    shouldComplete = source == "coach" || source == "journal"
        case "manifestation_day":    shouldComplete = source == "manifestation" || source == "prayer"
        case "oracle_meditate":      shouldComplete = source == "oracle" || source == "meditation"
        default: break
        }

        if shouldComplete {
            challenge.isCompleted = true
            challenge.completedAt = Date()
            // Award challenge XP
            awardXP(amount: challenge.xpReward, source: "daily_challenge", detail: "Daily challenge: \(challenge.title)")
        }
    }

    // MARK: - Queries

    func unlockedAchievementCount() -> Int {
        guard let ctx = modelContext else { return 0 }
        return (try? ctx.fetchCount(FetchDescriptor<Achievement>())) ?? 0
    }

    func recentEvents(limit: Int = 10) -> [XPEvent] {
        guard let ctx = modelContext else { return [] }
        var descriptor = FetchDescriptor<XPEvent>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        descriptor.fetchLimit = limit
        return (try? ctx.fetch(descriptor)) ?? []
    }

    func frameworkLevel(for fw: SacredFramework) -> Int {
        guard let profile else { return 0 }
        let fwXP: Int
        switch fw {
        case .vibrationalGame:   fwXP = profile.vibrationalGameXP
        case .energyEnhancement: fwXP = profile.energyEnhancementXP
        case .apollux:           fwXP = profile.apolluxXP
        }
        // Framework level: every 500 XP = 1 level
        return fwXP / 500
    }
}
