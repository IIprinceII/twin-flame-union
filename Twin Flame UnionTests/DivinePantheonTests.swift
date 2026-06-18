import Testing
@testable import The_Twin_Flame_Union_App

struct DivinePantheonTests {
    @Test func deityNamedFindsRealDeityAndNilForUnknown() {
        #expect(DivinePantheon.deity(named: "Aphrodite")?.culture == "Greek")
        #expect(DivinePantheon.deity(named: "Isis")?.culture == "Egyptian")
        #expect(DivinePantheon.deity(named: "Quetzalcoatl")?.culture == "Mexica")
        #expect(DivinePantheon.deity(named: "NotAGod") == nil)
    }

    @Test func groupedCoversEveryDeityAcrossThreeCultures() {
        let groups = DivinePantheon.grouped()
        #expect(groups.map(\.culture) == ["Greek", "Egyptian", "Mexica"])
        let total = groups.reduce(0) { $0 + $1.deities.count }
        #expect(total == DivinePantheon.all.count)
    }
}
