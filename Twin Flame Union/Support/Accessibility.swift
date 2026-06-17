//
//  Accessibility.swift
//  Twin Flame Union
//
//  Shared accessibility helpers: Reduce Motion gating + Dynamic Type weight mapping.
//

import SwiftUI
import UIKit

extension Animation {
    /// The base animation, or `nil` when Reduce Motion is on — so callers can drop
    /// looping/decorative motion. Usage:
    ///   `.animation(.calm(reduceMotion, .easeInOut(duration: 2).repeatForever()), value: x)`
    static func calm(_ reduceMotion: Bool, _ base: Animation) -> Animation? {
        reduceMotion ? nil : base
    }
}

extension Font.Weight {
    /// The matching `UIFont.Weight`, for building Dynamic-Type-scaled system fonts via UIFontMetrics.
    var uiWeight: UIFont.Weight {
        if self == .ultraLight { return .ultraLight }
        if self == .thin       { return .thin }
        if self == .light      { return .light }
        if self == .medium     { return .medium }
        if self == .semibold   { return .semibold }
        if self == .bold       { return .bold }
        if self == .heavy      { return .heavy }
        if self == .black      { return .black }
        return .regular
    }
}
