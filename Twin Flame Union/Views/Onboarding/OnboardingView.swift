//
//  OnboardingView.swift
//  Twin Flame Union
//
//  First-launch onboarding: name → birthday + time + city → partner → notifications → complete.
//  Saves directly to @AppStorage so ProfileView is pre-filled.
//

import SwiftUI
import UserNotifications

// MARK: - Onboarding Step

private enum OnboardingStep: Int, CaseIterable {
    case welcome
    case name
    case birthday
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
    @AppStorage("userBirthDateTS")       private var userBirthDateTS       = 0.0
    @AppStorage("userBirthCity")         private var userBirthCity         = ""
    @AppStorage("mySunSign")             private var mySunSign             = ""
    @AppStorage("myMoonSign")            private var myMoonSign            = ""
    @AppStorage("myRisingSign")          private var myRisingSign          = ""
    @AppStorage("partnerName")           private var storedPartnerName     = ""
    @AppStorage("partnerSunSign")        private var partnerSunSign        = ""
    @AppStorage("showPartnerChart")      private var showPartnerChart      = false

    // Transient state
    @State private var step             : OnboardingStep = .welcome
    @State private var nameInput        = ""
    @State private var birthDate        = OnboardingView.defaultBirthDate
    @State private var birthTime        = OnboardingView.defaultBirthTime
    @State private var birthCity        = ""
    @State private var partnerNameInput = ""
    @State private var partnerDate      = Date()
    @State private var includePartner   = false
    @State private var goingForward     = true

    static private var defaultBirthDate: Date {
        Calendar.current.date(from: DateComponents(year: 1995, month: 6, day: 21)) ?? Date()
    }
    static private var defaultBirthTime: Date {
        Calendar.current.date(from: DateComponents(hour: 12, minute: 0)) ?? Date()
    }

    var body: some View {
        ZStack {
            CosmicBackground()

            VStack(spacing: 0) {

                // Progress dots (hidden on welcome & complete)
                if step != .welcome && step != .complete {
                    progressDots
                        .padding(.top, 56)
                        .padding(.bottom, 8)
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
                    case .birthday:
                        BirthdayStep(
                            birthDate: $birthDate,
                            birthTime: $birthTime,
                            birthCity: $birthCity,
                            onNext: advance
                        )
                        .transition(slideTransition)
                    case .partner:
                        PartnerStep(
                            partnerName: $partnerNameInput,
                            partnerDate: $partnerDate,
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
                            sunSign:    BirthCalculator.sunSign(for: birthDate),
                            moonSign:   BirthCalculator.moonSign(for: birthDate),
                            risingSign: BirthCalculator.risingSign(for: birthTime),
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
        let contentSteps: [OnboardingStep] = [.name, .birthday, .partner, .notifications]
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
            case .name:          step = .birthday
            case .birthday:      step = .partner
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
        userBirthDateTS = birthDate.timeIntervalSince1970
        userBirthCity   = birthCity

        mySunSign    = BirthCalculator.sunSign(for: birthDate)
        myMoonSign   = BirthCalculator.moonSign(for: birthDate)
        myRisingSign = BirthCalculator.risingSign(for: birthTime)

        let trimmedPartner = partnerNameInput.trimmingCharacters(in: .whitespaces)
        if includePartner && !trimmedPartner.isEmpty {
            storedPartnerName = trimmedPartner
            partnerSunSign    = BirthCalculator.sunSign(for: partnerDate)
            showPartnerChart  = true
        }

        hasCompletedOnboarding = true
        onComplete()
    }
}

// MARK: - Birth Calculator

enum BirthCalculator {

    // Sun sign from birth month/day
    static func sunSign(for date: Date) -> String {
        let cal   = Calendar.current
        let month = cal.component(.month, from: date)
        let day   = cal.component(.day,   from: date)
        switch (month, day) {
        case (3, 21...), (4, 1..<20):  return "Aries"
        case (4, 20...), (5, 1..<21):  return "Taurus"
        case (5, 21...), (6, 1..<21):  return "Gemini"
        case (6, 21...), (7, 1..<23):  return "Cancer"
        case (7, 23...), (8, 1..<23):  return "Leo"
        case (8, 23...), (9, 1..<23):  return "Virgo"
        case (9, 23...), (10, 1..<23): return "Libra"
        case (10, 23...), (11, 1..<22): return "Scorpio"
        case (11, 22...), (12, 1..<22): return "Sagittarius"
        case (12, 22...), (1, 1..<20): return "Capricorn"
        case (1, 20...), (2, 1..<19):  return "Aquarius"
        default:                        return "Pisces"
        }
    }

    // Approximate moon sign from birth date
    // Reference: Jan 1 2000 00:00 UTC → Moon at ~218.3° (Scorpio ~8°)
    static func moonSign(for date: Date) -> String {
        let signs = ["Aries","Taurus","Gemini","Cancer","Leo","Virgo",
                     "Libra","Scorpio","Sagittarius","Capricorn","Aquarius","Pisces"]
        var comps = DateComponents()
        comps.year = 2000; comps.month = 1; comps.day = 1
        comps.timeZone = TimeZone(identifier: "UTC")
        let ref   = Calendar(identifier: .gregorian).date(from: comps) ?? Date()
        let days  = date.timeIntervalSince(ref) / 86400.0
        var lon   = (218.3 + days * 13.176).truncatingRemainder(dividingBy: 360)
        if lon < 0 { lon += 360 }
        return signs[Int(lon / 30) % 12]
    }

    // Approximate rising sign from birth time (2-hour windows)
    // Assumes ~40°N latitude; the ascendant shifts ~1 sign per 2 hours
    static func risingSign(for time: Date) -> String {
        let signs = ["Aries","Taurus","Gemini","Cancer","Leo","Virgo",
                     "Libra","Scorpio","Sagittarius","Capricorn","Aquarius","Pisces"]
        let cal   = Calendar.current
        let hour  = cal.component(.hour,   from: time)
        let min   = cal.component(.minute, from: time)
        let totalHours = Double(hour) + Double(min) / 60.0
        // Aries rises ~at 6 AM as a rough anchor
        let index = Int((totalHours - 6 + 24).truncatingRemainder(dividingBy: 24) / 2) % 12
        return signs[index]
    }
}

// MARK: - Welcome Step

private struct WelcomeStep: View {
    let onNext: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Flame orb
            ZStack {
                Circle()
                    .fill(AppGradients.warm.opacity(0.15))
                    .frame(width: 180, height: 180)
                    .blur(radius: 30)
                    .scaleEffect(appeared ? 1.1 : 0.8)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: appeared)

                Image(systemName: "flame.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(AppGradients.warm)
                    .scaleEffect(appeared ? 1.0 : 0.7)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: appeared)
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

            Button(action: onNext) {
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

            Button(action: onNext) {
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

// MARK: - Birthday Step

private struct BirthdayStep: View {
    @Binding var birthDate: Date
    @Binding var birthTime: Date
    @Binding var birthCity: String
    let onNext: () -> Void

    private let birthDateRange: ClosedRange<Date> = {
        let start = Calendar.current.date(from: DateComponents(year: 1920, month: 1, day: 1))!
        let end   = Calendar.current.date(from: DateComponents(year: 2010, month: 12, day: 31))!
        return start...end
    }()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                Spacer().frame(height: 12)

                VStack(spacing: 10) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(AppColors.gold)

                    Text("Your Cosmic Birth Data")
                        .font(AppFont.serifHeadline(26))
                        .foregroundStyle(AppColors.cream)

                    Text("Used to calculate your sun, moon & rising signs")
                        .font(AppFont.body(14))
                        .foregroundStyle(AppColors.lavender)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                }

                // Date picker
                OnboardingCard(icon: "calendar", label: "Birthday") {
                    DatePicker(
                        "",
                        selection: $birthDate,
                        in: birthDateRange,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .colorScheme(.dark)
                }

                // Time picker
                OnboardingCard(icon: "clock.fill", label: "Time of Birth") {
                    VStack(spacing: 6) {
                        DatePicker(
                            "",
                            selection: $birthTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                        .colorScheme(.dark)

                        Text("As accurate as possible — used for your rising sign")
                            .font(AppFont.caption(11))
                            .foregroundStyle(AppColors.lavender.opacity(0.7))
                    }
                }

                // City field
                OnboardingCard(icon: "location.fill", label: "Birth City (optional)") {
                    TextField("e.g. Los Angeles, London, Tokyo", text: $birthCity)
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.cream)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(AppColors.deepViolet.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1))
                }

                // Calculated signs preview
                SignPreviewRow(birthDate: birthDate, birthTime: birthTime)

                Button(action: onNext) {
                    Text("Continue")
                        .warmButtonStyle()
                }
                .padding(.bottom, 52)
            }
            .padding(.horizontal, 24)
        }
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

private struct SignPreviewRow: View {
    let birthDate: Date
    let birthTime: Date

    var body: some View {
        HStack(spacing: 0) {
            SignPill(label: "Sun",    sign: BirthCalculator.sunSign(for: birthDate),    icon: "sun.max.fill",    color: AppColors.gold)
            Spacer()
            SignPill(label: "Moon",   sign: BirthCalculator.moonSign(for: birthDate),   icon: "moon.fill",       color: AppColors.lavender)
            Spacer()
            SignPill(label: "Rising", sign: BirthCalculator.risingSign(for: birthTime), icon: "arrow.up.circle.fill", color: Color(hex: "4CAF82"))
        }
        .padding(16)
        .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(AppColors.gold.opacity(0.2), lineWidth: 1))
    }
}

private struct SignPill: View {
    let label: String
    let sign: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
            Text(sign)
                .font(AppFont.body(13, weight: .semibold))
                .foregroundStyle(AppColors.cream)
            Text(label)
                .font(AppFont.caption(11))
                .foregroundStyle(AppColors.lavender.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Partner Step

private struct PartnerStep: View {
    @Binding var partnerName: String
    @Binding var partnerDate: Date
    @Binding var include: Bool
    let onNext: () -> Void
    let onSkip: () -> Void

    private let dateRange: ClosedRange<Date> = {
        let s = Calendar.current.date(from: DateComponents(year: 1920, month: 1, day: 1))!
        let e = Calendar.current.date(from: DateComponents(year: 2010, month: 12, day: 31))!
        return s...e
    }()

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

                        // Partner birthday
                        OnboardingCard(icon: "calendar", label: "Their Birthday") {
                            DatePicker("", selection: $partnerDate, in: dateRange, displayedComponents: .date)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .frame(maxWidth: .infinity)
                                .colorScheme(.dark)
                        }

                        // Partner sun sign preview
                        HStack {
                            Image(systemName: "sun.max.fill")
                                .foregroundStyle(AppColors.gold)
                            Text("Their Sun Sign: \(BirthCalculator.sunSign(for: partnerDate))")
                                .font(AppFont.body(14, weight: .semibold))
                                .foregroundStyle(AppColors.cream)
                        }
                        .padding(.horizontal, 4)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                VStack(spacing: 12) {
                    Button(action: onNext) {
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
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(AppColors.gold)
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
    let sunSign: String
    let moonSign: String
    let risingSign: String
    let onFinish: () -> Void

    @State private var appeared = false

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
                        .scaleEffect(appeared ? 1.15 : 0.85)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: appeared)
                    Text("✨")
                        .font(.system(size: 64))
                        .scaleEffect(appeared ? 1 : 0.5)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.7, dampingFraction: 0.55).delay(0.1), value: appeared)
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

                // Chart card
                VStack(spacing: 16) {
                    Text("YOUR BIRTH CHART")
                        .font(AppFont.caption(11, weight: .semibold))
                        .foregroundStyle(AppColors.lavender.opacity(0.7))
                        .kerning(2)

                    HStack(spacing: 0) {
                        CompletionSign(label: "Sun ☉",    sign: sunSign,    color: AppColors.gold)
                        Divider().frame(height: 44).background(AppColors.purple.opacity(0.3))
                        CompletionSign(label: "Moon ☽",   sign: moonSign,   color: AppColors.lavender)
                        Divider().frame(height: 44).background(AppColors.purple.opacity(0.3))
                        CompletionSign(label: "Rising ↑", sign: risingSign, color: Color(hex: "4CAF82"))
                    }
                }
                .padding(24)
                .background(AppColors.deepViolet.opacity(0.8), in: RoundedRectangle(cornerRadius: 22))
                .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(AppColors.gold.opacity(0.25), lineWidth: 1))
                .padding(.horizontal, 24)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.9)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.65), value: appeared)
            }

            Spacer()

            Button(action: onFinish) {
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

private struct CompletionSign: View {
    let label: String
    let sign: String
    let color: Color

    var body: some View {
        VStack(spacing: 5) {
            Text(label)
                .font(AppFont.caption(11))
                .foregroundStyle(AppColors.lavender.opacity(0.7))
            Text(sign)
                .font(AppFont.body(14, weight: .semibold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }
}
