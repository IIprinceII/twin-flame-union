//
//  SoulJournalView.swift
//  Twin Flame Union
//
//  Soul Journal — write and revisit your twin flame journey.
//

import SwiftUI
import SwiftData

// JournalMood is defined in JournalView.swift

// MARK: - Soul Journal View

struct SoulJournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.createdAt, order: .reverse) private var entries: [JournalEntry]

    @State private var showEditor = false
    @State private var selectedEntry: JournalEntry?

    var body: some View {
        ZStack {
            CosmicBackground()

            Group {
                if entries.isEmpty {
                    EmptyJournalView {
                        showEditor = true
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 14) {
                            ForEach(entries) { entry in
                                JournalEntryRow(entry: entry)
                                    .onTapGesture {
                                        selectedEntry = entry
                                        showEditor = true
                                    }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                    }
                }
            }

            // Floating new entry button
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
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        #endif
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

    private func save(title: String, content: String, mood: String) {
        if let entry = selectedEntry {
            entry.title = title
            entry.content = content
            entry.mood = mood
            entry.updatedAt = Date()
        } else {
            let entry = JournalEntry(title: title, content: content, mood: mood)
            modelContext.insert(entry)
        }
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

private struct EmptyJournalView: View {
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

// JournalEditorView and MoodChip are defined in JournalView.swift
