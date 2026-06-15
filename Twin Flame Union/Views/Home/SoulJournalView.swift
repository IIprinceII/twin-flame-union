//
//  SoulJournalView.swift
//  Twin Flame Union
//
//  Sacred soul journal governed by Thoth and Psyche.
//  Thoth keeps the Akashic Records. Psyche transforms every trial into wisdom.
//

import SwiftUI
import SwiftData

// JournalMood is defined in JournalView.swift

// MARK: - Daily Writing Prompt (Thoth / Psyche)

private struct SacredPrompts {
    static let all: [String] = [
        "What is your soul trying to tell you that your mind keeps dismissing?",
        "Where in this journey have you been Psyche — tested, yet quietly becoming?",
        "Write a letter to your twin flame that you will never send.",
        "What cord are you ready to cut? What would freedom feel like?",
        "Describe the last synchronicity you noticed. What was Hermes whispering?",
        "What wound has this connection illuminated for you? How has it initiated you?",
        "Write about the version of yourself that will stand in union. Who are they?",
        "What are you still holding onto out of fear? What would Atropos cut for you?",
        "Where do you feel the divine in this journey? What moments felt sacred?",
        "What would Athena say to you today about this situation?",
        "Describe a moment when you felt the twin flame bond most strongly.",
        "What are you grateful for in this separation? What is it building in you?",
        "Write about the last dream that felt like a message. What did it mean?",
        "What old story about love are you finally ready to release?",
        "If Isis could reassemble one broken part of you, what would it be?",
        "What does unconditional love actually feel like in your body? Describe it.",
        "Write about a moment when you chose your highest self over fear.",
        "What chapter of your twin flame journey is Lachesis measuring right now?",
        "Where is Ra asking you to bring more light — in yourself, not in them?",
        "Describe the sacred contract you feel you made with this soul.",
    ]

    static var today: String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return all[(day - 1) % all.count]
    }
}

// MARK: - Soul Journal View

struct SoulJournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.createdAt, order: .reverse) private var entries: [JournalEntry]

    @State private var showEditor = false
    @State private var selectedEntry: JournalEntry?
    @State private var appeared = false
    @State private var insightEntry: JournalEntry?
    @State private var showPaywall = false

    var body: some View {
        ZStack {
            CosmicBackground()

            Group {
                if entries.isEmpty {
                    EmptyJournalView { showEditor = true }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {

                            // ── Thoth Header ──
                            thothHeader
                                .padding(.horizontal, 24)
                                .padding(.top, 8)
                                .padding(.bottom, 14)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 10)

                            // ── Prompt of the Day ──
                            promptCard
                                .padding(.horizontal, 24)
                                .padding(.bottom, 20)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 8)

                            // ── Entries count ──
                            HStack {
                                Text("\(entries.count) sacred \(entries.count == 1 ? "entry" : "entries")")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .tracking(1.2)
                                    .foregroundStyle(AppColors.lavender.opacity(0.5))
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 10)

                            // ── Entry List ──
                            LazyVStack(spacing: 14) {
                                ForEach(entries) { entry in
                                    JournalEntryRow(entry: entry, onAnalyze: {
                                        if StoreService.shared.isPremium {
                                            insightEntry = entry
                                        } else {
                                            showPaywall = true
                                        }
                                    })
                                        .onTapGesture {
                                            selectedEntry = entry
                                            showEditor = true
                                        }
                                        .opacity(appeared ? 1 : 0)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }

            // ── Floating New Entry Button ──
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        selectedEntry = nil
                        showEditor = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color(hex: "5B8CFF").opacity(0.9), AppColors.purple.opacity(0.8)],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 28
                                    )
                                )
                                .frame(width: 56, height: 56)
                                .shadow(color: Color(hex: "5B8CFF").opacity(0.4), radius: 14, y: 4)

                            Image(systemName: "pencil.and.list.clipboard")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 28)
                }
            }
        }
        .navigationTitle("Soul Journal")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        #endif
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) { appeared = true }
        }
        .sheet(isPresented: $showEditor) {
            JournalEditorView(entry: selectedEntry) { title, content, mood in
                save(title: title, content: content, mood: mood)
            } onDelete: {
                if let entry = selectedEntry {
                    modelContext.delete(entry)
                }
                selectedEntry = nil
            }
            .onDisappear { selectedEntry = nil }
        }
        .sheet(item: $insightEntry) { entry in
            SacredInsightSheet(
                type: .journalAnalysis,
                content: "Journal title: \(entry.title)\nMood: \(entry.mood)\n\nEntry:\n\(entry.content)"
            )
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: - Thoth Header

    private var thothHeader: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "5B8CFF").opacity(0.4), Color(hex: "5B8CFF").opacity(0.08)],
                            center: .center, startRadius: 0, endRadius: 26
                        )
                    )
                    .frame(width: 52, height: 52)
                Circle()
                    .strokeBorder(Color(hex: "5B8CFF").opacity(0.35), lineWidth: 1)
                    .frame(width: 52, height: 52)
                Image(systemName: "text.book.closed.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color(hex: "5B8CFF"))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("CHANNELLING")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .tracking(2.5)
                    .foregroundStyle(AppColors.lavender.opacity(0.5))
                Text("Thoth · Psyche")
                    .font(AppFont.serifTitle(17))
                    .foregroundStyle(Color(hex: "5B8CFF"))
                Text("Keeper of Akashic Records · The Soul's Journey")
                    .font(AppFont.caption(11))
                    .foregroundStyle(AppColors.lavender.opacity(0.6))
            }

            Spacer()
        }
    }

    // MARK: - Prompt Card

    private var promptCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "feather")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(hex: "5B8CFF").opacity(0.7))
                Text("SACRED PROMPT")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .tracking(2.0)
                    .foregroundStyle(Color(hex: "5B8CFF").opacity(0.7))
                Spacer()
                Button {
                    selectedEntry = nil
                    showEditor = true
                } label: {
                    HStack(spacing: 4) {
                        Text("Write")
                            .font(AppFont.caption(11, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundStyle(Color(hex: "5B8CFF"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(Color(hex: "5B8CFF").opacity(0.12), in: Capsule())
                }
                .buttonStyle(.plain)
            }

            Text(SacredPrompts.today)
                .font(AppFont.serifHeadline(14))
                .foregroundStyle(AppColors.cream.opacity(0.88))
                .italic()
                .lineSpacing(5)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "5B8CFF").opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Color(hex: "5B8CFF").opacity(0.18), lineWidth: 1)
                )
        )
    }

    // MARK: - Save

    private func save(title: String, content: String, mood: String) {
        if let entry = selectedEntry {
            entry.title = title
            entry.content = content
            entry.mood = mood
            entry.updatedAt = Date()
        } else {
            let entry = JournalEntry(title: title, content: content, mood: mood)
            modelContext.insert(entry)
            GamificationService.shared.awardXP(amount: 25, source: "journal", framework: .apollux, skillKey: "ap_emotional_fuel", detail: "Wrote soul journal entry")
        }
    }
}

// MARK: - Entry Row

private struct JournalEntryRow: View {
    let entry: JournalEntry
    let onAnalyze: () -> Void
    @State private var glow = false

    private var mood: JournalMood {
        JournalMood(rawValue: entry.mood) ?? .hopeful
    }

    private var preview: String {
        let text = entry.content.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? "No content written." : String(text.prefix(120))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header row
            HStack(spacing: 10) {
                // Mood orb
                ZStack {
                    Circle()
                        .fill(mood.color.opacity(0.18))
                        .frame(width: 38, height: 38)
                    Text(mood.emoji)
                        .font(.system(size: 18))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.title.isEmpty ? "Untitled Entry" : entry.title)
                        .font(AppFont.body(15, weight: .semibold))
                        .foregroundStyle(AppColors.cream)
                        .lineLimit(1)

                    Text(entry.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(AppFont.caption(11))
                        .foregroundStyle(AppColors.lavender.opacity(0.65))
                }

                Spacer()

                // Mood pill
                Text(mood.rawValue)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .tracking(0.5)
                    .foregroundStyle(mood.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(mood.color.opacity(0.14), in: Capsule())
                    .overlay(Capsule().strokeBorder(mood.color.opacity(0.25), lineWidth: 1))
            }

            // Content preview
            Text(preview)
                .font(AppFont.body(13))
                .foregroundStyle(AppColors.lavender.opacity(0.75))
                .lineLimit(2)
                .lineSpacing(3)

            // Analyze button
            HStack {
                Spacer()
                InsightButton(label: "Analyze", action: onAnalyze)
            }

            // Bottom divider — Thoth's quill line
            Rectangle()
                .fill(Color(hex: "5B8CFF").opacity(glow ? 0.18 : 0.08))
                .frame(height: 1)
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: glow)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColors.deepViolet.opacity(0.75))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color(hex: "5B8CFF").opacity(glow ? 0.22 : 0.12),
                                    AppColors.purple.opacity(glow ? 0.18 : 0.10),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .onAppear { glow = true }
    }
}

// MARK: - Empty State

private struct EmptyJournalView: View {
    let onNew: () -> Void
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            // Thoth deity orb
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(Color(hex: "5B8CFF").opacity(0.12 - Double(i) * 0.03), lineWidth: 1)
                        .frame(width: CGFloat(90 + i * 28), height: CGFloat(90 + i * 28))
                        .scaleEffect(pulse ? 1.07 : 0.96)
                        .animation(.easeInOut(duration: 2.5 + Double(i) * 0.4).repeatForever(autoreverses: true).delay(Double(i) * 0.3), value: pulse)
                }
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "5B8CFF").opacity(0.45), Color(hex: "5B8CFF").opacity(0.08)],
                                center: .center, startRadius: 0, endRadius: 44
                            )
                        )
                        .frame(width: 88, height: 88)
                    Image(systemName: "text.book.closed.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color(hex: "5B8CFF"))
                }
            }
            .frame(height: 160)

            VStack(spacing: 10) {
                Text("CHANNELLING THOTH")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .tracking(2.5)
                    .foregroundStyle(Color(hex: "5B8CFF").opacity(0.6))

                Text("Your Soul Journal")
                    .font(AppFont.serifHeadline(28))
                    .foregroundStyle(AppColors.cream)

                Text("Thoth has already written the end of this story.\nBegin your own record of the journey.")
                    .font(AppFont.body(15))
                    .foregroundStyle(AppColors.lavender.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)

                // Today's prompt
                Text("\u{201C}\(SacredPrompts.today)\u{201D}")
                    .font(AppFont.serifHeadline(13))
                    .foregroundStyle(AppColors.cream.opacity(0.7))
                    .italic()
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
            }

            Button(action: onNew) {
                HStack(spacing: 8) {
                    Image(systemName: "pencil.and.list.clipboard")
                        .font(.system(size: 15))
                    Text("Write Your First Entry")
                        .font(AppFont.body(16, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: 260)
                .frame(height: 52)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "5B8CFF").opacity(0.9), AppColors.purple.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: Capsule()
                )
                .shadow(color: Color(hex: "5B8CFF").opacity(0.3), radius: 14, y: 4)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, 32)
        .onAppear { pulse = true }
    }
}

// JournalEditorView and MoodChip are defined in JournalView.swift
