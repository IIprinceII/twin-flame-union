//
//  ReadableWidth.swift
//  Twin Flame Union
//
//  Constrains content to a centered, readable column on large screens (iPad /
//  landscape) while staying full-width on a phone in portrait.
//

import SwiftUI

private struct ReadableWidth: ViewModifier {
    var maxWidth: CGFloat = 680
    func body(content: Content) -> some View {
        content.frame(maxWidth: maxWidth).frame(maxWidth: .infinity)
    }
}

extension View {
    /// Constrains content to a centered, readable column on large screens (iPad /
    /// landscape) while staying full-width on a phone in portrait. Apply to the
    /// CONTENT inside a scroll view — never to a full-bleed background.
    func readableWidth(_ maxWidth: CGFloat = 680) -> some View {
        modifier(ReadableWidth(maxWidth: maxWidth))
    }
}
