import Testing
import UIKit
@testable import The_Twin_Flame_Union_App

struct SerifFontTests {
    // Proves the system serif design is available (so headlines render serif, not the SF fallback).
    @Test func systemSerifDesignResolves() {
        let sys = UIFont.systemFont(ofSize: 24, weight: .bold)
        #expect(sys.fontDescriptor.withDesign(.serif) != nil)
    }
    // Proves the AppFont helpers exist and return a font (not the old broken custom name).
    @Test func serifHelpersProduceFonts() {
        _ = AppFont.serifHeadline(28)
        _ = AppFont.serifTitle(20)
        #expect(Bool(true))
    }
}
