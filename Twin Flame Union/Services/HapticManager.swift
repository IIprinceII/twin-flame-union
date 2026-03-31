//
//  HapticManager.swift
//  Twin Flame Union
//
//  Centralised haptic feedback. Call from any @MainActor context.
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
