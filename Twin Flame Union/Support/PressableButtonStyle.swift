//
//  PressableButtonStyle.swift
//  Twin Flame Union
//
//  Tactile press feedback: subtle scale + dim, and (by default) a light haptic on press-down.
//  Use `PressableButtonStyle(haptic: false)` for buttons that already fire their own haptic
//  in the action, to get the scale/dim press feel without a doubled haptic.
//

import SwiftUI

struct PressableButtonStyle: ButtonStyle {
    var haptic: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed && haptic { HapticManager.impact(.light) }
            }
    }
}
