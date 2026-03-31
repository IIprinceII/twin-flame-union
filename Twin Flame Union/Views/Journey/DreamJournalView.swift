//
//  DreamJournalView.swift
//  Twin Flame Union
//
//  Dream journal — list and editor for nightly dream entries.
//

import SwiftUI
import SwiftData

// MARK: - Dream Journal List View

struct DreamJournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DreamEntry.createdAt, order: .reverse) private var entries: [DreamEntry]

    @State private var showEditor = false
    @State private var entryToEdit: DreamEntry? = nil

    var body: some View {
        ZStack {
            CosmicBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // Header
                    VStack(spacing: 8) {
                        Text("Dream Journal")
                            .font(AppFont.serifHeadline(30))
                            .foregroundStyle(AppColors.cream)
                        Text("Your nightly messages from the cosmos")
                            .font(AppFont.body(14))
                            .foregroundStyle(AppColors.lavender)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 24)

                    if entries.isEmpty {
                        // Empty state
                        VStack(spacing: 16) {
                            Image(systemName: "moon.stars.fill")
                                .font(.system(size: 52))
                                .foregroundStyle(AppColors.gold.opacity(0.7))
                                .padding(.top, 48)

                            Text("No dreams recorded yet")
                                .font(AppFont.serifTitle(20))
                                .foregroundStyle(AppColors.cream)

                            Text("Your soul speaks through dreams.\nBegin capturing them.")
                                .font(AppFont.body(14))
                                .foregroundStyle(AppColors.lavender)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                    } else {
                        // Dream entry rows
                        LazyVStack(spacing: 12) {
                            ForEach(entries) { entry in
                                DreamEntryRow(entry: entry) {
                                    entryToEdit = entry
                                    showEditor = true
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        modelContext.delete(entry)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .navigationTitle("Dream Journal")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    entryToEdit = nil
                    showEditor = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppColors.gold)
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            DreamEntryEditor(entry: entryToEdit)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Dream Entry Row

private struct DreamEntryRow: View {
    let entry: DreamEntry
    let onTap: () -> Void

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }()

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {

                // Date + title row
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(Self.dateFormatter.string(from: entry.createdAt))
                        .font(AppFont.caption(12, weight: .semibold))
                        .foregroundStyle(AppColors.lavender)
                        .frame(minWidth: 36, alignment: .leading)

                    Text(entry.title.isEmpty ? "Untitled Dream" : entry.title)
                        .font(AppFont.body(16, weight: .semibold))
                        .foregroundStyle(AppColors.cream)
                        .lineLimit(1)

                    Spacer()
                }

                // Content preview
                if !entry.content.isEmpty {
                    let preview = String(entry.content.prefix(60))
                    Text(entry.content.count > 60 ? preview + "…" : preview)
                        .font(AppFont.body(13))
                        .foregroundStyle(AppColors.lavender)
                        .lineLimit(2)
                        .lineSpacing(3)
                }

                // Badges row
                HStack(spacing: 8) {
                    if entry.isLucid {
                        DreamBadge(label: "◇ Lucid", backgroundColor: AppColors.purple.opacity(0.25), borderColor: AppColors.purple.opacity(0.6), textColor: AppColors.lavender)
                    }
                    if entry.isTwinFlameDream {
                        DreamBadge(label: "🔥 TF Dream", backgroundColor: AppColors.gold.opacity(0.15), borderColor: AppColors.gold.opacity(0.5), textColor: AppColors.gold)
                    }
                    if !entry.wakeFeeling.isEmpty {
                        DreamBadge(label: entry.wakeFeeling, backgroundColor: AppColors.deepViolet.opacity(0.5), borderColor: AppColors.purple.opacity(0.3), textColor: AppColors.cream)
                    }
                    Spacer()
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
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
                        Button(action: save) {
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
