//
//  SkillTreeDefinitions.swift
//  Twin Flame Union
//
//  Static definitions for the three framework skill trees.
//

import SwiftUI

// MARK: - Framework

enum SacredFramework: String, CaseIterable, Identifiable {
    case vibrationalGame   = "vibrational"
    case energyEnhancement = "energy"
    case apollux           = "apollux"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .vibrationalGame:   return "The Vibrational Game"
        case .energyEnhancement: return "Energy Enhancement"
        case .apollux:           return "Apollux"
        }
    }

    var subtitle: String {
        switch self {
        case .vibrationalGame:   return "Energy & Relationships"
        case .energyEnhancement: return "Body & Aura Elevation"
        case .apollux:           return "Mind Optimization"
        }
    }

    var icon: String {
        switch self {
        case .vibrationalGame:   return "waveform"
        case .energyEnhancement: return "bolt.fill"
        case .apollux:           return "brain.head.profile"
        }
    }

    var color: Color {
        switch self {
        case .vibrationalGame:   return AppColors.coral
        case .energyEnhancement: return Color(hex: "FF4500")
        case .apollux:           return AppColors.gold
        }
    }

    var nodes: [SkillNode] { SkillNode.nodesFor(self) }
}

// MARK: - Skill Node

struct SkillNode: Identifiable {
    let id: String
    let framework: SacredFramework
    let title: String
    let icon: String
    let color: Color
    let maxLevel: Int
    let xpPerLevel: Int
    let prerequisites: [String]
    let description: String

    static func nodesFor(_ fw: SacredFramework) -> [SkillNode] {
        switch fw {
        case .vibrationalGame:   return vibrationalNodes
        case .energyEnhancement: return energyNodes
        case .apollux:           return apolluxNodes
        }
    }

    // ─── Vibrational Game ────────────────────────────────────
    private static let vibrationalNodes: [SkillNode] = [
        SkillNode(id: "vg_influence", framework: .vibrationalGame,
                  title: "Influence & Vibration", icon: "waveform",
                  color: AppColors.coral, maxLevel: 10, xpPerLevel: 80,
                  prerequisites: [],
                  description: "Understand that energy exerts influence over everything. All behaviors come down to vibration."),
        SkillNode(id: "vg_connections", framework: .vibrationalGame,
                  title: "Connections & Power", icon: "arrow.left.arrow.right",
                  color: Color(hex: "4A90D9"), maxLevel: 10, xpPerLevel: 100,
                  prerequisites: ["vg_influence"],
                  description: "Master connectivity levels and power dynamics. Understand why the chaser gives power to the runner."),
        SkillNode(id: "vg_push_pull", framework: .vibrationalGame,
                  title: "Push & Pull Dynamics", icon: "arrow.up.arrow.down",
                  color: Color(hex: "E74C8B"), maxLevel: 10, xpPerLevel: 100,
                  prerequisites: ["vg_influence"],
                  description: "Understand energy voids (pull) and energy fills (push). Master the dynamics of longing and distance."),
        SkillNode(id: "vg_language", framework: .vibrationalGame,
                  title: "Energy Language", icon: "text.bubble.fill",
                  color: AppColors.sage, maxLevel: 10, xpPerLevel: 100,
                  prerequisites: ["vg_connections"],
                  description: "All language contains energy equations — tensions, resolutions, circuits. Master the vibrational weight of words."),
        SkillNode(id: "vg_generating", framework: .vibrationalGame,
                  title: "Generating Vibrations", icon: "sparkles",
                  color: AppColors.gold, maxLevel: 10, xpPerLevel: 120,
                  prerequisites: ["vg_push_pull", "vg_language"],
                  description: "Construct vibrations at every level — word, conversation, relationship. Small shifts compound into massive changes."),
    ]

    // ─── Energy Enhancement ──────────────────────────────────
    private static let energyNodes: [SkillNode] = [
        SkillNode(id: "ee_constitution", framework: .energyEnhancement,
                  title: "Vibrational Constitution", icon: "sun.max.fill",
                  color: Color(hex: "FFD700"), maxLevel: 10, xpPerLevel: 80,
                  prerequisites: [],
                  description: "Understand your energy spectrum: Low (A), Medium (B), High (C). Assess and elevate your constitution."),
        SkillNode(id: "ee_elimination", framework: .energyEnhancement,
                  title: "Elimination & Flow", icon: "arrow.up.right.circle.fill",
                  color: Color(hex: "FF4500"), maxLevel: 10, xpPerLevel: 100,
                  prerequisites: ["ee_constitution"],
                  description: "Activate your elimination system — skin, lungs, heart, blood — to exchange lower vibrations for higher ones."),
        SkillNode(id: "ee_physical", framework: .energyEnhancement,
                  title: "Physical Methods", icon: "figure.walk",
                  color: AppColors.sage, maxLevel: 10, xpPerLevel: 100,
                  prerequisites: ["ee_constitution"],
                  description: "Stretching, vibration tones, running water, speed — stimulate energy motility through physical means."),
        SkillNode(id: "ee_visualization", framework: .energyEnhancement,
                  title: "Visualization Methods", icon: "eye.fill",
                  color: Color(hex: "3D9BE9"), maxLevel: 10, xpPerLevel: 100,
                  prerequisites: ["ee_physical"],
                  description: "Sense, brighten, pull, and quicken energy through the mind. Direct influence over your energy body."),
        SkillNode(id: "ee_blockage", framework: .energyEnhancement,
                  title: "Blockage Clearing", icon: "xmark.circle.fill",
                  color: Color(hex: "E53935"), maxLevel: 10, xpPerLevel: 100,
                  prerequisites: ["ee_elimination", "ee_visualization"],
                  description: "Use physical + mental methods in tandem to clear blockages. Blockage clearing is math."),
        SkillNode(id: "ee_ritual", framework: .energyEnhancement,
                  title: "The 11:11 Ritual", icon: "clock.fill",
                  color: AppColors.coral, maxLevel: 10, xpPerLevel: 120,
                  prerequisites: [],
                  description: "The foundation practice. 11 or 22 minutes at 11:11 PM. Extra potency on the 11th and 22nd."),
    ]

    // ─── Apollux ─────────────────────────────────────────────
    private static let apolluxNodes: [SkillNode] = [
        SkillNode(id: "ap_intent", framework: .apollux,
                  title: "Intent Calibration", icon: "target",
                  color: AppColors.gold, maxLevel: 10, xpPerLevel: 80,
                  prerequisites: [],
                  description: "Intent is the lifeblood of progress. Too strong = overextension. Too weak = no persistence. Calibrate."),
        SkillNode(id: "ap_focus", framework: .apollux,
                  title: "Foundational Focus", icon: "scope",
                  color: Color(hex: "9B59B6"), maxLevel: 10, xpPerLevel: 100,
                  prerequisites: ["ap_intent"],
                  description: "The basis for everything in the mind. Without foundational focus, intent scatters."),
        SkillNode(id: "ap_optimization", framework: .apollux,
                  title: "Mind Optimization", icon: "brain.head.profile",
                  color: Color(hex: "5B8CFF"), maxLevel: 10, xpPerLevel: 100,
                  prerequisites: ["ap_focus"],
                  description: "Visualization mastery, memory stability, mental state management, loop breaking."),
        SkillNode(id: "ap_calculation", framework: .apollux,
                  title: "Contextualization", icon: "arrow.triangle.branch",
                  color: AppColors.sage, maxLevel: 10, xpPerLevel: 100,
                  prerequisites: ["ap_focus"],
                  description: "Process thoughts in relationship. Build connections between data points. Sequence efficiently."),
        SkillNode(id: "ap_awareness", framework: .apollux,
                  title: "Awareness Expansion", icon: "eye.circle.fill",
                  color: Color(hex: "4A90D9"), maxLevel: 10, xpPerLevel: 100,
                  prerequisites: ["ap_optimization"],
                  description: "Stretch the bounds of perception. See signs, patterns, and energies you previously missed."),
        SkillNode(id: "ap_emotional_fuel", framework: .apollux,
                  title: "Emotional Fuel", icon: "flame.fill",
                  color: Color(hex: "FF6B47"), maxLevel: 10, xpPerLevel: 100,
                  prerequisites: ["ap_intent"],
                  description: "Emotions are octane. Strong emotion amplifies everything. Channel wisely — or it powers the wrong engine."),
        SkillNode(id: "ap_wisdom", framework: .apollux,
                  title: "Wisdom", icon: "crown.fill",
                  color: Color(hex: "FFD700"), maxLevel: 10, xpPerLevel: 150,
                  prerequisites: ["ap_awareness", "ap_calculation", "ap_emotional_fuel"],
                  description: "The apex. Optimal long/short term balance. Protecting internal treasures. The master skill."),
    ]
}

// MARK: - Achievement Definitions

struct AchievementDef {
    let key: String
    let title: String
    let detail: String
    let icon: String
    let rarity: String
    let framework: String
    let xpReward: Int
}

enum AchievementCatalog {
    static let all: [AchievementDef] = general + vibrational + energy + apollux + hidden

    private static let general: [AchievementDef] = [
        AchievementDef(key: "first_flame", title: "First Flame", detail: "Begin your sacred journey.", icon: "flame.fill", rarity: "common", framework: "general", xpReward: 10),
        AchievementDef(key: "sacred_spark", title: "Sacred Spark", detail: "Reach Level 5.", icon: "sparkles", rarity: "common", framework: "general", xpReward: 50),
        AchievementDef(key: "rising_phoenix", title: "Rising Phoenix", detail: "Reach Level 15.", icon: "bird.fill", rarity: "rare", framework: "general", xpReward: 100),
        AchievementDef(key: "divine_architect", title: "Divine Architect", detail: "Reach Level 50.", icon: "crown.fill", rarity: "legendary", framework: "general", xpReward: 500),
        AchievementDef(key: "week_devotion", title: "Week of Devotion", detail: "Maintain a 7-day streak.", icon: "flame.circle.fill", rarity: "common", framework: "general", xpReward: 75),
        AchievementDef(key: "moon_cycle", title: "Moon Cycle Master", detail: "Maintain a 30-day streak.", icon: "moon.stars.fill", rarity: "epic", framework: "general", xpReward: 200),
        AchievementDef(key: "eternal_flame", title: "Eternal Flame", detail: "Maintain a 100-day streak.", icon: "flame.fill", rarity: "legendary", framework: "general", xpReward: 500),
        AchievementDef(key: "trinity_balance", title: "Trinity Balance", detail: "Earn XP in all three frameworks in a single day.", icon: "triangle.fill", rarity: "rare", framework: "general", xpReward: 100),
    ]

    private static let vibrational: [AchievementDef] = [
        AchievementDef(key: "energy_awakening", title: "Energy Awakening", detail: "Complete all Vibrational Game lessons.", icon: "waveform", rarity: "common", framework: "vibrational", xpReward: 50),
        AchievementDef(key: "connection_mapper", title: "Connection Mapper", detail: "Log 10 connection moments.", icon: "point.3.connected.trianglepath.dotted", rarity: "common", framework: "vibrational", xpReward: 50),
        AchievementDef(key: "sacred_linguist", title: "Sacred Linguist", detail: "Write 25 prayers.", icon: "text.book.closed.fill", rarity: "rare", framework: "vibrational", xpReward: 100),
        AchievementDef(key: "vibration_builder", title: "Vibration Builder", detail: "Manifest 3 items from the board.", icon: "checkmark.seal.fill", rarity: "epic", framework: "vibrational", xpReward: 150),
        AchievementDef(key: "hermes_protocol", title: "Hermes Protocol", detail: "Log 50 synchronicities.", icon: "bolt.fill", rarity: "rare", framework: "vibrational", xpReward: 100),
        AchievementDef(key: "harmonias_balance", title: "Harmonia's Balance", detail: "Vibrational Score above 667 for 7 days.", icon: "waveform", rarity: "legendary", framework: "vibrational", xpReward: 300),
    ]

    private static let energy: [AchievementDef] = [
        AchievementDef(key: "constitution_awakened", title: "Constitution Awakened", detail: "Complete your first chakra check-in.", icon: "rays", rarity: "common", framework: "energy", xpReward: 25),
        AchievementDef(key: "frequency_healer", title: "Frequency Healer", detail: "Use solfeggio frequencies for 60+ minutes total.", icon: "waveform.circle.fill", rarity: "rare", framework: "energy", xpReward: 75),
        AchievementDef(key: "1111_devotee", title: "11:11 Devotee", detail: "Complete the 11:11 ritual 11 times.", icon: "clock.fill", rarity: "rare", framework: "energy", xpReward: 100),
        AchievementDef(key: "1111_on_11th", title: "11:11 on the 11th", detail: "Complete the ritual on the 11th of any month.", icon: "sparkles", rarity: "epic", framework: "energy", xpReward: 150),
        AchievementDef(key: "master_number", title: "Master Number", detail: "Complete the ritual on 11/11 at 11:11 PM.", icon: "star.fill", rarity: "legendary", framework: "energy", xpReward: 500),
        AchievementDef(key: "sekhmets_fire", title: "Sekhmet's Fire", detail: "All Energy Enhancement skills at level 5+.", icon: "flame.fill", rarity: "epic", framework: "energy", xpReward: 200),
        AchievementDef(key: "radiant_constitution", title: "Radiant Constitution", detail: "Maintain 'C' constitution for 14 days.", icon: "sun.max.fill", rarity: "legendary", framework: "energy", xpReward: 300),
    ]

    private static let apollux: [AchievementDef] = [
        AchievementDef(key: "intent_set", title: "Intent Set", detail: "Create your first manifestation intention.", icon: "target", rarity: "common", framework: "apollux", xpReward: 25),
        AchievementDef(key: "thought_holder", title: "Thought Holder", detail: "Complete thought stabilization 10 times.", icon: "brain.head.profile", rarity: "common", framework: "apollux", xpReward: 50),
        AchievementDef(key: "dream_walker", title: "Dream Walker", detail: "Log 20 dreams.", icon: "moon.zzz.fill", rarity: "rare", framework: "apollux", xpReward: 75),
        AchievementDef(key: "darkness_navigator", title: "Darkness Navigator", detail: "Complete 10 darkness meditations.", icon: "moon.fill", rarity: "epic", framework: "apollux", xpReward: 150),
        AchievementDef(key: "emotional_alchemist", title: "Emotional Alchemist", detail: "Journal with 7 different emotional states.", icon: "flame.fill", rarity: "rare", framework: "apollux", xpReward: 75),
        AchievementDef(key: "athenas_wisdom", title: "Athena's Wisdom", detail: "All Apollux skills at level 5+.", icon: "lightbulb.fill", rarity: "epic", framework: "apollux", xpReward: 200),
        AchievementDef(key: "mind_sovereign", title: "Mind Sovereign", detail: "Complete every mind practice at least 3 times.", icon: "crown.fill", rarity: "legendary", framework: "apollux", xpReward: 300),
    ]

    private static let hidden: [AchievementDef] = [
        AchievementDef(key: "twin_flame_dream", title: "Twin Flame Dream", detail: "Log a dream marked as a twin flame dream.", icon: "moon.stars.fill", rarity: "common", framework: "general", xpReward: 30),
        AchievementDef(key: "full_moon_ritual", title: "Full Moon Ritual", detail: "Complete a meditation during a full moon.", icon: "moon.circle.fill", rarity: "rare", framework: "general", xpReward: 50),
        AchievementDef(key: "astral_linkage", title: "The Astral Linkage", detail: "Earn XP in all three frameworks in one session.", icon: "link.circle.fill", rarity: "rare", framework: "general", xpReward: 100),
        AchievementDef(key: "golden_ratio", title: "Golden Ratio", detail: "Equal XP in all three frameworks (within 5%).", icon: "infinity", rarity: "legendary", framework: "general", xpReward: 300),
        AchievementDef(key: "answered_prayer", title: "Answered Prayer", detail: "Mark a prayer as answered.", icon: "hands.sparkles.fill", rarity: "epic", framework: "general", xpReward: 100),
        AchievementDef(key: "pantheon_scholar", title: "Pantheon Scholar", detail: "Experience 22 different deity days.", icon: "text.book.closed.fill", rarity: "epic", framework: "general", xpReward: 150),
    ]
}

// MARK: - Daily Challenge Templates

struct ChallengeTemplate {
    let key: String
    let title: String
    let detail: String
    let xpReward: Int
}

enum DailyChallengeTemplates {
    static let all: [ChallengeTemplate] = [
        ChallengeTemplate(key: "journal_meditate", title: "Soul & Stillness", detail: "Write a journal entry AND complete a meditation today.", xpReward: 75),
        ChallengeTemplate(key: "chakra_solfeggio", title: "Frequency Alignment", detail: "Complete a chakra check-in AND listen to solfeggio frequencies.", xpReward: 75),
        ChallengeTemplate(key: "gratitude_prayer", title: "Sacred Exchange", detail: "Log gratitude AND write a prayer today.", xpReward: 60),
        ChallengeTemplate(key: "dream_sync", title: "Dream & Sign", detail: "Log a dream AND a synchronicity today.", xpReward: 70),
        ChallengeTemplate(key: "triple_framework", title: "Trinity Practice", detail: "Earn XP from all three frameworks in one day.", xpReward: 100),
        ChallengeTemplate(key: "energy_clear", title: "Energy Clearing", detail: "Complete a cord cutting AND a meditation today.", xpReward: 80),
        ChallengeTemplate(key: "mind_body", title: "Mind-Body Bridge", detail: "Complete a mind practice AND log a chakra check-in.", xpReward: 80),
        ChallengeTemplate(key: "seraphina_journal", title: "Divine Dialogue", detail: "Ask Seraphina a question AND write a journal entry.", xpReward: 70),
        ChallengeTemplate(key: "manifestation_day", title: "Manifestation Day", detail: "Add an intention to your manifestation board AND write a prayer.", xpReward: 65),
        ChallengeTemplate(key: "oracle_meditate", title: "Oracle & Stillness", detail: "Pull your oracle card AND complete a meditation.", xpReward: 60),
    ]

    static func forToday() -> ChallengeTemplate {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return all[day % all.count]
    }
}
