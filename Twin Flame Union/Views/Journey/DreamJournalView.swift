//
//  DreamJournalView.swift
//  Twin Flame Union
//
//  Dream journal — list and editor for nightly dream entries.
//

import SwiftUI
import SwiftData
import StoreKit

// MARK: - Dream Journal List View

struct DreamJournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DreamEntry.createdAt, order: .reverse) private var entries: [DreamEntry]

    @State private var showEditor = false
    @State private var entryToEdit: DreamEntry? = nil
    @State private var appeared = false
    @State private var dreamToInterpret: DreamEntry? = nil
    @State private var showPaywall = false

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            // Morpheus dream-blue atmospheric glow
            RadialGradient(
                colors: [Color(hex: "4A90D9").opacity(0.06), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 320
            )
            .ignoresSafeArea()
            .accessibilityHidden(true)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // ── Morpheus · Hypnos Deity Banner ──
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(RadialGradient(
                                    colors: [Color(hex: "4A90D9").opacity(0.45), Color(hex: "4A90D9").opacity(0.08)],
                                    center: .center, startRadius: 0, endRadius: 26
                                ))
                                .frame(width: 52, height: 52)
                            Circle()
                                .strokeBorder(Color(hex: "4A90D9").opacity(0.35), lineWidth: 1)
                                .frame(width: 52, height: 52)
                            Image(systemName: "moon.zzz.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Color(hex: "4A90D9"))
                        }
                        .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("CHANNELLING")
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                .tracking(2.5)
                                .foregroundStyle(AppColors.lavender.opacity(0.5))
                            Text("Morpheus · Hypnos")
                                .font(AppFont.serifTitle(17))
                                .foregroundStyle(Color(hex: "4A90D9"))
                            Text("In dreams the veil lifts. What you saw is real.")
                                .font(AppFont.caption(11))
                                .foregroundStyle(AppColors.lavender.opacity(0.6))
                                .italic()
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)

                    if entries.isEmpty {
                        // ── Empty State ──
                        VStack(spacing: 20) {
                            ZStack {
                                ForEach(0..<3, id: \.self) { i in
                                    Circle()
                                        .stroke(Color(hex: "4A90D9").opacity(0.1 - Double(i) * 0.025), lineWidth: 1)
                                        .frame(width: CGFloat(80 + i * 26), height: CGFloat(80 + i * 26))
                                }
                                ZStack {
                                    Circle()
                                        .fill(RadialGradient(
                                            colors: [Color(hex: "4A90D9").opacity(0.35), Color(hex: "4A90D9").opacity(0.05)],
                                            center: .center, startRadius: 0, endRadius: 38
                                        ))
                                        .frame(width: 76, height: 76)
                                    Image(systemName: "moon.stars.fill")
                                        .font(.system(size: 32))
                                        .foregroundStyle(Color(hex: "7BB8F0"))
                                }
                            }
                            .frame(height: 150)
                            .accessibilityHidden(true)
                            .padding(.top, 48)

                            VStack(spacing: 8) {
                                Text("No Dreams Recorded")
                                    .font(AppFont.serifTitle(22))
                                    .foregroundStyle(AppColors.cream)
                                Text("Morpheus sends messages every night.\nBegin capturing what the veil reveals.")
                                    .font(AppFont.body(14))
                                    .foregroundStyle(AppColors.lavender)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                    } else {
                        // ── Dream entry rows ──
                        LazyVStack(spacing: 12) {
                            ForEach(entries) { entry in
                                DreamEntryRow(entry: entry, onTap: {
                                    HapticManager.impact(.light)
                                    entryToEdit = entry
                                    showEditor = true
                                }, onInterpret: {
                                    if StoreService.shared.isPremium {
                                        dreamToInterpret = entry
                                    } else {
                                        showPaywall = true
                                    }
                                })
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        modelContext.delete(entry)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .opacity(appeared ? 1 : 0)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) { appeared = true }
        }
        .navigationTitle("Dream Journal")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    HapticManager.impact(.medium)
                    entryToEdit = nil
                    showEditor = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppColors.gold)
                }
                .accessibilityLabel("New dream entry")
            }
        }
        .sheet(isPresented: $showEditor) {
            DreamEntryEditor(entry: entryToEdit)
        }
        .sheet(item: $dreamToInterpret) { dream in
            DreamInterpretationView(entry: dream)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Dream Entry Row

private struct DreamEntryRow: View {
    let entry: DreamEntry
    let onTap: () -> Void
    let onInterpret: () -> Void
    @State private var glow = false

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }()

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {

                // Date + title row
                HStack(spacing: 10) {
                    // Moon orb for date
                    ZStack {
                        Circle()
                            .fill(Color(hex: "4A90D9").opacity(0.15))
                            .frame(width: 38, height: 38)
                        VStack(spacing: 0) {
                            Text(Self.dateFormatter.string(from: entry.createdAt)
                                    .components(separatedBy: " ").first ?? "")
                                .font(.system(size: 8, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color(hex: "7BB8F0").opacity(0.8))
                            Text(Self.dateFormatter.string(from: entry.createdAt)
                                    .components(separatedBy: " ").last ?? "")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(hex: "7BB8F0"))
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.title.isEmpty ? "Untitled Dream" : entry.title)
                            .font(AppFont.body(15, weight: .semibold))
                            .foregroundStyle(AppColors.cream)
                            .lineLimit(1)
                        if entry.isTwinFlameDream {
                            Text("Twin Flame Dream")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .tracking(0.5)
                                .foregroundStyle(AppColors.gold.opacity(0.8))
                        }
                    }

                    Spacer()

                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "4A90D9").opacity(0.5))
                        .accessibilityHidden(true)
                }

                // Content preview
                if !entry.content.isEmpty {
                    let preview = String(entry.content.prefix(100))
                    Text(entry.content.count > 100 ? preview + "…" : preview)
                        .font(AppFont.body(13))
                        .foregroundStyle(AppColors.lavender.opacity(0.75))
                        .lineLimit(2)
                        .lineSpacing(3)
                }

                // Badges row
                HStack(spacing: 8) {
                    if entry.isLucid {
                        DreamBadge(label: "◇ Lucid", backgroundColor: AppColors.purple.opacity(0.2), borderColor: AppColors.purple.opacity(0.5), textColor: AppColors.lavender)
                    }
                    if !entry.wakeFeeling.isEmpty {
                        DreamBadge(label: entry.wakeFeeling, backgroundColor: Color(hex: "4A90D9").opacity(0.12), borderColor: Color(hex: "4A90D9").opacity(0.3), textColor: Color(hex: "7BB8F0"))
                    }
                    Spacer()

                    // Interpret button
                    Button(action: {
                        HapticManager.impact(.light)
                        onInterpret()
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 11))
                            Text("Interpret")
                                .font(AppFont.caption(12, weight: .semibold))
                        }
                        .foregroundStyle(AppColors.gold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.gold.opacity(0.12), in: Capsule())
                        .overlay(Capsule().strokeBorder(AppColors.gold.opacity(0.35), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(AppColors.deepViolet.opacity(0.75))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "4A90D9").opacity(glow ? 0.22 : 0.12),
                                        AppColors.purple.opacity(glow ? 0.18 : 0.08),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .onAppear { glow = true }
    }
}

// MARK: - Dream Badge

private struct DreamBadge: View {
    let label: String
    let backgroundColor: Color
    let borderColor: Color
    let textColor: Color

    var body: some View {
        Text(label)
            .font(AppFont.caption(11, weight: .semibold))
            .foregroundStyle(textColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(backgroundColor, in: Capsule())
            .overlay(Capsule().strokeBorder(borderColor, lineWidth: 1))
    }
}

// MARK: - Dream Entry Editor

private struct DreamEntryEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let entry: DreamEntry?

    // Local state for all fields
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedPeople: Set<String> = []
    @State private var selectedSymbols: Set<String> = []
    @State private var wakeFeeling: String = ""
    @State private var isLucid: Bool = false
    @State private var isTwinFlameDream: Bool = false

    private let peopleOptions = ["My Twin Flame", "KAZZ", "KAI", "Archangel Michael", "Jesus Christ",
                                 "A Guide", "Past Self", "Future Self", "Stranger", "Family", "Other"]
    private let symbolOptions = ["🌊 Water", "🔥 Fire", "🚪 Door", "🪞 Mirror", "🪜 Stairs", "🦋 Butterfly",
                                 "🌹 Rose", "🌙 Moon", "⭐ Stars", "🏠 House", "🌳 Tree", "💎 Crystal",
                                 "👑 Crown", "❤️ Heart", "☀️ Light", "⚔️ Michael", "🛡 Protection",
                                 "🙏 Prayer", "🔱 Covenant", "🧿 Telepathy", "🌀 Shift", "🕊 Freedom",
                                 "💍 Union", "🔮 Truth", "⚡ Healing"]
    private let feelingOptions = ["✨ Hopeful", "💫 Peaceful", "😰 Anxious", "💔 Sad", "🔥 Excited",
                                  "🌀 Confused", "👑 Elevated", "🙏 Grateful", "🛡 Protected", "💞 Reunited"]

    private let threeColumnGrid = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // 1. Title
                        EditorSection(label: "TITLE") {
                            TextField("Give your dream a name…", text: $title)
                                .font(AppFont.body(16))
                                .foregroundStyle(AppColors.cream)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 14)
                                .background(AppColors.deepViolet.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
                                )
                        }

                        // 2. Dream content
                        EditorSection(label: "DREAM") {
                            ZStack(alignment: .topLeading) {
                                if content.isEmpty {
                                    Text("Describe everything you remember…")
                                        .font(AppFont.body(15))
                                        .foregroundStyle(AppColors.lavender.opacity(0.5))
                                        .padding(.top, 12)
                                        .padding(.leading, 6)
                                        .allowsHitTesting(false)
                                }
                                TextEditor(text: $content)
                                    .font(AppFont.body(15))
                                    .foregroundStyle(AppColors.cream)
                                    .scrollContentBackground(.hidden)
                                    .frame(minHeight: 120)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .background(AppColors.deepViolet.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
                            )
                        }

                        // 3. Who appeared
                        EditorSection(label: "WHO APPEARED?") {
                            FlexWrap(items: peopleOptions, selectedItems: $selectedPeople)
                        }

                        // 4. Symbols
                        EditorSection(label: "SYMBOLS") {
                            LazyVGrid(columns: threeColumnGrid, spacing: 8) {
                                ForEach(symbolOptions, id: \.self) { symbol in
                                    let isSelected = selectedSymbols.contains(symbol)
                                    Button {
                                        if isSelected {
                                            selectedSymbols.remove(symbol)
                                        } else {
                                            selectedSymbols.insert(symbol)
                                        }
                                    } label: {
                                        Text(symbol)
                                            .font(AppFont.caption(12))
                                            .foregroundStyle(isSelected ? AppColors.cream : AppColors.lavender)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 6)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                isSelected
                                                    ? AppColors.gold.opacity(0.2)
                                                    : AppColors.deepViolet.opacity(0.5),
                                                in: RoundedRectangle(cornerRadius: 10)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .strokeBorder(
                                                        isSelected
                                                            ? AppColors.gold
                                                            : AppColors.purple.opacity(0.3),
                                                        lineWidth: 1
                                                    )
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // 5. Feeling on wake
                        EditorSection(label: "FEELING ON WAKE") {
                            FlexWrapSingleSelect(items: feelingOptions, selectedItem: $wakeFeeling)
                        }

                        // 6. Toggles
                        EditorSection(label: "DREAM TYPE") {
                            VStack(spacing: 0) {
                                Toggle(isOn: $isLucid) {
                                    Text("Lucid Dream")
                                        .font(AppFont.body(15, weight: .medium))
                                        .foregroundStyle(AppColors.cream)
                                }
                                .tint(AppColors.purple)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 13)

                                Divider()
                                    .background(AppColors.purple.opacity(0.2))
                                    .padding(.horizontal, 14)

                                Toggle(isOn: $isTwinFlameDream) {
                                    Text("Twin Flame Dream")
                                        .font(AppFont.body(15, weight: .medium))
                                        .foregroundStyle(AppColors.cream)
                                }
                                .tint(AppColors.gold)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 13)
                            }
                            .background(AppColors.deepViolet.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
                            )
                        }

                        // Save button
                        Button(action: {
                            HapticManager.impact(.medium)
                            save()
                        }) {
                            Text("Save Dream")
                                .warmButtonStyle()
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
            }
            .navigationTitle(entry == nil ? "New Dream" : "Edit Dream")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(AppFont.body(15))
                    .foregroundStyle(AppColors.lavender)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        HapticManager.impact(.medium)
                        save()
                    }
                    .font(AppFont.body(15, weight: .semibold))
                    .foregroundStyle(AppColors.gold)
                }
            }
            .preferredColorScheme(.dark)
        }
        .onAppear {
            if let e = entry {
                title = e.title
                content = e.content
                selectedPeople = Set(e.people.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty })
                selectedSymbols = Set(e.symbols.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty })
                wakeFeeling = e.wakeFeeling
                isLucid = e.isLucid
                isTwinFlameDream = e.isTwinFlameDream
            }
        }
    }

    private func save() {
        let peopleString = selectedPeople.sorted().joined(separator: ", ")
        let symbolsString = selectedSymbols.sorted().joined(separator: ", ")

        if let existing = entry {
            existing.title = title
            existing.content = content
            existing.people = peopleString
            existing.symbols = symbolsString
            existing.wakeFeeling = wakeFeeling
            existing.isLucid = isLucid
            existing.isTwinFlameDream = isTwinFlameDream
        } else {
            let newEntry = DreamEntry(
                title: title,
                content: content,
                people: peopleString,
                symbols: symbolsString,
                wakeFeeling: wakeFeeling,
                isLucid: isLucid,
                isTwinFlameDream: isTwinFlameDream
            )
            modelContext.insert(newEntry)
            GamificationService.shared.awardXP(amount: 20, source: "dream", framework: .apollux, skillKey: "ap_awareness", detail: "Logged dream: \(title)")
        }
        dismiss()
    }
}

// MARK: - Editor Section Container

private struct EditorSection<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppColors.lavender)
                .kerning(1.5)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Flex Wrap (Multi-select)

private struct FlexWrap: View {
    let items: [String]
    @Binding var selectedItems: Set<String>

    var body: some View {
        FlowLayoutView(items: items) { item in
            let isSelected = selectedItems.contains(item)
            Button {
                if isSelected {
                    selectedItems.remove(item)
                } else {
                    selectedItems.insert(item)
                }
            } label: {
                Text(item)
                    .font(AppFont.caption(13))
                    .foregroundStyle(isSelected ? AppColors.cream : AppColors.lavender)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(
                        isSelected
                            ? AppColors.gold.opacity(0.2)
                            : AppColors.deepViolet.opacity(0.5),
                        in: Capsule()
                    )
                    .overlay(
                        Capsule().strokeBorder(
                            isSelected ? AppColors.gold : AppColors.purple.opacity(0.3),
                            lineWidth: 1
                        )
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Flex Wrap Single Select

private struct FlexWrapSingleSelect: View {
    let items: [String]
    @Binding var selectedItem: String

    var body: some View {
        FlowLayoutView(items: items) { item in
            let isSelected = selectedItem == item
            Button {
                selectedItem = isSelected ? "" : item
            } label: {
                Text(item)
                    .font(AppFont.caption(13))
                    .foregroundStyle(isSelected ? AppColors.cream : AppColors.lavender)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(
                        isSelected
                            ? AppColors.gold.opacity(0.2)
                            : AppColors.deepViolet.opacity(0.5),
                        in: Capsule()
                    )
                    .overlay(
                        Capsule().strokeBorder(
                            isSelected ? AppColors.gold : AppColors.purple.opacity(0.3),
                            lineWidth: 1
                        )
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Dream Interpretation View (Premium)

struct DreamInterpretationView: View {
    let entry: DreamEntry
    @Environment(\.dismiss) private var dismiss
    @State private var interpretation = ""
    @State private var isLoading = true
    @State private var errorMessage: String?
    @AppStorage("mySunSign") private var mySunSign = ""
    @AppStorage("tfCurrentStage") private var tfStageID = 0

    private let stageNames = ["Recognition","Testing","Crisis","Runner & Chaser",
                               "Surrender","Illumination","Radiance","Harmonizing Union"]

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicBackground()

                // Morpheus glow
                RadialGradient(
                    colors: [Color(hex: "4A90D9").opacity(0.08), Color.clear],
                    center: .top, startRadius: 0, endRadius: 300
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // Header
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "4A90D9").opacity(0.2))
                                    .frame(width: 64, height: 64)
                                Image(systemName: "sparkles")
                                    .font(.system(size: 26))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [AppColors.gold, Color(hex: "4A90D9")],
                                            startPoint: .topLeading, endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            .accessibilityHidden(true)

                            Text("Dream Interpretation")
                                .font(AppFont.serifHeadline(22))
                                .foregroundStyle(AppColors.cream)

                            Text("Channelling Morpheus · Hypnos · Nyx")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .tracking(1.5)
                                .foregroundStyle(Color(hex: "4A90D9").opacity(0.8))
                        }
                        .padding(.top, 12)

                        // Dream summary
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entry.title.isEmpty ? "Untitled Dream" : entry.title)
                                .font(AppFont.body(15, weight: .semibold))
                                .foregroundStyle(AppColors.cream)
                            Text(entry.content.prefix(200) + (entry.content.count > 200 ? "..." : ""))
                                .font(AppFont.body(13))
                                .foregroundStyle(AppColors.lavender.opacity(0.7))
                                .lineSpacing(3)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color(hex: "4A90D9").opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)

                        // Interpretation
                        if isLoading {
                            VStack(spacing: 14) {
                                ProgressView()
                                    .tint(Color(hex: "4A90D9"))
                                    .scaleEffect(1.1)
                                Text("Morpheus is reading your dream...")
                                    .font(AppFont.body(14))
                                    .foregroundStyle(AppColors.lavender)
                            }
                            .padding(.top, 40)
                        } else if let error = errorMessage {
                            VStack(spacing: 12) {
                                Text(error)
                                    .font(AppFont.body(14))
                                    .foregroundStyle(AppColors.lavender.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                Button {
                                    HapticManager.impact(.medium)
                                    Task { await fetchInterpretation() }
                                } label: {
                                    Label("Try Again", systemImage: "arrow.clockwise")
                                        .font(AppFont.body(14, weight: .semibold))
                                        .foregroundStyle(AppColors.gold)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 24)
                        } else {
                            Text(interpretation)
                                .font(AppFont.serifTitle(16))
                                .foregroundStyle(AppColors.cream)
                                .lineSpacing(6)
                                .padding(20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "4A90D9").opacity(0.08), AppColors.deepViolet.opacity(0.6)],
                                                startPoint: .topLeading, endPoint: .bottomTrailing
                                            )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .strokeBorder(Color(hex: "4A90D9").opacity(0.25), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal, 20)
                        }

                        Spacer().frame(height: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AppColors.lavender.opacity(0.6))
                    }
                    .accessibilityLabel("Dismiss")
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
        }
        .task {
            await fetchInterpretation()
        }
    }

    private func fetchInterpretation() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let stage = stageNames[min(tfStageID, stageNames.count - 1)]

            var dreamDetails = "Dream title: \(entry.title)\n\nDream content: \(entry.content)"
            if !entry.symbols.isEmpty { dreamDetails += "\n\nSymbols present: \(entry.symbols)" }
            if !entry.people.isEmpty { dreamDetails += "\n\nWho appeared: \(entry.people)" }
            if !entry.wakeFeeling.isEmpty { dreamDetails += "\n\nFeeling on wake: \(entry.wakeFeeling)" }
            if entry.isLucid { dreamDetails += "\n\nThis was a lucid dream." }
            if entry.isTwinFlameDream { dreamDetails += "\n\nThe dreamer believes this was a twin flame dream." }
            dreamDetails += "\n\nMy sun sign: \(mySunSign.isEmpty ? "Unknown" : mySunSign)"
            dreamDetails += "\nMy twin flame stage: \(stage)"

            let userMessage = "Interpret this dream through the lens of Morpheus, Hypnos, and the twin flame journey. Be DIRECT. Tell me exactly what this dream means, which deity sent it, and what I need to DO about it.\n\n\(dreamDetails)"

            interpretation = try await ClaudeProxyService.send(
                model: "claude-haiku-4-5-20251001",
                maxTokens: 800,
                system: LoveCoachService.dreamInterpretationPrompt,
                messages: [.init(role: "user", content: userMessage)]
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Flow Layout

private struct FlowLayoutView<Item: Hashable, ItemView: View>: View {
    let items: [Item]
    @ViewBuilder let itemView: (Item) -> ItemView

    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        GeometryReader { geo in
            generateContent(in: geo)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geo: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0
        var rowHeight: CGFloat = 0

        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { item in
                itemView(item)
                    .alignmentGuide(.leading) { d in
                        if abs(width - d.width) > geo.size.width {
                            width = 0
                            height -= rowHeight + 8
                            rowHeight = 0
                        }
                        let result = width
                        if item == items.last {
                            width = 0
                        } else {
                            width -= d.width + 8
                        }
                        rowHeight = max(rowHeight, d.height)
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item == items.last {
                            height = 0
                        }
                        return result
                    }
            }
        }
        .background(
            GeometryReader { innerGeo in
                Color.clear.onAppear {
                    totalHeight = innerGeo.size.height
                }
            }
        )
    }
}
