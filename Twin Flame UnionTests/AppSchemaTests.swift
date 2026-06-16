import Testing
import SwiftData
@testable import The_Twin_Flame_Union_App

struct AppSchemaTests {

    @Test func versionedSchemaListsAllTwelveModels() {
        #expect(AppSchemaV1.models.count == 12)
        #expect(AppSchemaV1.versionIdentifier == Schema.Version(1, 0, 0))
    }

    @Test func containerBuildsFromMigrationPlanAndRoundTrips() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Schema(AppSchemaV1.models),
            migrationPlan: TFUMigrationPlan.self,
            configurations: [config]
        )
        let context = ModelContext(container)
        context.insert(DreamEntry(title: "Test Dream"))
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<DreamEntry>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.title == "Test Dream")
    }
}
