import Testing
@testable import The_Twin_Flame_Union_App

struct DeityResonanceServiceTests {
    @Test func resonanceNamesBothDeitiesAndHasThemes() {
        let mine = DivinePantheon.deity(named: "Aphrodite")!
        let theirs = DivinePantheon.deity(named: "Isis")!
        let r = DeityResonanceService.resonance(mine: mine, theirs: theirs)
        #expect(r.narrative.contains("Aphrodite"))
        #expect(r.narrative.contains("Isis"))
        #expect(r.themes.count >= 3)
    }

    @Test func resonanceIsDeterministic() {
        let mine = DivinePantheon.deity(named: "Eros")!
        let theirs = DivinePantheon.deity(named: "Osiris")!
        let a = DeityResonanceService.resonance(mine: mine, theirs: theirs)
        let b = DeityResonanceService.resonance(mine: mine, theirs: theirs)
        #expect(a.narrative == b.narrative)
        #expect(a.themes.map(\.title) == b.themes.map(\.title))
    }
}
