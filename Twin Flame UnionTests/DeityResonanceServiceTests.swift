import Testing
@testable import The_Twin_Flame_Union_App

struct DeityResonanceServiceTests {
    @Test func resonanceNamesBothDeitiesAndHasFourThemes() {
        let mine = DivinePantheon.deity(named: "Aphrodite")!
        let theirs = DivinePantheon.deity(named: "Isis")!
        let r = DeityResonanceService.resonance(mine: mine, theirs: theirs)
        #expect(r.narrative.contains("Aphrodite"))
        #expect(r.narrative.contains("Isis"))
        #expect(r.themes.count == 4)
    }

    @Test func resonanceIsDeterministic() {
        let mine = DivinePantheon.deity(named: "Eros")!
        let theirs = DivinePantheon.deity(named: "Osiris")!
        let a = DeityResonanceService.resonance(mine: mine, theirs: theirs)
        let b = DeityResonanceService.resonance(mine: mine, theirs: theirs)
        #expect(a.narrative == b.narrative)
        #expect(a.themes.map(\.body) == b.themes.map(\.body))
    }

    @Test func samePatronDoesNotDoubleTheName() {
        let isis = DivinePantheon.deity(named: "Isis")!
        let r = DeityResonanceService.resonance(mine: isis, theirs: isis)
        #expect(!r.narrative.contains("Isis and Isis"))
        #expect(r.themes.allSatisfy { !$0.body.contains("Isis and Isis") })
    }

    @Test func heartOpeningProseHasNoInterpunct() {
        let mine = DivinePantheon.deity(named: "Aphrodite")!
        let theirs = DivinePantheon.deity(named: "Isis")!
        let r = DeityResonanceService.resonance(mine: mine, theirs: theirs)
        let heart = r.themes.first { $0.title == "Heart Opening" }
        #expect(heart?.body.contains("·") == false)
    }
}
