//
//  JournalView.swift
//  Twin Flame Union
//
//  Soul Journal with search and HealthKit integration.
//

import SwiftUI
import SwiftData

// MARK: - Journal Mood

enum JournalMood: String, CaseIterable {
    case hopeful      = "Hopeful"
    case peaceful     = "Peaceful"
    case longing      = "Longing"
    case healing      = "Healing"
    case grateful     = "Grateful"
    case confused     = "Confused"
    case surrendering = "Surrendering"

    var emoji: String {
        switch self {
        case .hopeful:      return "🌟"
        case .peaceful:     return "🕊️"
        case .longing:      return "💜"
        case .healing:      return "🌿"
        case .grateful:     return "✨"
        case .confused:     return "🌊"
        case .surrendering: return "🦋"
        }
    }

    var color: Color {
        switch self {
        case .hopeful:      return Color.white
        case .peaceful:     return Color(hex: "4A90D9")
        case .longing:      return Color(hex: "9B59B6")
        case .healing:      return Color(hex: "4CAF82")
        case .grateful:     return Color(hex: "F39C12")
        case .confused:     return Color(hex: "2E86AB")
        case .surrendering: return Color(hex: "E91E8C")
        }
    }
}

// MARK: - Journal View

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.createdAt, order: .reverse) private var entries: [JournalEntry]

    @State private var showEditor = false
    @State private var selectedEntry: JournalEntry?
    @State private var searchText: String = ""

    private var filteredEntries: [JournalEntry] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return entries
        }
        let query = searchText.lowercased()
        return entries.filter {
            $0.title.lowercased().contains(query) ||
            $0.content.lowercased().contains(query)
        }
    }

    var body: some View {
        ZStack {
            CosmicBackground()

            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $searchText)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                Group {
                    if entries.isEmpty {
                        EmptyJournalState {
                            selectedEntry = nil
                            showEditor = true
                        }
                    } else if filteredEntries.isEmpty {
                        noResultsView
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 14) {
                                ForEach(filteredEntries) { entry in
                                    JournalEntryRow(entry: entry)
                                        .onTapGesture {
                                            selectedEntry = entry
                                            showEditor = true
                                        }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                        }
                    }
                }
            }

            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        selectedEntry = nil
                        showEditor = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(AppGradients.warm, in: Circle())
                            .shadow(color: AppColors.coral.opacity(0.5), radius: 12, y: 4)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 28)
                }
            }
        }
        .navigationTitle("Soul Journal")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
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
    }

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 44))
                .foregroundStyle(AppColors.lavender.opacity(0.4))
            Text("No results for \"\(searchText)\"")
                .font(AppFont.serifTitle(18))
                .foregroundStyle(AppColors.cream)
            Text("Try a different search term.")
                .font(AppFont.body(14))
                .foregroundStyle(AppColors.lavender)
            Spacer()
        }
    }

    private func save(title: String, content: String, mood: String) {
        if let entry = selectedEntry {
            entry.title = title
            entry.content = content
            entry.mood = mood
            entry.updatedAt = Date()
        } else {
            let entry = JournalEntry(title: title, content: content, mood: mood)
            modelContext.insert(entry)
            GamificationService.shared.awardXP(amount: 25, source: "journal", framework: .apollux, skillKey: "ap_emotional_fuel", detail: "Wrote journal entry")
        }
    }
}

// MARK: - Search Bar

private struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15))
                .foregroundStyle(AppColors.lavender)

            TextField("Search entries...", text: $text)
                .font(AppFont.body(15))
                .foregroundStyle(AppColors.cream)
                .tint(AppColors.gold)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(AppColors.lavender.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Entry Row

private struct JournalEntryRow: View {
    let entry: JournalEntry

    private var mood: JournalMood {
        JournalMood(rawValue: entry.mood) ?? .hopeful
    }

    private var preview: String {
        let text = entry.content.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? "No content" : String(text.prefix(100))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(mood.emoji)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.title.isEmpty ? "Untitled Entry" : entry.title)
                        .font(AppFont.body(16, weight: .semibold))
                        .foregroundStyle(AppColors.cream)
                        .lineLimit(1)

                    Text(entry.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColors.lavender)
                }

                Spacer()

                Text(mood.rawValue)
                    .font(AppFont.caption(11, weight: .semibold))
                    .foregroundStyle(mood.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(mood.color.opacity(0.15), in: Capsule())
            }

            Text(preview)
                .font(AppFont.body(14))
                .foregroundStyle(AppColors.lavender)
                .lineLimit(2)
                .lineSpacing(3)
        }
        .padding(16)
        .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(AppColors.purple.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Empty State

private struct EmptyJournalState: View {
    let onNew: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                Text("📖")
                    .font(.system(size: 56))

                VStack(spacing: 8) {
                    Text("Your Soul Journal")
                        .font(AppFont.serifHeadline(24))
                        .foregroundStyle(AppColors.cream)

                    Text("Write your thoughts, feelings,\nand reflections on your journey.")
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.lavender)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }

            Button(action: onNew) {
                Text("Write Your First Entry")
                    .warmButtonStyle()
            }

            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Journal Editor View

struct JournalEditorView: View {
    let entry: JournalEntry?
    let onSave: (String, String, String) -> Void
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var content: String
    @State private var selectedMood: JournalMood
    @State private var showDeleteConfirm = false
    @State private var logMindfulSession = false
    @FocusState private var contentFocused: Bool

    init(
        entry: JournalEntry?,
        onSave: @escaping (String, String, String) -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.entry = entry
        self.onSave = onSave
        self.onDelete = onDelete
        _title        = State(initialValue: entry?.title ?? "")
        _content      = State(initialValue: entry?.content ?? "")
        _selectedMood = State(initialValue: JournalMood(rawValue: entry?.mood ?? "") ?? .hopeful)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppGradients.cosmic.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {

                        // Mood picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text("How are you feeling?")
                                .font(AppFont.body(13, weight: .semibold))
                                .foregroundStyle(AppColors.lavender)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(JournalMood.allCases, id: \.self) { mood in
                                        MoodChip(mood: mood, isSelected: selectedMood == mood) {
                                            selectedMood = mood
                                        }
                                    }
                                }
                            }
                        }

                        // Title
                        TextField("Entry title (optional)", text: $title)
                            .font(AppFont.serifTitle(20))
                            .foregroundStyle(AppColors.cream)
                            .tint(AppColors.gold)
                            .padding(14)
                            .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
                            )

                        // Content
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your thoughts")
                                .font(AppFont.body(13, weight: .semibold))
                                .foregroundStyle(AppColors.lavender)

                            TextEditor(text: $content)
                                .font(AppFont.body(15))
                                .foregroundStyle(AppColors.cream)
                                .tint(AppColors.gold)
                                .scrollContentBackground(.hidden)
                                .background(AppColors.deepViolet.opacity(0.6))
                                .frame(minHeight: 260)
                                .padding(14)
                                .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
                                )
                                .focused($contentFocused)
                        }

                        // HealthKit mindful session toggle
                        if HealthService.shared.isAuthorized {
                            Toggle(isOn: $logMindfulSession) {
                                HStack(spacing: 10) {
                                    Image(systemName: "heart.text.square.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color(hex: "FF2D55"))
                                    Text("Log as mindful session")
                                        .font(AppFont.body(15))
                                        .foregroundStyle(AppColors.cream)
                                }
                            }
                            .tint(AppColors.gold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
                            )
                        }

                        // Delete button
                        if entry != nil {
                            Button(role: .destructive) {
                                showDeleteConfirm = true
                            } label: {
                                Label("Delete Entry", systemImage: "trash")
                                    .font(AppFont.body(14))
                                    .foregroundStyle(AppColors.coral.opacity(0.8))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(AppColors.coral.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                            }
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(entry == nil ? "New Entry" : "Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColors.lavender)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, content, selectedMood.rawValue)
                        if logMindfulSession {
                            Task {
                                try? await HealthService.shared.logMindfulSession(duration: 300)
                            }
                        }
                        dismiss()
                    }
                    .font(AppFont.body(15, weight: .semibold))
                    .foregroundStyle(content.isEmpty ? AppColors.lavender.opacity(0.4) : AppColors.gold)
                    .disabled(content.isEmpty)
                }
            }
            .preferredColorScheme(.dark)
            .confirmationDialog("Delete this entry?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    onDelete()
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            }
            .onAppear {
                contentFocused = (entry == nil)
                Task {
                    if !HealthService.shared.isAuthorized {
                        try? await HealthService.shared.requestAuthorization()
                    }
                }
            }
        }
    }
}

// MARK: - Mood Chip

struct MoodChip: View {
    let mood: JournalMood
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(mood.emoji)
                    .font(.body)
                Text(mood.rawValue)
                    .font(AppFont.body(13, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .white : AppColors.lavender)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isSelected ? mood.color.opacity(0.8) : AppColors.deepViolet.opacity(0.6),
                in: Capsule()
            )
            .overlay(Capsule().strokeBorder(isSelected ? mood.color : AppColors.purple.opacity(0.3), lineWidth: 1))
        }
    }
}
