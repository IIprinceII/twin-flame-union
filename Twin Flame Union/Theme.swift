//
//  Theme.swift
//  Twin Flame Union
//
//  Design system: ethereal, mystical, celestial
//

import SwiftUI
import UIKit

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            assertionFailure("Color(hex:) — unsupported hex string: '\(hex)'")
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - App Color Palette

enum AppColors {
    static let deepViolet = Color(hex: "0E0620")   // deeper, richer void
    static let purple     = Color(hex: "7B35B8")   // Aphrodite's violet
    static let gold       = Color(hex: "F0C060")   // Athena's true gold
    static let rose       = Color(hex: "E8739A")   // Aphrodite's rose
    static let sage       = Color(hex: "7EC8A0")   // Hygieia's healing green
    static let coral      = Color(hex: "CC88FF")   // soft lavender-violet
    static let cream      = Color(hex: "F5EFE6")   // Hestia's warm hearth-light
    static let lavender   = Color(hex: "B8A8D0")   // softer, more luminous
    static let ember      = Color(hex: "FF9A6C")   // Hestia's hearthfire
}

// MARK: - Gradient Definitions

enum AppGradients {
    /// Deep void into sacred violet — Hestia's night sky
    static let dark = LinearGradient(
        colors: [AppColors.deepViolet, Color(hex: "1A0830")],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Athena's gold to Aphrodite's rose — warm and divine
    static let warm = LinearGradient(
        colors: [Color(hex: "9B4FCC"), Color(hex: "4C1D95")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// The sacred cosmos — Panacea's infinite healing sky
    static let cosmic = LinearGradient(
        colors: [
            Color(hex: "1A0830"),
            Color(hex: "0D0418"),
            Color(hex: "060212")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Gold sunrise — Athena's dawn wisdom
    static let golden = LinearGradient(
        colors: [Color(hex: "F0C060"), Color(hex: "E8A040")],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Aphrodite's rose — divine love and grace
    static let rose = LinearGradient(
        colors: [Color(hex: "CC6699"), Color(hex: "9B35A0")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Typography

enum AppFont {
    // Serif headlines — Georgia with New York as preferred option
    static func serifHeadline(_ size: CGFloat) -> Font {
        .custom("NewYork-Bold", size: size, relativeTo: .largeTitle)
    }

    static func serifTitle(_ size: CGFloat) -> Font {
        .custom("NewYork-Regular", size: size, relativeTo: .title)
    }

    // Fallback-safe serif using Georgia (always available on iOS)
    static func headline(_ size: CGFloat) -> Font {
        .custom("Georgia-Bold", size: size, relativeTo: .headline)
    }

    static func title(_ size: CGFloat) -> Font {
        .custom("Georgia", size: size, relativeTo: .title)
    }

    // System font for body text
    static func body(_ size: CGFloat = 16, weight: Font.Weight = .regular) -> Font {
        let base = UIFont.systemFont(ofSize: size, weight: weight.uiWeight)
        return Font(UIFontMetrics(forTextStyle: .body).scaledFont(for: base))
    }

    static func caption(_ size: CGFloat = 13, weight: Font.Weight = .regular) -> Font {
        let base = UIFont.systemFont(ofSize: size, weight: weight.uiWeight)
        return Font(UIFontMetrics(forTextStyle: .caption1).scaledFont(for: base))
    }
}

// MARK: - Reusable View Modifiers

struct DarkBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppGradients.dark.ignoresSafeArea())
    }
}

struct WarmButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFont.body(16, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 14)
            .background(AppGradients.warm, in: Capsule())
            .shadow(color: Color(hex: "8B5CF6").opacity(0.45), radius: 16, y: 8)
    }
}

struct PrimaryAuthButton: ViewModifier {
    var isEnabled: Bool = true

    func body(content: Content) -> some View {
        content
            .font(AppFont.body(16, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                isEnabled ? AppColors.purple : AppColors.lavender.opacity(0.3),
                in: RoundedRectangle(cornerRadius: 14)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        isEnabled ? Color.white.opacity(0.15) : Color.clear,
                        lineWidth: 1
                    )
            )
            .shadow(color: isEnabled ? AppColors.purple.opacity(0.6) : .clear, radius: 14, y: 7)
            .opacity(isEnabled ? 1 : 0.6)
    }
}

// MARK: - Loading Overlay

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            AppColors.deepViolet.opacity(0.7)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.3)
                Text("Connecting to the universe...")
                    .font(AppFont.body(14))
                    .foregroundStyle(AppColors.lavender)
            }
        }
    }
}

extension View {
    func darkBackground() -> some View {
        modifier(DarkBackground())
    }

    func warmButtonStyle() -> some View {
        modifier(WarmButtonStyle())
    }

    func primaryAuthButton(isEnabled: Bool = true) -> some View {
        modifier(PrimaryAuthButton(isEnabled: isEnabled))
    }
}
