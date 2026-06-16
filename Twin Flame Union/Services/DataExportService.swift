//
//  DataExportService.swift
//  Twin Flame Union
//
//  Builds a Codable snapshot of all user data for "Export My Data".
//  Export-only. The `schemaVersion` field future-proofs a later import path.
//

import Foundation
import SwiftData

// MARK: - Snapshot DTOs (plain Codable mirrors of the @Model types)

nonisolated struct DataExportSnapshot: Codable {
    var schemaVersion: String = "1.0.0"
    var exportedAt: Date = Date()
    var journalEntries: [JournalDTO] = []
    var dreamEntries: [DreamDTO] = []
    var synchronicities: [SynchronicityDTO] = []
    var chakraEntries: [ChakraDTO] = []
    var manifestations: [ManifestationDTO] = []
    var connectionMoments: [ConnectionMomentDTO] = []
    var prayers: [PrayerDTO] = []
    var gratitudeEntries: [GratitudeDTO] = []
    var soulProfiles: [SoulProfileDTO] = []
    var xpEvents: [XPEventDTO] = []
    var achievements: [AchievementDTO] = []
    var dailyChallenges: [DailyChallengeDTO] = []
}

nonisolated struct JournalDTO: Codable { var id: UUID; var title: String; var content: String; var mood: String; var createdAt: Date; var updatedAt: Date }
nonisolated struct DreamDTO: Codable { var id: UUID; var title: String; var content: String; var people: String; var symbols: String; var wakeFeeling: String; var isLucid: Bool; var isTwinFlameDream: Bool; var createdAt: Date }
nonisolated struct SynchronicityDTO: Codable { var id: UUID; var type: String; var detail: String; var note: String; var createdAt: Date }
nonisolated struct ChakraDTO: Codable { var id: UUID; var date: Date; var root: Int; var sacral: Int; var solarPlexus: Int; var heart: Int; var throat: Int; var thirdEye: Int; var crown: Int; var note: String }
nonisolated struct ManifestationDTO: Codable { var id: UUID; var intention: String; var emoji: String; var isManifested: Bool; var createdAt: Date }
nonisolated struct ConnectionMomentDTO: Codable { var id: UUID; var title: String; var detail: String; var category: String; var date: Date; var createdAt: Date }
nonisolated struct PrayerDTO: Codable { var id: UUID; var petition: String; var detail: String; var isAnswered: Bool; var answeredNote: String; var createdAt: Date; var answeredAt: Date? }
nonisolated struct GratitudeDTO: Codable { var id: UUID; var date: Date; var items: String }
nonisolated struct SoulProfileDTO: Codable { var id: UUID; var totalXP: Int; var vibrationalScore: Double; var vibrationalGameXP: Int; var energyEnhancementXP: Int; var apolluxXP: Int; var constitutionRating: String; var createdAt: Date; var lastActivityAt: Date; var skillLevels: [String: Int] }
nonisolated struct XPEventDTO: Codable { var id: UUID; var amount: Int; var source: String; var framework: String; var skillKey: String; var detail: String; var createdAt: Date }
nonisolated struct AchievementDTO: Codable { var id: UUID; var key: String; var title: String; var detail: String; var icon: String; var rarity: String; var framework: String; var unlockedAt: Date; var xpReward: Int }
nonisolated struct DailyChallengeDTO: Codable { var id: UUID; var date: Date; var challengeKey: String; var title: String; var detail: String; var xpReward: Int; var isCompleted: Bool; var completedAt: Date? }

// MARK: - Service

enum DataExportService {

    static func snapshot(from context: ModelContext) throws -> DataExportSnapshot {
        var snap = DataExportSnapshot()

        snap.journalEntries = try context.fetch(FetchDescriptor<JournalEntry>()).map {
            JournalDTO(id: $0.id, title: $0.title, content: $0.content, mood: $0.mood, createdAt: $0.createdAt, updatedAt: $0.updatedAt)
        }
        snap.dreamEntries = try context.fetch(FetchDescriptor<DreamEntry>()).map {
            DreamDTO(id: $0.id, title: $0.title, content: $0.content, people: $0.people, symbols: $0.symbols, wakeFeeling: $0.wakeFeeling, isLucid: $0.isLucid, isTwinFlameDream: $0.isTwinFlameDream, createdAt: $0.createdAt)
        }
        snap.synchronicities = try context.fetch(FetchDescriptor<SynchronicityEntry>()).map {
            SynchronicityDTO(id: $0.id, type: $0.type, detail: $0.detail, note: $0.note, createdAt: $0.createdAt)
        }
        snap.chakraEntries = try context.fetch(FetchDescriptor<ChakraEntry>()).map {
            ChakraDTO(id: $0.id, date: $0.date, root: $0.root, sacral: $0.sacral, solarPlexus: $0.solarPlexus, heart: $0.heart, throat: $0.throat, thirdEye: $0.thirdEye, crown: $0.crown, note: $0.note)
        }
        snap.manifestations = try context.fetch(FetchDescriptor<ManifestationItem>()).map {
            ManifestationDTO(id: $0.id, intention: $0.intention, emoji: $0.emoji, isManifested: $0.isManifested, createdAt: $0.createdAt)
        }
        snap.connectionMoments = try context.fetch(FetchDescriptor<ConnectionMoment>()).map {
            ConnectionMomentDTO(id: $0.id, title: $0.title, detail: $0.detail, category: $0.category, date: $0.date, createdAt: $0.createdAt)
        }
        snap.prayers = try context.fetch(FetchDescriptor<PrayerEntry>()).map {
            PrayerDTO(id: $0.id, petition: $0.petition, detail: $0.detail, isAnswered: $0.isAnswered, answeredNote: $0.answeredNote, createdAt: $0.createdAt, answeredAt: $0.answeredAt)
        }
        snap.gratitudeEntries = try context.fetch(FetchDescriptor<GratitudeEntry>()).map {
            GratitudeDTO(id: $0.id, date: $0.date, items: $0.items)
        }
        snap.soulProfiles = try context.fetch(FetchDescriptor<SoulProfile>()).map {
            SoulProfileDTO(id: $0.id, totalXP: $0.totalXP, vibrationalScore: $0.vibrationalScore, vibrationalGameXP: $0.vibrationalGameXP, energyEnhancementXP: $0.energyEnhancementXP, apolluxXP: $0.apolluxXP, constitutionRating: $0.constitutionRating, createdAt: $0.createdAt, lastActivityAt: $0.lastActivityAt, skillLevels: $0.skillLevels)
        }
        snap.xpEvents = try context.fetch(FetchDescriptor<XPEvent>()).map {
            XPEventDTO(id: $0.id, amount: $0.amount, source: $0.source, framework: $0.framework, skillKey: $0.skillKey, detail: $0.detail, createdAt: $0.createdAt)
        }
        snap.achievements = try context.fetch(FetchDescriptor<Achievement>()).map {
            AchievementDTO(id: $0.id, key: $0.key, title: $0.title, detail: $0.detail, icon: $0.icon, rarity: $0.rarity, framework: $0.framework, unlockedAt: $0.unlockedAt, xpReward: $0.xpReward)
        }
        snap.dailyChallenges = try context.fetch(FetchDescriptor<DailyChallenge>()).map {
            DailyChallengeDTO(id: $0.id, date: $0.date, challengeKey: $0.challengeKey, title: $0.title, detail: $0.detail, xpReward: $0.xpReward, isCompleted: $0.isCompleted, completedAt: $0.completedAt)
        }
        return snap
    }

    static func encode(_ snapshot: DataExportSnapshot) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(snapshot)
    }
}
