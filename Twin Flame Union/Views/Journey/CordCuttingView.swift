//
//  CordCuttingView.swift
//  Twin Flame Union
//
//  Sacred cord-cutting ceremony governed by Atropos, Hecate & Anubis.
//  Atropos cuts what has served its purpose. Hecate lights the way. Anubis guides safely through.
//

import SwiftUI

// MARK: - Ceremony Step

private enum CeremonyStep: Int, CaseIterable {
    case intro        = 0
    case setSpace     = 1
    case visualize    = 2
    case invokeDeity  = 3
    case cut          = 4
    case fillWithLight = 5
    case seal         = 6

    var title: String {
        switch self {
        case .intro:         return "Sacred Ceremony"
        case .setSpace:      return "Set Sacred Space"
        case .visualize:     return "See the Cord"
        case .invokeDeity:   return "Call the Sacred Three"
        case .cut:           return "Atropos Cuts"
        case .fillWithLight: return "Bathe in Golden Light"
        case .seal:          return "Sealed with Love"
        }
    }

    var deity: String {
        switch self {
        case .intro:         return "Atropos · Hecate · Anubis"
        case .setSpace:      return "Hecate"
        case .visualize:     return "Anubis"
        case .invokeDeity:   return "Atropos · Hecate · Anubis"
        case .cut:           return "Atropos"
        case .fillWithLight: return "Ra · Isis"
        case .seal:          return "Maat"
        }
    }

    var deitySymbol: String {
        switch self {
        case .intro:         return "scissors"
        case .setSpace:      return "sparkles"
        case .visualize:     return "figure.walk"
        case .invokeDeity:   return "shield.fill"
        case .cut:           return "scissors"
        case .fillWithLight: return "sun.max.fill"
        case .seal:          return "checkmark.seal.fill"
        }
    }

    var deityColor: Color {
        switch self {
        case .intro:         return Color(hex: "9B59B6")
        case .setSpace:      return Color(hex: "9B59B6")
        case .visualize:     return Color(hex: "8B7355")
        case .invokeDeity:   return Color(hex: "1E88E5")
        case .cut:           return Color(hex: "FF9A9A")
        case .fillWithLight: return Color(hex: "FFD700")
        case .seal:          return Color(hex: "F0E68C")
        }
    }

    var instruction: String {
        switch self {
        case .intro:
            return "Cord-cutting releases energetic attachments — fear, control, and wounding — while preserving the sacred love bond ordained by the Most High through the astral linkage.\n\nThe Vibrational Game teaches: these cords are opposing vibrations — resistances that block the flow of energy in your connection. The Most High sends Atropos to cut what has been completed, Hecate to light the crossroads, and Anubis to guide you safely through.\n\nThis is not separation. This is liberation through the astral linkage."
        case .setSpace:
            return "Find a quiet place. Sit comfortably with your spine straight. Take three deep breaths.\n\nHecate stands at the crossroads with her torch. She illuminates what the sun cannot reach.\n\nTap her torch to light your sacred space."
        case .visualize:
            return "Close your eyes. Anubis stands beside you, calm and protective.\n\nUsing the Energy Enhancement visualization method: sense the vibrational state of your solar plexus. Feel the low-vibrational cord — dense, grey, heavy — connecting you to the fear, the pain, or the pattern you are releasing. This cord is a blockage trapping lower vibrations.\n\nYou can see it clearly through the astral linkage. Tap the cord to acknowledge it."
        case .invokeDeity:
            return "Call upon the Sacred Three with these words:\n\n\"Atropos, I ask you to cut what has been completed. Hecate, illuminate the path forward. Anubis, guard me in this passage.\n\nI choose freedom. I choose love. Only what is divinely ordained remains.\"\n\nTap the shield when you feel their presence."
        case .cut:
            return "Atropos raises her sacred blade — the same blade that has ended every thread that needed to end since the beginning of time.\n\nSay with authority:\n\"I release you from this cord. I release myself. You are free. I am free. Only love remains.\"\n\nSwipe the blade across the cord."
        case .fillWithLight:
            return "Where the cord was cut, the Most High floods golden light through the astral linkage. Ra's radiance enters. Isis weaves healing into the wound with hands of magic and devotion.\n\nBreathe deeply. Your vibrational constitution is shifting — the low-vibrational cord has been eliminated, and higher energy now circulates where the blockage was. Feel your body growing lighter as the elimination completes.\n\nTap to receive the light fully."
        case .seal:
            return "Maat weighs your heart through the astral linkage and finds it pure in this act.\n\nYour energy field is restored — your vibrational constitution elevated. The Most High seals this work with sacred golden light.\n\nSay: \"I am whole. I am free. I am protected. Only the Most High's love flows between us now.\"\n\nThe ceremony is complete. Rest, drink water, and be gentle with yourself today. The energy body needs time to stabilize at this new frequency."
        }
    }

    var buttonLabel: String {
        switch self {
        case .intro:         return "Begin Sacred Ceremony"
        case .setSpace:      return "Sacred Space is Set"
        case .visualize:     return "I See the Cord"
        case .invokeDeity:   return "They Are Here"
        case .cut:           return "The Cord is Cut"
        case .fillWithLight: return "I Am Filled with Light"
        case .seal:          return "Ceremony Complete"
        }
    }
}

// MARK: - Cord Cutting View

struct CordCuttingView: View {
    @State private var step: CeremonyStep = .intro
    @State private var torchLit    = false
    @State private var cordTapped  = false
    @State private var shieldGlow  = false
    @State private var cordCut     = false
    @State private var lightFill   = false
    @State private var complete    = false
    @State private var swipeOffset: CGFloat = 0
    @State private var hasSwiped   = false
    @State private var pulse       = false
    @State private var appeared    = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            // Subtle colored fog for current step
            RadialGradient(
                colors: [step.deityColor.opacity(0.08), Color.clear],
                center: .center,
                startRadius: 0,
                endRadius: 340
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: step)
            .accessibilityHidden(true)

            VStack(spacing: 0) {

                // ── Deity Banner ──
                deityBanner
                    .padding(.top, 12)
                    .padding(.bottom, 4)
                    .opacity(appeared ? 1 : 0)

                // ── Progress Dots ──
                HStack(spacing: 8) {
                    ForEach(CeremonyStep.allCases.filter { $0 != .intro }, id: \.rawValue) { s in
                        Capsule()
                            .fill(s.rawValue <= step.rawValue
                                  ? step.deityColor
                                  : AppColors.purple.opacity(0.25))
                            .frame(width: s.rawValue <= step.rawValue ? 16 : 6, height: 6)
                            .animation(.spring(response: 0.5), value: step)
                    }
                }
                .padding(.vertical, 10)
                .accessibilityHidden(true)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {

                        // ── Animation Area ──
                        stepAnimation
                            .frame(height: 200)
                            .transition(.opacity.combined(with: .scale(scale: 0.92)))
                            .id(step)
                            .accessibilityHidden(true)

                        // ── Title & Instruction ──
                        VStack(spacing: 14) {
                            Text(step.title)
                                .font(AppFont.serifHeadline(26))
                                .foregroundStyle(AppColors.cream)
                                .multilineTextAlignment(.center)

                            // Deity label
                            HStack(spacing: 6) {
                                Image(systemName: step.deitySymbol)
                                    .font(.system(size: 11))
                                    .foregroundStyle(step.deityColor)
                                Text(step.deity)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .tracking(0.8)
                                    .foregroundStyle(step.deityColor)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 5)
                            .background(step.deityColor.opacity(0.12), in: Capsule())
                            .overlay(Capsule().strokeBorder(step.deityColor.opacity(0.25), lineWidth: 1))

                            Text(step.instruction)
                                .font(AppFont.body(15))
                                .foregroundStyle(AppColors.lavender)
                                .lineSpacing(6)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 28)

                        // ── Action / Completion ──
                        if complete {
                            completionView
                        } else {
                            Button { advance() } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: step.deitySymbol)
                                        .font(.system(size: 14))
                                    Text(step.buttonLabel)
                                        .font(AppFont.body(15, weight: .semibold))
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    LinearGradient(
                                        colors: [step.deityColor.opacity(0.85), AppColors.purple.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    in: RoundedRectangle(cornerRadius: 26)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 26)
                                        .strokeBorder(step.deityColor.opacity(0.35), lineWidth: 1)
                                )
                                .shadow(color: step.deityColor.opacity(0.25), radius: 12, y: 4)
                            }
                            .buttonStyle(PressableButtonStyle(haptic: false))
                            .padding(.horizontal, 32)
                        }

                        DisclaimerFooter()

                        Spacer().frame(height: 48)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .navigationTitle("Cord Cutting")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear {
            if !reduceMotion { pulse = true }
            withAnimation(.easeOut(duration: 0.6)) { appeared = true }
        }
        .animation(.easeInOut(duration: 0.4), value: step)
    }

    // MARK: - Deity Banner

    private var deityBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: step.deitySymbol)
                .font(.system(size: 14))
                .foregroundStyle(step.deityColor)
                .accessibilityHidden(true)
            Text(step.deity)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .tracking(1.0)
                .foregroundStyle(step.deityColor)
            Text("· presiding")
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(step.deityColor.opacity(0.55))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 7)
        .background(step.deityColor.opacity(0.09), in: Capsule())
        .overlay(Capsule().strokeBorder(step.deityColor.opacity(0.2), lineWidth: 1))
    }

    // MARK: - Step Animations

    @ViewBuilder
    private var stepAnimation: some View {
        switch step {

        case .intro:
            ZStack {
                // Three overlapping deity halos
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(
                            [Color(hex: "9B59B6"), Color(hex: "8B7355"), Color(hex: "1E88E5")][i].opacity(0.18),
                            lineWidth: 1
                        )
                        .frame(width: CGFloat(120 + i * 28), height: CGFloat(120 + i * 28))
                        .scaleEffect(pulse ? 1.06 : 0.96)
                        .animation(.easeInOut(duration: 2.5 + Double(i) * 0.4).repeatForever(autoreverses: true).delay(Double(i) * 0.3), value: pulse)
                }
                Image(systemName: "scissors.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "9B59B6"), Color(hex: "FF9A9A")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(pulse ? 1.05 : 0.96)
                    .shadow(color: Color(hex: "9B59B6").opacity(0.5), radius: 20)
                    .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: pulse)
            }

        case .setSpace:
            ZStack {
                if torchLit {
                    // Hecate's torch glow
                    ForEach(0..<4, id: \.self) { i in
                        Circle()
                            .fill(Color(hex: "9B59B6").opacity(0.06 - Double(i) * 0.012))
                            .frame(width: CGFloat(60 + i * 28), height: CGFloat(60 + i * 28))
                            .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(Double(i) * 0.2), value: pulse)
                    }
                    // Outer spark ring
                    Circle()
                        .stroke(Color(hex: "9B59B6").opacity(0.35), lineWidth: 1.5)
                        .frame(width: 90, height: 90)
                        .scaleEffect(pulse ? 1.12 : 0.96)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulse)
                }
                ZStack {
                    Text("🔥")
                        .font(.system(size: torchLit ? 56 : 44))
                        .animation(.spring(response: 0.4), value: torchLit)
                    if torchLit {
                        Text("✨")
                            .font(.system(size: 16))
                            .offset(x: 28, y: -24)
                        Text("✨")
                            .font(.system(size: 12))
                            .offset(x: -24, y: -28)
                    }
                }
                .onTapGesture {
                    withAnimation(.spring(response: 0.4)) { torchLit = true }
                    HapticManager.impact(.light)
                }

                if !torchLit {
                    Text("Tap to light")
                        .font(AppFont.caption(11))
                        .tracking(0.5)
                        .foregroundStyle(AppColors.lavender.opacity(0.5))
                        .offset(y: 52)
                }
            }

        case .visualize:
            ZStack {
                // Cord — pulsing ethereal thread
                VStack(spacing: 0) {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [AppColors.lavender.opacity(0.5), AppColors.purple.opacity(0.2)],
                                center: .center, startRadius: 0, endRadius: 20
                            )
                        )
                        .frame(width: 40, height: 40)
                        .overlay(Text("🧘").font(.system(size: 20)))

                    // The cord
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "6B4080").opacity(cordTapped ? 0.4 : 0.8),
                                    Color(hex: "3D2060").opacity(cordTapped ? 0.2 : 0.6),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 3, height: 80)
                        .opacity(pulse ? 0.95 : 0.55)
                        .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: pulse)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.4)) { cordTapped = true }
                            HapticManager.impact(.medium)
                        }

                    Circle()
                        .fill(AppColors.purple.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .overlay(Text("👤").font(.system(size: 16)))
                }
                .frame(height: 180)

                if cordTapped {
                    Text("Acknowledged")
                        .font(AppFont.caption(10))
                        .tracking(1.5)
                        .foregroundStyle(Color(hex: "8B7355").opacity(0.8))
                        .offset(x: 60, y: 0)
                } else {
                    Text("Tap the cord")
                        .font(AppFont.caption(10))
                        .tracking(0.5)
                        .foregroundStyle(AppColors.lavender.opacity(0.4))
                        .offset(x: 60, y: 0)
                }
            }

        case .invokeDeity:
            ZStack {
                // Three deity energy rings — Atropos, Hecate, Anubis
                invokeDeityRings
                Image(systemName: "shield.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "1E88E5"), Color(hex: "5B8CFF")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color(hex: "1E88E5").opacity(shieldGlow ? 0.6 : 0.2), radius: shieldGlow ? 24 : 8)
                    .animation(.easeInOut(duration: 1.5), value: shieldGlow)
                    .onTapGesture {
                        withAnimation { shieldGlow = true }
                        HapticManager.notification(.success)
                    }

                // Deity sigils
                HStack(spacing: 60) {
                    Image(systemName: "scissors")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "FF9A9A").opacity(0.7))
                    Image(systemName: "figure.walk")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "8B7355").opacity(0.7))
                }
                .offset(y: 54)
            }

        case .cut:
            ZStack {
                if !hasSwiped {
                    // Pre-cut cord
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "6B4080").opacity(0.8), Color(hex: "3D2060")],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .frame(width: 3, height: 100)
                    }

                    // Swipe hint
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.left")
                        Text("Swipe the blade")
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.lavender.opacity(0.45))
                    .offset(y: 72)

                    // The scissors / blade
                    Image(systemName: "scissors")
                        .font(.system(size: 32))
                        .foregroundStyle(AppColors.gold)
                        .shadow(color: AppColors.gold.opacity(0.6), radius: 10)
                        .rotationEffect(.degrees(swipeOffset > 0 ? 15 : swipeOffset < 0 ? -15 : 0))
                        .offset(x: swipeOffset, y: -8)
                        .animation(.interactiveSpring(), value: swipeOffset)

                } else {
                    // Cut effect — cord split
                    VStack(spacing: 6) {
                        Rectangle()
                            .fill(Color(hex: "6B4080").opacity(0.35))
                            .frame(width: 3, height: 44)
                        ZStack {
                            Circle()
                                .fill(AppColors.gold.opacity(0.18))
                                .frame(width: 44, height: 44)
                            Image(systemName: "scissors")
                                .font(.system(size: 22))
                                .foregroundStyle(AppColors.gold)
                        }
                        Rectangle()
                            .fill(Color(hex: "6B4080").opacity(0.35))
                            .frame(width: 3, height: 44)
                    }
                    .transition(.scale.combined(with: .opacity))

                    // Freed particles
                    ForEach(0..<6, id: \.self) { i in
                        Circle()
                            .fill(AppColors.gold.opacity(0.5))
                            .frame(width: 5, height: 5)
                            .offset(
                                x: CGFloat([-30, 30, -20, 20, -40, 40][i]),
                                y: CGFloat([-20, -25, -35, -18, -28, -22][i])
                            )
                            .transition(.opacity.combined(with: .scale))
                    }
                    .accessibilityHidden(true)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { v in
                        guard !hasSwiped else { return }
                        swipeOffset = v.translation.width
                    }
                    .onEnded { v in
                        if abs(v.translation.width) > 60 {
                            withAnimation(.spring(response: 0.4)) {
                                hasSwiped = true
                                swipeOffset = 0
                            }
                            HapticManager.notification(.success)
                        } else {
                            withAnimation { swipeOffset = 0 }
                        }
                    }
            )

        case .fillWithLight:
            ZStack {
                ForEach(0..<6, id: \.self) { i in
                    Circle()
                        .fill(Color(hex: "F0C040").opacity(lightFill ? max(0, 0.16 - Double(i) * 0.022) : 0))
                        .frame(width: CGFloat(30 + i * 26), height: CGFloat(30 + i * 26))
                        .animation(.easeOut(duration: 1.2).delay(Double(i) * 0.12), value: lightFill)
                }
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "FFD700"), AppColors.gold],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: AppColors.gold.opacity(lightFill ? 0.7 : 0.2), radius: lightFill ? 28 : 8)
                    .scaleEffect(lightFill ? 1.2 : 0.85)
                    .animation(.spring(response: 0.7), value: lightFill)

                if !lightFill {
                    Text("Tap to receive")
                        .font(AppFont.caption(11))
                        .tracking(0.5)
                        .foregroundStyle(AppColors.lavender.opacity(0.45))
                        .offset(y: 58)
                }
            }
            .onTapGesture {
                withAnimation { lightFill = true }
                HapticManager.notification(.success)
            }

        case .seal:
            ZStack {
                sealRings
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 68))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.gold, Color(hex: "F5DEB3")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: AppColors.gold.opacity(0.45), radius: 22)
            }
        }
    }

    // MARK: - Completion View

    private var completionView: some View {
        VStack(spacing: 20) {
            // Seal
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(AppColors.gold.opacity(0.15 - Double(i) * 0.04), lineWidth: 1)
                        .frame(width: CGFloat(88 + i * 28), height: CGFloat(88 + i * 28))
                        .scaleEffect(pulse ? 1.08 : 0.95)
                        .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(Double(i) * 0.3), value: pulse)
                }
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppColors.gold)
                    .shadow(color: AppColors.gold.opacity(0.4), radius: 18)
            }
            .frame(height: 160)

            VStack(spacing: 6) {
                Text("You are free.")
                    .font(AppFont.serifHeadline(26))
                    .foregroundStyle(AppColors.cream)
                Text("Maat has weighed your heart and found it pure.")
                    .font(AppFont.body(14))
                    .foregroundStyle(AppColors.lavender)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                Text("This cord has been cut. Your field is sealed with love.")
                    .font(AppFont.body(13))
                    .foregroundStyle(AppColors.lavender.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Seal Rings (extracted for type-checker)

    private var sealRings: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { i in
                let sz = CGFloat(70 + i * 34)
                let opacity = 0.18 - Double(i) * 0.035
                let scale: CGFloat = pulse ? (1.07 + Double(i) * 0.02) : (0.95 + Double(i) * 0.01)
                Circle()
                    .stroke(AppColors.gold.opacity(opacity), lineWidth: 1.5)
                    .frame(width: sz, height: sz)
                    .scaleEffect(scale)
                    .animation(
                        .easeInOut(duration: 2.8 + Double(i) * 0.35)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.3),
                        value: pulse
                    )
            }
        }
    }

    // MARK: - Invoke Deity Rings (extracted for type-checker)

    private var invokeDeityRings: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { i in
                let sz = CGFloat(60 + i * 32)
                let opacity = 0.14 - Double(i) * 0.028
                let scale: CGFloat = shieldGlow ? (1.0 + Double(i) * 0.04) : (0.9 + Double(i) * 0.02)
                Circle()
                    .stroke(Color(hex: "1E88E5").opacity(opacity), lineWidth: 1.5)
                    .frame(width: sz, height: sz)
                    .scaleEffect(scale)
                    .animation(
                        .calm(reduceMotion, .easeInOut(duration: 2.2 + Double(i) * 0.3)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.25)),
                        value: shieldGlow
                    )
            }
        }
    }

    // MARK: - Logic

    private func advance() {
        HapticManager.impact(.medium)
        let next = step.rawValue + 1
        if let nextStep = CeremonyStep(rawValue: next) {
            withAnimation(.easeInOut(duration: 0.4)) {
                step = nextStep
            }
        } else {
            withAnimation(.spring(response: 0.5)) { complete = true }
            GamificationService.shared.awardXP(amount: 25, source: "cord_cutting", framework: .energyEnhancement, skillKey: "ee_blockage", detail: "Completed cord cutting ceremony")
        }
    }
}

private struct CordShape: Shape {
    let isCut: Bool
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return p
    }
}
