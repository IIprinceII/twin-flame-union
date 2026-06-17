import Testing
import SwiftUI
import UIKit
@testable import The_Twin_Flame_Union_App

struct AccessibilityHelpersTests {

    @Test func calmReturnsNilWhenReduceMotionOn() {
        #expect(Animation.calm(true, .easeInOut(duration: 1)) == nil)
        #expect(Animation.calm(false, .easeInOut(duration: 1)) != nil)
    }

    @Test func fontWeightMapsToUIFontWeight() {
        #expect(Font.Weight.regular.uiWeight == .regular)
        #expect(Font.Weight.semibold.uiWeight == .semibold)
        #expect(Font.Weight.bold.uiWeight == .bold)
        #expect(Font.Weight.light.uiWeight == .light)
    }
}
