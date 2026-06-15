//
//  DailyDevotionView.swift
//  Twin Flame Union
//
//  Daily spiritual checklist with progress ring — inspired by Aphrodite's ritual view.
//

import SwiftUI

struct DailyDevotionView: View {
    @State private var steps: [DevotionStep] = DevotionStep.todaySteps()
    @State private var showCompletion = false

    private var completedCount: Int { steps.filter(\.isCompleted).count }
    private var progress: Double {
        guard !steps.isEmpty else { return 0 }
        return Double(completedCount) / Double(steps.count)
    }
    private var allCompleted: Bool { !steps.isEmpty && completedCount == steps.count }

    private var progressMessage: String {
        switch progress {
        case 0:          return "Begin your sacred practice"
        case 0.01..<0.5: return "Beautiful start, keep going"
        case 0.5..<1.0:  return "You're radiating divine light"
        case 1.0:        return "Devotion complete"
        default:         return ""
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 9))
                        .foregroundStyle(AppColors.gold)
                    Text("DAILY DEVOTION")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .tracking(2.2)
                        .foregroundStyle(AppColors.gold.opacity(0.9))
                }
                Spacer()

                // Mini progress ring
                ZStack {
                    Circle()
                        .stroke(AppColors.purple.opacity(0.2), lineWidth: 3)
                        .frame(width: 32, height: 32)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(AppColors.gold, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 32, height: 32)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring, value: progress)

                    Text("\(completedCount)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.gold)
                }
            }

            // Progress message
            Text(progressMessage)
                .font(AppFont.caption(12))
                .foregroundStyle(AppColors.lavender)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Steps
            VStack(spacing: 10) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            steps[index].isCompleted.toggle()
                            saveTodayProgress()
                        }
                        HapticManager.impact(.light)
                    } label: {
                        HStack(spacing: 12) {
                            // Check circle
                            ZStack {
                                Circle()
                                    .fill(step.isCompleted ? step.color : step.color.opacity(0.15))
                                    .frame(width: 28, height: 28)

                                if step.isCompleted {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: step.icon)
                                        .font(.system(size: 11))
                                        .foregroundStyle(step.color)
                                }
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(step.title)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(step.isCompleted ? AppColors.lavender.opacity(0.5) : AppColors.cream)
                                    .strikethrough(step.isCompleted, color: AppColors.lavender.opacity(0.3))

                                Text(step.subtitle)
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundStyle(AppColors.lavender.opacity(step.isCompleted ? 0.3 : 0.6))
                            }

                            Spacer()

                            if step.isCompleted {
                                Image(systemName: "sparkle")
                                    .font(.system(size: 8))
                                    .foregroundStyle(step.color.opacity(0.6))
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(step.isCompleted ? step.color.opacity(0.06) : AppColors.deepViolet.opacity(0.4))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(step.isCompleted ? step.color.opacity(0.2) : Color.clear, lineWidth: 0.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            // Completion celebration
            if allCompleted && !showCompletion {
                Button {
                    withAnimation(.spring(response: 0.5)) {
                        showCompletion = true
                    }
                    HapticManager.notification(.success)
                    // Update best streak if needed
                    let current = StreakTracker.current
                    let best = UserDefaults.standard.integer(forKey: "bestStreakCount")
                    if current > best {
                        UserDefaults.standard.set(current, forKey: "bestStreakCount")
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                        Text("Devotion Complete")
                        Image(systemName: "sparkles")
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.cream)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [AppColors.gold.opacity(0.8), AppColors.ember.opacity(0.8)],
                            startPoint: .leading, endPoint: .trailing
                        ),
                        in: Capsule()
                    )
                    .shadow(color: AppColors.gold.opacity(0.3), radius: 10, y: 4)
                }
                .transition(.scale.combined(with: .opacity))
            }

            if showCompletion {
                VStack(spacing: 8) {
                    Text("You showed up for your sacred path today")
                        .font(AppFont.serifTitle(14))
                        .foregroundStyle(AppColors.cream)
                    Text("The divine council honors your devotion")
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColors.lavender)
                }
                .padding(.vertical, 8)
                .transition(.opacity)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [AppColors.purple.opacity(0.12), AppColors.deepViolet.opacity(0.75)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(AppColors.gold.opacity(0.18), lineWidth: 1)
        )
        .onAppear {
            loadTodayProgress()
        }
    }

    // MARK: - Persistence

    private func saveTodayProgress() {
        let completedIDs = steps.filter(\.isCompleted).map(\.id.uuidString)
        let todayKey = devotionDateKey()
        UserDefaults.standard.set(completedIDs, forKey: todayKey)
    }

    private func loadTodayProgress() {
        let todayKey = devotionDateKey()
        guard let savedIDs = UserDefaults.standard.stringArray(forKey: todayKey) else { return }
        let savedSet = Set(savedIDs)
        for i in steps.indices {
            if savedSet.contains(steps[i].id.uuidString) {
                steps[i].isCompleted = true
            }
        }
        // Check if completion was already shown today
        if steps.allSatisfy(\.isCompleted) {
            showCompletion = true
        }
    }

    private func devotionDateKey() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return "devotion_\(f.string(from: Date()))"
    }
}

// MARK: - Devotion Step Model

struct DevotionStep: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var isCompleted: Bool

    /// Generate today's devotion steps — stable per day (seeded by day-of-year)
    static func todaySteps() -> [DevotionStep] {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0

        // Core steps always present
        var steps = [
            DevotionStep(
                id: stableUUID("meditate", day: dayOfYear),
                title: "Sacred Meditation",
                subtitle: "Even 3 minutes shifts your frequency",
                icon: "moon.stars.fill",
                color: AppColors.purple,
                isCompleted: false
            ),
            DevotionStep(
                id: stableUUID("journal", day: dayOfYear),
                title: "Soul Journal",
                subtitle: "Write what your heart needs to release",
                icon: "book.fill",
                color: AppColors.rose,
                isCompleted: false
            ),
            DevotionStep(
                id: stableUUID("affirm", day: dayOfYear),
                title: "Speak Your Affirmation",
                subtitle: "Say it aloud — your voice carries power",
                icon: "sparkles",
                color: AppColors.gold,
                isCompleted: false
            ),
            DevotionStep(
                id: stableUUID("hydrate", day: dayOfYear),
                title: "Sacred Hydration",
                subtitle: "Bless your water and drink deeply",
                icon: "drop.fill",
                color: Color(hex: "4FC3F7"),
                isCompleted: false
            ),
        ]

        // Rotating bonus step based on day
        let bonusSteps = [
            DevotionStep(id: stableUUID("bonus", day: dayOfYear), title: "Gratitude Offering", subtitle: "Name 3 things you're grateful for", icon: "heart.fill", color: AppColors.sage, isCompleted: false),
            DevotionStep(id: stableUUID("bonus", day: dayOfYear), title: "Prayer or Invocation", subtitle: "Speak to the divine council", icon: "hands.sparkles.fill", color: AppColors.coral, isCompleted: false),
            DevotionStep(id: stableUUID("bonus", day: dayOfYear), title: "Cord Cutting Breath", subtitle: "Breathe out what isn't yours", icon: "wind", color: AppColors.ember, isCompleted: false),
            DevotionStep(id: stableUUID("bonus", day: dayOfYear), title: "Mirror Affirmation", subtitle: "Look yourself in the eyes and affirm love", icon: "face.smiling", color: AppColors.rose, isCompleted: false),
            DevotionStep(id: stableUUID("bonus", day: dayOfYear), title: "Chakra Check-in", subtitle: "Scan your 7 energy centers", icon: "rays", color: Color(hex: "AB47BC"), isCompleted: false),
            DevotionStep(id: stableUUID("bonus", day: dayOfYear), title: "Dream Recall", subtitle: "Write down last night's messages", icon: "cloud.moon.fill", color: Color(hex: "7986CB"), isCompleted: false),
            DevotionStep(id: stableUUID("bonus", day: dayOfYear), title: "Sacred Movement", subtitle: "Stretch, dance, or walk with intention", icon: "figure.walk", color: AppColors.sage, isCompleted: false),
        ]

        steps.append(bonusSteps[dayOfYear % bonusSteps.count])
        return steps
    }

    /// Generate a stable UUID from a string seed + day, so the same step has the same ID each session on the same day
    private static func stableUUID(_ seed: String, day: Int) -> UUID {
        let combined = "\(seed)_\(day)"
        let hash = combined.utf8.reduce(0) { ($0 &* 31) &+ UInt64($1) }
        // Build a deterministic UUID from the hash
        var bytes = [UInt8](repeating: 0, count: 16)
        for i in 0..<8 {
            bytes[i] = UInt8((hash >> (i * 8)) & 0xFF)
        }
        for i in 8..<16 {
            bytes[i] = UInt8(((hash &* 37) >> ((i - 8) * 8)) & 0xFF)
        }
        // Set version 4 and variant bits
        bytes[6] = (bytes[6] & 0x0F) | 0x40
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        let uuid = NSUUID(uuidBytes: bytes) as UUID
        return uuid
    }
}
