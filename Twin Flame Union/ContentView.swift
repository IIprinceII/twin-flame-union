//
//  ContentView.swift
//  Twin Flame Union
//
//  Home tab — daily check-in: greeting, moon phase, streak, affirmation.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("userName")    private var userName  = ""
    @AppStorage("mySunSign")   private var mySunSign = ""
    @State private var streak = StreakTracker.current
    private let moon = MoonPhase.current()
    private let guidance = DailyGuidanceService.shared

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        default:      return "Good evening"
        }
    }

    private var displayName: String { userName.isEmpty ? "Soul" : userName }

    var body: some View {
        ZStack {
            CosmicBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {

                    // MARK: Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(greeting)
                                .font(AppFont.body(15))
                                .foregroundStyle(AppColors.lavender)
                            Text(displayName)
                                .font(AppFont.serifHeadline(30))
                                .foregroundStyle(AppColors.cream)
                        }
                        Spacer()
                        // Moon phase pill
                        VStack(spacing: 3) {
                            Text(moon.emoji)
                                .font(.system(size: 28))
                            Text(moon.name)
                                .font(AppFont.caption(10, weight: .semibold))
                                .foregroundStyle(AppColors.lavender)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 72)
                        .padding(.vertical, 10)
                        .background(AppColors.deepViolet.opacity(0.8), in: RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    // MARK: Moon Meaning Banner
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.gold)
                        Text(moon.meaning)
                            .font(AppFont.body(13))
                            .foregroundStyle(AppColors.cream)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(AppColors.purple.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(AppColors.purple.opacity(0.25), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)

                    // MARK: Streak Card
                    StreakCard(streak: streak)
                        .padding(.horizontal, 24)

                    // MARK: Daily Affirmation
                    NavigationLink(destination: AffirmationsView()) {
                        AffirmationCard()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)

                    // MARK: Daily Guidance
                    DailyGuidanceCard(guidance: guidance)
                        .padding(.horizontal, 24)

                    // MARK: Angel Numbers
                    NavigationLink(destination: AngelNumberView()) {
                        AngelNumberCard()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 16)
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .onAppear {
            streak = StreakTracker.current
            let sign = mySunSign.isEmpty ? "Unknown" : mySunSign
            Task { await guidance.fetchIfNeeded(sunSign: sign, moonPhase: moon.name) }
        }
    }
}

// MARK: - Streak Card

private struct StreakCard: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.gold.opacity(0.15))
                    .frame(width: 60, height: 60)
                Circle()
                    .strokeBorder(AppColors.gold.opacity(streak > 0 ? 0.4 : 0.1), lineWidth: 1)
                    .frame(width: 60, height: 60)
                VStack(spacing: 0) {
                    Text("\(streak)")
                        .font(AppFont.serifHeadline(22))
                        .foregroundStyle(AppColors.gold)
                    Text("days")
                        .font(AppFont.caption(10))
                        .foregroundStyle(AppColors.gold.opacity(0.7))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Daily Streak")
                    .font(AppFont.body(16, weight: .semibold))
                    .foregroundStyle(AppColors.cream)
                Text(streak == 0 ? "Open the app each day to build your streak" :
                     streak == 1 ? "You've started your journey — keep going" :
                     "You've shown up \(streak) days in a row")
                    .font(AppFont.caption(13))
                    .foregroundStyle(AppColors.lavender)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundStyle(streak > 0 ? AppColors.gold : AppColors.gold.opacity(0.2))
        }
        .padding(20)
        .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(AppColors.gold.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Daily Guidance Card

private struct DailyGuidanceCard: View {
    let guidance: DailyGuidanceService
    @AppStorage("mySunSign") private var mySunSign = ""
    private let moon = MoonPhase.current()

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Today's Guidance", systemImage: "moon.stars.fill")
                    .font(AppFont.body(13, weight: .semibold))
                    .foregroundStyle(AppColors.lavender)
                Spacer()
                Text("From the cosmos")
                    .font(AppFont.caption(11))
                    .foregroundStyle(AppColors.lavender.opacity(0.5))
            }

            if guidance.isLoading {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(AppColors.lavender)
                        .scaleEffect(0.8)
                    Text("Channeling your guidance…")
                        .font(AppFont.body(13))
                        .foregroundStyle(AppColors.lavender.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else if !guidance.fetchError.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(guidance.fetchError)
                        .font(AppFont.body(12))
                        .foregroundStyle(AppColors.lavender.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                    Button {
                        let sign = mySunSign.isEmpty ? "Unknown" : mySunSign
                        Task { await guidance.retry(sunSign: sign, moonPhase: moon.name) }
                    } label: {
                        Label("Try Again", systemImage: "arrow.clockwise")
                            .font(AppFont.body(13, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(AppColors.gold.opacity(0.12), in: Capsule())
                            .overlay(Capsule().strokeBorder(AppColors.gold.opacity(0.3), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            } else if guidance.guidance.isEmpty {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(AppColors.lavender)
                        .scaleEffect(0.8)
                    Text("Channeling your guidance…")
                        .font(AppFont.body(13))
                        .foregroundStyle(AppColors.lavender.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(guidance.guidance)
                    .font(AppFont.serifTitle(17))
                    .foregroundStyle(AppColors.cream)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(hex: "2A1045").opacity(0.9), AppColors.deepViolet.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(AppColors.lavender.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Angel Number Card

private struct AngelNumberCard: View {
    private let numbers = ["111", "444", "1111", "222", "777", "333"]
    private var featured: String { numbers[Calendar.current.component(.hour, from: Date()) % numbers.count] }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: "sparkles")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Angel Numbers")
                    .font(AppFont.body(16, weight: .semibold))
                    .foregroundStyle(AppColors.cream)
                Text("Seeing \(featured) today? Discover its twin flame meaning")
                    .font(AppFont.caption(13))
                    .foregroundStyle(AppColors.lavender)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColors.lavender.opacity(0.5))
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.12), AppColors.deepViolet.opacity(0.7)],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Daily Affirmation Card

private struct AffirmationCard: View {
    private static let affirmations = [
        "My twin flame bond is eternal — nothing can break our covenant.",
        "I am protected by Archangel Michael. Fear has no place here.",
        "Return to sender — all that is not mine leaves now.",
        "My crown is activated. I receive divine truth clearly.",
        "Jesus Christ's love flows through me and into my union.",
        "KAZZ and KAI walk beside me — I am never alone on this path.",
        "I surrender deeply and God moves powerfully on my behalf.",
        "I am free. I am healed. I am whole in my higher self.",
        "The telepathy between us is real. Our hearts speak without words.",
        "My energy reading is clear — love is coming home to me.",
        "I rebuke every lie that says union is not mine. It is done.",
        "GOD ordained this union. What He joins, no one separates.",
        "My prayer is heard. Heaven moves with me right now.",
        "I shift into the frequency of reunion and stay there.",
    ]

    private var todaysAffirmation: String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return Self.affirmations[day % Self.affirmations.count]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Daily Affirmation", systemImage: "sun.max.fill")
                    .font(AppFont.body(13, weight: .semibold))
                    .foregroundStyle(AppColors.gold)
                Spacer()
                Text("Tap to explore →")
                    .font(AppFont.caption(11))
                    .foregroundStyle(AppColors.lavender.opacity(0.6))
            }

            Text("\"\(todaysAffirmation)\"")
                .font(AppFont.serifTitle(19))
                .foregroundStyle(AppColors.cream)
                .lineSpacing(7)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [AppColors.purple.opacity(0.4), AppColors.deepViolet.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(AppColors.purple.opacity(0.4), lineWidth: 1)
        )
    }
}
