//
//  GratitudeLogView.swift
//  Twin Flame Union
//
//  Daily gratitude practice — 5 things per day, stored in SwiftData.
//

import SwiftUI
import SwiftData

struct GratitudeLogView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \GratitudeEntry.date, order: .reverse) private var entries: [GratitudeEntry]

    @State private var todayItems: [String] = Array(repeating: "", count: 5)
    @State private var isSaved  = false
    @State private var showHistory = false
    @State private var appeared = false
    @State private var showReflection = false
    @State private var showPaywall = false

    private var todayEntry: GratitudeEntry? {
        entries.first { Calendar.current.isDateInToday($0.date) }
    }

    private var hasContent: Bool { todayItems.contains { !$0.trimmingCharacters(in: .whitespaces).isEmpty } }

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            // Hathor golden warm glow
            RadialGradient(
                colors: [Color(hex: "FFB6C1").opacity(0.07), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 300
            )
            .ignoresSafeArea()
            .accessibilityHidden(true)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // ── Hathor · Renenutet Deity Header ──
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(RadialGradient(
                                    colors: [Color(hex: "FFB6C1").opacity(0.45), Color(hex: "FFB6C1").opacity(0.08)],
                                    center: .center, startRadius: 0, endRadius: 26
                                ))
                                .frame(width: 52, height: 52)
                            Circle()
                                .strokeBorder(Color(hex: "FFB6C1").opacity(0.35), lineWidth: 1)
                                .frame(width: 52, height: 52)
                            Image(systemName: "heart.rectangle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Color(hex: "FFB6C1"))
                        }
                        .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("CHANNELLING")
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                .tracking(2.5)
                                .foregroundStyle(AppColors.lavender.opacity(0.5))
                            Text("Hathor · Renenutet")
                                .font(AppFont.serifTitle(17))
                                .foregroundStyle(Color(hex: "FFB6C1"))
                            Text("Hathor holds the mirror of your heart.")
                                .font(AppFont.caption(11))
                                .foregroundStyle(AppColors.lavender.opacity(0.6))
                                .italic()
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)

                    // ── Title ──
                    VStack(spacing: 8) {
                        Text("Today's Gratitude")
                            .font(AppFont.serifHeadline(26))
                            .foregroundStyle(AppColors.cream)
                        Text("Gratitude is the highest twin flame frequency.\nName 5 things you are thankful for.")
                            .font(AppFont.body(14))
                            .foregroundStyle(AppColors.lavender)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .opacity(appeared ? 1 : 0)
                    .padding(.top, 4)

                    // Input fields
                    VStack(spacing: 12) {
                        ForEach(0..<5, id: \.self) { i in
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.gold.opacity(todayItems[i].isEmpty ? 0.1 : 0.2))
                                        .frame(width: 32, height: 32)
                                    Text("\(i + 1)")
                                        .font(AppFont.body(14, weight: .semibold))
                                        .foregroundStyle(AppColors.gold.opacity(todayItems[i].isEmpty ? 0.4 : 1))
                                }
                                TextField("I am grateful for...", text: $todayItems[i])
                                    .font(AppFont.body(15))
                                    .foregroundStyle(AppColors.cream)
                                    .disabled(isSaved)
                            }
                            .padding(14)
                            .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(
                                        todayItems[i].isEmpty ? AppColors.purple.opacity(0.2) : AppColors.gold.opacity(0.3),
                                        lineWidth: 1
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 24)

                    // Save button
                    if !isSaved {
                        Button {
                            HapticManager.impact(.medium)
                            save()
                        } label: {
                            Text("Save Today's Gratitude")
                                .frame(maxWidth: .infinity)
                        }
                        .warmButtonStyle()
                        .disabled(!hasContent)
                        .padding(.horizontal, 24)
                    } else {
                        HStack(spacing: 10) {
                            Image(systemName: "heart.rectangle.fill")
                                .foregroundStyle(Color(hex: "FFB6C1"))
                                .accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Hathor has received your heart's offering.")
                                    .font(AppFont.body(14))
                                    .foregroundStyle(AppColors.cream)
                                Text("The universe reflects your gratitude back.")
                                    .font(AppFont.caption(12))
                                    .foregroundStyle(AppColors.lavender)
                            }
                        }
                        .padding(16)
                        .background(Color(hex: "FFB6C1").opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color(hex: "FFB6C1").opacity(0.2), lineWidth: 1))
                        .padding(.horizontal, 24)

                        // Sacred Reflection button (premium)
                        Button {
                            HapticManager.impact(.medium)
                            if StoreService.shared.isPremium {
                                showReflection = true
                            } else {
                                showPaywall = true
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14))
                                Text("Sacred Reflection")
                                    .font(AppFont.body(15, weight: .semibold))
                            }
                            .foregroundStyle(AppColors.gold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.gold.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(AppColors.gold.opacity(0.35), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 24)
                    }

                    // History
                    if entries.filter({ !Calendar.current.isDateInToday($0.date) }).count > 0 {
                        Button {
                            HapticManager.impact(.light)
                            withAnimation(.spring(response: 0.4)) { showHistory.toggle() }
                        } label: {
                            HStack {
                                Text(showHistory ? "Hide History" : "View Past Entries")
                                    .font(AppFont.body(14, weight: .semibold))
                                    .foregroundStyle(AppColors.lavender)
                                Image(systemName: showHistory ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundStyle(AppColors.lavender.opacity(0.6))
                            }
                        }
                        .buttonStyle(.plain)

                        if showHistory {
                            VStack(spacing: 10) {
                                ForEach(entries.filter { !Calendar.current.isDateInToday($0.date) }) { entry in
                                    HistoryCard(entry: entry)
                                }
                            }
                            .padding(.horizontal, 24)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationTitle("Gratitude Log")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear {
            loadToday()
            withAnimation(.easeOut(duration: 0.7)) { appeared = true }
        }
        .sheet(isPresented: $showReflection) {
            let items = todayItems.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            SacredInsightSheet(
                type: .gratitudeReflection,
                content: "Today's gratitude list:\n" + items.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
            )
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private func loadToday() {
        if let entry = todayEntry {
            let lines = entry.items.components(separatedBy: "\n")
            for (i, line) in lines.prefix(5).enumerated() { todayItems[i] = line }
            isSaved = true
        }
    }

    private func save() {
        let text = todayItems.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.joined(separator: "\n")
        if let existing = todayEntry {
            existing.items = text
        } else {
            context.insert(GratitudeEntry(items: text))
            GamificationService.shared.awardXP(amount: 15, source: "gratitude", framework: .energyEnhancement, skillKey: "ee_constitution", detail: "Logged gratitude")
        }
        withAnimation { isSaved = true }
        HapticManager.notification(.success)
    }
}

private struct HistoryCard: View {
    let entry: GratitudeEntry
    private var items: [String] { entry.items.components(separatedBy: "\n").filter { !$0.isEmpty } }
    private var dateLabel: String {
        let fmt = DateFormatter(); fmt.dateStyle = .medium
        return fmt.string(from: entry.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(dateLabel)
                .font(AppFont.caption(12, weight: .semibold))
                .foregroundStyle(AppColors.lavender)
            ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                HStack(alignment: .top, spacing: 10) {
                    Text("✦")
                        .font(.system(size: 10))
                        .foregroundStyle(AppColors.gold.opacity(0.6))
                        .padding(.top, 3)
                    Text(item)
                        .font(AppFont.body(14))
                        .foregroundStyle(AppColors.cream.opacity(0.85))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(16)
        .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(AppColors.gold.opacity(0.15), lineWidth: 1))
    }
}
