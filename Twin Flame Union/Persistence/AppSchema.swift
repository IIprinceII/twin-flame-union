//
//  AppSchema.swift
//  Twin Flame Union
//
//  Versioned SwiftData schema + migration plan. AppSchemaV1 freezes the current
//  model shape as the documented baseline. A future AppSchemaV2 is a small diff:
//  add the new versioned schema to `schemas` and one stage to `stages`.
//

import Foundation
import SwiftData

enum AppSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static let models: [any PersistentModel.Type] = [
        JournalEntry.self,
        DreamEntry.self,
        SynchronicityEntry.self,
        ChakraEntry.self,
        ManifestationItem.self,
        ConnectionMoment.self,
        PrayerEntry.self,
        GratitudeEntry.self,
        SoulProfile.self,
        XPEvent.self,
        Achievement.self,
        DailyChallenge.self,
    ]
}

enum TFUMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [AppSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []   // No migrations yet. Add a stage here when AppSchemaV2 lands.
    }
}
