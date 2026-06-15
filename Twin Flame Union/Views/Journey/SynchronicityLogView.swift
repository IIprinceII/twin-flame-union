//
//  SynchronicityLogView.swift
//  Twin Flame Union
//
//  Log and review synchronicity signs — angel numbers, shared songs, recurring thoughts.
//

import SwiftUI
import SwiftData

// MARK: - Main View

struct SynchronicityLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SynchronicityEntry.createdAt, order: .reverse) private var entries: [SynchronicityEntry]

    @State private var showAngelNumberSheet = false
    @State private var insightEntry: SynchronicityEntry?
    @State private var showPaywall = false

    // MARK: Computed Properties

    private var weekCount: Int {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return entries.filter { $0.createdAt >= cutoff }.count
    }

    private var weekSubtitle: String {
        switch weekCount {
        case 0:
            return "The universe is always speaking — stay present"
        case 1...3:
            return "You're noticing the signs — keep your heart open"
        case 4...7:
            return "Strong cosmic communication — your twin is close"
        default:
            return "Extraordinary alignment — union energy is peaking"
        }
    }

    /// Entries grouped by calendar day, sorted with most-recent day first.
    private var groupedEntries: [(key: Date, value: [SynchronicityEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.createdAt)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    // MARK: Body

    var body: some View {
        ZStack {
            CosmicBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    weeklyStatsBanner
                    quickLogGrid
                    logSection
                    Spacer().frame(height: 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .navigationTitle("Synchronicity Log")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showAngelNumberSheet) {
            AngelNumberInputSheet { number in
                logEntry(type: "Angel Number", detail: number)
            }
        }
        .sheet(item: $insightEntry) { entry in
            SacredInsightSheet(
                type: .synchronicityDecode,
                content: "Synchronicity type: \(entry.type)\nDetail: \(entry.detail)\nLogged: \(entry.createdAt.formatted())"
            )
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: - Weekly Stats Banner

    private var weeklyStatsBanner: some View {
        HStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 28))
                .foregroundStyle(AppColors.gold)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(weekCount) synchronicities this week")
                    .font(AppFont.body(17, weight: .semibold))
                    .foregroundStyle(AppColors.cream)

                Text(weekSubtitle)
                    .font(AppFont.body(13))
                    .foregroundStyle(AppColors.lavender)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(20)
        .background(AppColors.deepViolet.opacity(0.85), in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(AppColors.gold.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Quick Log Grid

    private var quickLogGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LOG A SIGN")
                .font(AppFont.body(11, weight: .semibold))
                .foregroundStyle(AppColors.lavender)
                .kerning(1.2)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                ForEach(SyncType.allCases) { syncType in
                    SyncTypeButton(syncType: syncType) {
                        if syncType.label == "Angel Number" {
                            showAngelNumberSheet = true
                        } else {
                            logEntry(type: syncType.label, detail: "")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Log Section

    private var logSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("YOUR SIGNS")
                .font(AppFont.body(11, weight: .semibold))
                .foregroundStyle(AppColors.lavender)
                .kerning(1.2)

            if entries.isEmpty {
                emptyState
            } else {
                ForEach(groupedEntries, id: \.key) { day, dayEntries in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(dayHeader(for: day))
                            .font(AppFont.body(12, weight: .semibold))
                            .foregroundStyle(AppColors.lavender.opacity(0.7))
                            .kerning(0.5)
                            .padding(.top, 4)

                        ForEach(dayEntries) { entry in
                            SyncEntryRow(entry: entry, onDecode: {
                                if StoreService.shared.isPremium {
                                    insightEntry = entry
                                } else {
                                    showPaywall = true
                                }
                            })
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteEntry(entry)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("🦋")
                .font(.system(size: 44))
            Text("No signs logged yet")
                .font(AppFont.body(16, weight: .semibold))
                .foregroundStyle(AppColors.cream)
            Text("Start noticing the magic around you")
                .font(AppFont.body(14))
                .foregroundStyle(AppColors.lavender)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(AppColors.deepViolet.opacity(0.5), in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private func logEntry(type: String, detail: String) {
        let entry = SynchronicityEntry(type: type, detail: detail)
        modelContext.insert(entry)
        GamificationService.shared.awardXP(amount: 15, source: "synchronicity", framework: .vibrationalGame, skillKey: "vg_influence", detail: "Logged synchronicity: \(type)")
    }

    private func deleteEntry(_ entry: SynchronicityEntry) {
        modelContext.delete(entry)
    }

    private func dayHeader(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Sync Type Model

private enum SyncType: String, CaseIterable, Identifiable {
    case angelNumber      = "Angel Number"
    case thoughtOfThem    = "Thought of Them"
    case sameSong         = "Same Song"
    case samePlace        = "Same Place"
    case dreamSign        = "Dream Sign"
    case physicalSign     = "Physical Sign"
    case energyShift      = "Energy Shift"
    case coincidence      = "Coincidence"
    case telepathy        = "Telepathy"
    case energyReading    = "Energy Reading"
    case prayerAnswered   = "Prayer Answered"
    case returnToSender   = "Return to Sender"
    case michaelsShield   = "Michael's Shield"
    case covenantMoment   = "Covenant Moment"

    var id: String { rawValue }
    var label: String { rawValue }

    var icon: String {
        switch self {
        case .angelNumber:    return "🔢"
        case .thoughtOfThem:  return "💭"
        case .sameSong:       return "🎵"
        case .samePlace:      return "📍"
        case .dreamSign:      return "🌙"
        case .physicalSign:   return "🦋"
        case .energyShift:    return "⚡"
        case .coincidence:    return "🔄"
        case .telepathy:      return "🧿"
        case .energyReading:  return "👁"
        case .prayerAnswered: return "🙏"
        case .returnToSender: return "🛡"
        case .michaelsShield: return "⚔️"
        case .covenantMoment: return "👑"
        }
    }

    var color: Color {
        switch self {
        case .angelNumber:    return AppColors.gold
        case .thoughtOfThem:  return Color(hex: "FF6B9D")
        case .sameSong:       return Color(hex: "4A90D9")
        case .samePlace:      return Color(hex: "4CAF82")
        case .dreamSign:      return AppColors.lavender
        case .physicalSign:   return Color(hex: "E0D4F7")
        case .energyShift:    return Color(hex: "9B59B6")
        case .coincidence:    return Color(hex: "26C6DA")
        case .telepathy:      return Color(hex: "C39BD3")
        case .energyReading:  return Color(hex: "7FDBFF")
        case .prayerAnswered: return Color(hex: "E8E4F0")
        case .returnToSender: return Color(hex: "FF6B6B")
        case .michaelsShield: return Color(hex: "4169E1")
        case .covenantMoment: return Color(hex: "D4C5F0")
        }
    }
}

// MARK: - Sync Type Button

private struct SyncTypeButton: View {
    let syncType: SyncType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(syncType.icon)
                    .font(.system(size: 28))
                Text(syncType.label)
                    .font(AppFont.body(10))
                    .foregroundStyle(AppColors.cream)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(syncType.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(syncType.color.opacity(0.35), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Entry Row

private struct SyncEntryRow: View {
    let entry: SynchronicityEntry
    var onDecode: (() -> Void)? = nil

    private var typeEmoji: String {
        switch entry.type {
        case "Angel Number":    return "🔢"
        case "Thought of Them": return "💭"
        case "Same Song":       return "🎵"
        case "Same Place":      return "📍"
        case "Dream Sign":      return "🌙"
        case "Physical Sign":   return "🦋"
        case "Energy Shift":    return "⚡"
        case "Coincidence":     return "🔄"
        case "Telepathy":       return "🧿"
        case "Energy Reading":  return "👁"
        case "Prayer Answered": return "🙏"
        case "Return to Sender": return "🛡"
        case "Michael's Shield": return "⚔️"
        case "Covenant Moment": return "👑"
        default:                return "✨"
        }
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: entry.createdAt)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 12) {
                Text(typeEmoji)
                    .font(.system(size: 22))

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.type)
                        .font(AppFont.body(14, weight: .semibold))
                        .foregroundStyle(AppColors.cream)

                    if !entry.detail.isEmpty {
                        Text(entry.detail)
                            .font(AppFont.body(13))
                            .foregroundStyle(AppColors.gold)
                    }
                }

                Spacer()

                Text(timeString)
                    .font(AppFont.body(11))
                    .foregroundStyle(AppColors.lavender)
            }

            if !entry.note.isEmpty {
                Text(entry.note)
                    .font(.system(size: 12, weight: .regular, design: .default).italic())
                    .foregroundStyle(AppColors.lavender)
                    .padding(.leading, 34)
            }

            if let onDecode {
                HStack {
                    Spacer()
                    InsightButton(label: "Decode", action: onDecode)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppColors.purple.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Angel Number Input Sheet

private struct AngelNumberInputSheet: View {
    let onConfirm: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var numberInput: String = ""

    var body: some View {
        ZStack {
            AppColors.deepViolet
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Which angel number?")
                    .font(AppFont.body(18, weight: .semibold))
                    .foregroundStyle(AppColors.cream)
                    .padding(.top, 24)

                TextField("e.g. 444", text: $numberInput)
                    .keyboardType(.numberPad)
                    .font(AppFont.body(17))
                    .foregroundStyle(AppColors.cream)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(AppColors.purple.opacity(0.2), in: RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(AppColors.gold.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 28)

                Button {
                    let trimmed = numberInput.trimmingCharacters(in: .whitespaces)
                    onConfirm(trimmed)
                    dismiss()
                } label: {
                    Text("Log It")
                        .frame(maxWidth: .infinity)
                }
                .disabled(numberInput.trimmingCharacters(in: .whitespaces).isEmpty)
                .primaryAuthButton(isEnabled: !numberInput.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal, 28)

                Spacer()
            }
        }
        .presentationDetents([.height(200)])
        .presentationBackground(AppColors.deepViolet)
        .preferredColorScheme(.dark)
    }
}
