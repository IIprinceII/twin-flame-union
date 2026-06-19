//
//  OnboardingView.swift
//  Twin Flame Union
//
//  First-launch onboarding: name → partner → notifications → complete.
//  Saves directly to @AppStorage so ProfileView is pre-filled.
//

import SwiftUI
import UserNotifications

// MARK: - Onboarding Step

private enum OnboardingStep: Int, CaseIterable {
    case welcome
    case name
    case partner
    case notifications
    case complete
}

// MARK: - Root View

struct OnboardingView: View {
    var onComplete: () -> Void

    // Persisted keys (match ProfileView exactly)
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("userName")              private var userName              = ""
    @AppStorage("partnerName")           private var storedPartnerName     = ""
    @AppStorage("showPartnerChart")      private var showPartnerChart      = false

    // Transient state
    @State private var step             : OnboardingStep = .welcome
    @State private var nameInput        = ""
    @State private var partnerNameInput = ""
    @State private var includePartner   = false
    @State private var goingForward     = true

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            VStack(spacing: 0) {

                // Progress dots (hidden on welcome & complete)
                if step != .welcome && step != .complete {
                    progressDots
                        .padding(.top, 56)
                        .padding(.bottom, 8)
                        .accessibilityHidden(true)
                }

                // Step content with slide transition
                ZStack {
                    switch step {
                    case .welcome:
                        WelcomeStep(onNext: advance)
                            .transition(slideTransition)
                    case .name:
                        NameStep(nameInput: $nameInput, onNext: advance)
                            .transition(slideTransition)
                    case .partner:
                        PartnerStep(
                            partnerName: $partnerNameInput,
                            include: $includePartner,
                            onNext: advance,
                            onSkip: advance
                        )
                        .transition(slideTransition)
                    case .notifications:
                        NotificationsStep(onNext: advance, onSkip: advance)
                            .transition(slideTransition)
                    case .complete:
                        CompleteStep(
                            name: nameInput,
                            onFinish: finish
                        )
                        .transition(slideTransition)
                    }
                }
                .animation(.easeInOut(duration: 0.45), value: step)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Progress Dots

    private var progressDots: some View {
        let contentSteps: [OnboardingStep] = [.name, .partner, .notifications]
        return HStack(spacing: 8) {
            ForEach(contentSteps, id: \.rawValue) { s in
                Capsule()
                    .fill(s.rawValue <= step.rawValue
                          ? AppColors.gold
                          : AppColors.purple.opacity(0.3))
                    .frame(width: s == step ? 28 : 8, height: 8)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: step)
            }
        }
    }

    private var slideTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: goingForward ? .trailing : .leading).combined(with: .opacity),
            removal:   .move(edge: goingForward ? .leading  : .trailing).combined(with: .opacity)
        )
    }

    // MARK: - Navigation

    private func advance() {
        goingForward = true
        withAnimation(.easeInOut(duration: 0.45)) {
            switch step {
            case .welcome:       step = .name
            case .name:          step = .partner
            case .partner:       step = .notifications
            case .notifications: step = .complete
            case .complete:      finish()
            }
        }
    }

    // MARK: - Finish

    private func finish() {
        let trimmedName = nameInput.trimmingCharacters(in: .whitespaces)
        userName        = trimmedName.isEmpty ? "Beautiful Soul" : trimmedName

        let trimmedPartner = partnerNameInput.trimmingCharacters(in: .whitespaces)
        if includePartner && !trimmedPartner.isEmpty {
            storedPartnerName = trimmedPartner
        }
        showPartnerChart = !storedPartnerName.isEmpty

        hasCompletedOnboarding = true
        onComplete()
    }
}

// MARK: - Welcome Step

private struct WelcomeStep: View {
    let onNext: () -> Void
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Flame orb
            ZStack {
                Circle()
                    .fill(AppGradients.warm.opacity(0.15))
                    .frame(width: 180, height: 180)
                    .blur(radius: 30)
                    .scaleEffect(appeared ? (reduceMotion ? 1.0 : 1.1) : 0.8)
                    .animation(Animation.calm(reduceMotion, .easeInOut(duration: 2.5).repeatForever(autoreverses: true)), value: appeared)
                    .accessibilityHidden(true)

                Image(systemName: "flame.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(AppGradients.warm)
                    .scaleEffect(appeared ? 1.0 : 0.7)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: appeared)
                    .accessibilityHidden(true)
            }
            .padding(.bottom, 36)

            VStack(spacing: 14) {
                Text("Twin Flame Union")
                    .font(AppFont.serifHeadline(34))
                    .foregroundStyle(AppColors.cream)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.7).delay(0.4), value: appeared)

                Text("Your sacred journey begins here.\nLet us align your cosmic path.")
                    .font(AppFont.body(16))
                    .foregroundStyle(AppColors.lavender)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(.easeOut(duration: 0.7).delay(0.6), value: appeared)
            }
            .padding(.horizontal, 32)

            Spacer()

            Button {
                HapticManager.impact(.medium)
                onNext()
            } label: {
                Text("Begin Your Journey")
                    .warmButtonStyle()
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.easeOut(duration: 0.7).delay(0.9), value: appeared)
            .padding(.bottom, 60)
        }
        .onAppear { appeared = true }
    }
}

// MARK: - Name Step

private struct NameStep: View {
    @Binding var nameInput: String
    let onNext: () -> Void
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 36))
                        .foregroundStyle(AppColors.gold)
                        .accessibilityHidden(true)

                    Text("What is your name,\nbeautiful soul?")
                        .font(AppFont.serifHeadline(28))
                        .foregroundStyle(AppColors.cream)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                }

                // Name field
                VStack(spacing: 6) {
                    TextField("Your name", text: $nameInput)
                        .font(AppFont.body(20))
                        .foregroundStyle(AppColors.cream)
                        .multilineTextAlignment(.center)
                        .focused($focused)
                        .submitLabel(.done)
                        .onSubmit { if !nameInput.trimmingCharacters(in: .whitespaces).isEmpty { onNext() } }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(AppColors.purple.opacity(0.4), lineWidth: 1)
                        )
                        .padding(.horizontal, 32)

                    Text("This is how we'll greet you in the app")
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColors.lavender.opacity(0.7))
                }
            }

            Spacer()

            Button {
                HapticManager.impact(.medium)
                onNext()
            } label: {
                Text("Continue")
                    .warmButtonStyle()
            }
            .opacity(nameInput.trimmingCharacters(in: .whitespaces).isEmpty ? 0.45 : 1)
            .disabled(nameInput.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding(.bottom, 52)
        }
        .onAppear { focused = true }
    }
}

private struct OnboardingCard<Content: View>: View {
    let icon: String
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.gold)
                    .accessibilityHidden(true)
                Text(label)
                    .font(AppFont.body(13, weight: .semibold))
                    .foregroundStyle(AppColors.lavender)
            }
            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - Partner Step

private struct PartnerStep: View {
    @Binding var partnerName: String
    @Binding var include: Bool
    let onNext: () -> Void
    let onSkip: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                Spacer().frame(height: 12)

                VStack(spacing: 10) {
                    Text("💞")
                        .font(.system(size: 44))

                    Text("Do you have a twin flame\nor special someone?")
                        .font(AppFont.serifHeadline(26))
                        .foregroundStyle(AppColors.cream)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)

                    Text("Adding their info unlocks compatibility charts")
                        .font(AppFont.body(14))
                        .foregroundStyle(AppColors.lavender)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                // Toggle
                Button {
                    HapticManager.impact(.light)
                    withAnimation(.spring(response: 0.4)) { include.toggle() }
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(include ? AppColors.purple : AppColors.deepViolet)
                                .frame(width: 28, height: 28)
                                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(AppColors.purple.opacity(0.6), lineWidth: 1))
                            if include {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        Text("Yes, add their details")
                            .font(AppFont.body(16, weight: .semibold))
                            .foregroundStyle(AppColors.cream)
                        Spacer()
                    }
                    .padding(18)
                    .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(include ? AppColors.purple : AppColors.purple.opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(.plain)

                if include {
                    VStack(spacing: 16) {
                        // Partner name
                        OnboardingCard(icon: "person.fill", label: "Their Name") {
                            TextField("Their name", text: $partnerName)
                                .font(AppFont.body(16))
                                .foregroundStyle(AppColors.cream)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 14)
                                .background(AppColors.deepViolet.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1))
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                VStack(spacing: 12) {
                    Button {
                        HapticManager.impact(.medium)
                        onNext()
                    } label: {
                        Text(include ? "Continue" : "Add Later")
                            .warmButtonStyle()
                    }

                    if include {
                        Button(action: onSkip) {
                            Text("Skip for now")
                                .font(AppFont.body(15))
                                .foregroundStyle(AppColors.lavender.opacity(0.7))
                        }
                    }
                }
                .padding(.bottom, 52)
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Notifications Step

private struct NotificationsStep: View {
    let onNext: () -> Void
    let onSkip: () -> Void
    @State private var requested = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .fill(AppColors.purple.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)
                        .accessibilityHidden(true)
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(AppColors.gold)
                        .accessibilityHidden(true)
                }

                VStack(spacing: 12) {
                    Text("Stay on Your\nCosmic Path")
                        .font(AppFont.serifHeadline(28))
                        .foregroundStyle(AppColors.cream)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)

                    Text("Receive a daily affirmation each morning to keep your heart aligned with your highest path.")
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.lavender)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding(.horizontal, 24)
                }

                // Benefits
                VStack(alignment: .leading, spacing: 14) {
                    NotifBenefit(icon: "sun.horizon.fill",  color: AppColors.gold,    text: "Daily affirmation at your chosen time")
                    NotifBenefit(icon: "moon.stars.fill",   color: AppColors.lavender, text: "Moon phase & cosmic guidance updates")
                    NotifBenefit(icon: "heart.fill",        color: Color(hex: "FF6B9D"), text: "Gentle reminders to journal & reflect")
                }
                .padding(.horizontal, 32)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    HapticManager.impact(.medium)
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
                        DispatchQueue.main.async { onNext() }
                    }
                } label: {
                    Text("Enable Daily Guidance")
                        .warmButtonStyle()
                }

                Button(action: onSkip) {
                    Text("Maybe Later")
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.lavender.opacity(0.7))
                }
            }
            .padding(.bottom, 52)
        }
    }
}

private struct NotifBenefit: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
                .frame(width: 24)
            Text(text)
                .font(AppFont.body(14))
                .foregroundStyle(AppColors.cream)
            Spacer()
        }
    }
}

// MARK: - Complete Step

private struct CompleteStep: View {
    let name: String
    let onFinish: () -> Void

    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var displayName: String {
        name.trimmingCharacters(in: .whitespaces).isEmpty ? "Beautiful Soul" : name
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                // Glow
                ZStack {
                    Circle()
                        .fill(AppGradients.warm.opacity(0.2))
                        .frame(width: 160, height: 160)
                        .blur(radius: 28)
                        .scaleEffect(appeared ? (reduceMotion ? 1.0 : 1.15) : 0.85)
                        .animation(Animation.calm(reduceMotion, .easeInOut(duration: 2).repeatForever(autoreverses: true)), value: appeared)
                        .accessibilityHidden(true)
                    Text("✨")
                        .font(.system(size: 64))
                        .scaleEffect(appeared ? 1 : 0.5)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.7, dampingFraction: 0.55).delay(0.1), value: appeared)
                        .accessibilityHidden(true)
                }

                VStack(spacing: 12) {
                    Text("Welcome, \(displayName)")
                        .font(AppFont.serifHeadline(30))
                        .foregroundStyle(AppColors.cream)
                        .multilineTextAlignment(.center)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 18)
                        .animation(.easeOut(duration: 0.6).delay(0.35), value: appeared)

                    Text("Your soul profile is ready")
                        .font(AppFont.body(16))
                        .foregroundStyle(AppColors.gold)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 14)
                        .animation(.easeOut(duration: 0.6).delay(0.5), value: appeared)
                }

            }

            Spacer()

            Button {
                HapticManager.notification(.success)
                onFinish()
            } label: {
                Text("Enter the Portal")
                    .warmButtonStyle()
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.easeOut(duration: 0.6).delay(0.9), value: appeared)
            .padding(.bottom, 60)
        }
        .onAppear { appeared = true }
    }
}

