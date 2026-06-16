import Testing
import SwiftData
import Foundation
@testable import The_Twin_Flame_Union_App

struct ModelDefaultsTests {

    // Building the full production schema in-memory and round-tripping one of each
    // model proves the property-level defaults don't break persistence.
    @Test func fullSchemaPersistsEveryModel() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Schema(AppSchemaV1.models), configurations: [config])
        let ctx = ModelContext(container)

        ctx.insert(JournalEntry(title: "j"))
        ctx.insert(DreamEntry(title: "d"))
        ctx.insert(SynchronicityEntry(type: "Angel Number"))
        ctx.insert(ChakraEntry())
        ctx.insert(ManifestationItem(intention: "m"))
        ctx.insert(ConnectionMoment(title: "c"))
        ctx.insert(PrayerEntry(petition: "p"))
        ctx.insert(GratitudeEntry())
        ctx.insert(SoulProfile())
        ctx.insert(XPEvent(amount: 10))
        ctx.insert(Achievement(key: "a"))
        ctx.insert(DailyChallenge())
        try ctx.save()

        #expect(try ctx.fetch(FetchDescriptor<JournalEntry>()).count == 1)
        #expect(try ctx.fetch(FetchDescriptor<SoulProfile>()).count == 1)
        #expect(try ctx.fetch(FetchDescriptor<DailyChallenge>()).count == 1)
    }

    @Test func defaultInitsProduceExpectedValues() {
        #expect(JournalEntry().mood == "Hopeful")
        #expect(DreamEntry().isLucid == false)
        #expect(ChakraEntry().heart == 3)
        #expect(ManifestationItem().emoji == "✨")
        #expect(SoulProfile().constitutionRating == "A")
        #expect(DailyChallenge().xpReward == 50)
    }
}
