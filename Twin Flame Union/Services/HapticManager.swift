//
//  HapticManager.swift
//  Twin Flame Union
//
//  Centralised haptic feedback. Call from any @MainActor context.
//
//  Conventions (apply consistently across the app):
//   • impact(.light)         — selection / navigation (tab, row, segment, picker)
//   • impact(.medium)        — primary actions (Begin, Submit, Save, Send)
//   • notification(.success) — completions (ritual / meditation done, XP, achievement, save success)
//   • notification(.error)   — failures (request / save failed)
//

import UIKit

enum HapticManager {

    /// Short physical tap — buttons, selections, chips
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    /// Success / warning / error feedback
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

    /// Light tick — list item selection, toggle, scroll snap
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
