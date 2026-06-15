//
//  PrayerJournalView.swift
//  Twin Flame Union
//
//  Prayer & petition journal — log prayers and track when they are answered.
//

import SwiftUI
import SwiftData

struct PrayerJournalView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \PrayerEntry.createdAt, order: .reverse) private var entries: [PrayerEntry]

    @State private var showAddSheet  = false
    @State private var entryToEdit: PrayerEntry? = nil
    @State private var filterAnswered = false

    private var filtered: [PrayerEntry] {
        filterAnswered ? entries.filter { $0.isAnswered } : entries
    }

    var body: some View {
        ZStack {
            CosmicBackground()

            VStack(spacing: 0) {
                // Filter toggle
                HStack(spacing: 12) {
                    filterPill("All Prayers",   isSelected: !filterAnswered) { filterAnswered = false }
                    filterPill("Answered ✓",    isSelected:  filterAnswered) { filterAnswered = true }
                    Spacer()
                    Text("\(entries.filter { $0.isAnswered }.count)/\(entries.count) answered")
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColors.lavender.opacity(0.6))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)

                if filtered.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(filtered) { entry in
                                PrayerCard(
                                    entry: entry,
                                    onMarkAnswered: {
                                        withAnimation(.spring(response: 0.4)) {
                                            entry.isAnswered = true
                                            entry.answeredAt = Date()
                                        }
                                        GamificationService.shared.awardXP(amount: 50, source: "prayer_answered", framework: .vibrationalGame, skillKey: "vg_generating", detail: "Prayer answered")
                                    },
                                    onEdit: { entryToEdit = entry },
                                    onDelete: { context.delete(entry) }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 100)
                    }
                }
            }

            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button { showAddSheet = true } label: {
                        ZStack {
                            Circle()
                                .fill(AppGradients.warm)
                                .frame(width: 60, height: 60)
                                .shadow(color: AppColors.purple.opacity(0.5), radius: 16, y: 8)
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.trailing, 28)
                    .padding(.bottom, 16)
                }
            }
        }
        .navigationTitle("Prayer Journal")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showAddSheet) {
            PrayerEditorSheet(entry: nil) { petition, detail in
                context.insert(PrayerEntry(petition: petition, detail: detail))
                GamificationService.shared.awardXP(amount: 20, source: "prayer", framework: .vibrationalGame, skillKey: "vg_language", detail: "Wrote prayer")
            }
        }
        .sheet(item: $entryToEdit) { entry in
            PrayerEditorSheet(entry: entry) { petition, detail in
                entry.petition = petition
                entry.detail   = detail
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "hands.sparkles.fill")
                .font(.system(size: 52))
                .foregroundStyle(AppColors.purple.opacity(0.5))
            Text("No prayers logged yet")
                .font(AppFont.serifTitle(20))
                .foregroundStyle(AppColors.cream)
            Text("Tap + to log your first prayer or petition")
                .font(AppFont.body(14))
                .foregroundStyle(AppColors.lavender)
            Spacer()
        }
    }

    private func filterPill(_ label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(AppFont.caption(12, weight: .semibold))
                .foregroundStyle(isSelected ? AppColors.cream : AppColors.lavender)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    isSelected ? AppColors.purple : AppColors.deepViolet.opacity(0.6),
                    in: Capsule()
                )
                .overlay(Capsule().strokeBorder(AppColors.purple.opacity(isSelected ? 0 : 0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Prayer Card

private struct PrayerCard: View {
    let entry: PrayerEntry
    let onMarkAnswered: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var showAnswerSheet = false

    private var dateLabel: String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        return fmt.string(from: entry.createdAt)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.petition)
                        .font(AppFont.body(16, weight: .semibold))
                        .foregroundStyle(entry.isAnswered ? AppColors.gold : AppColors.cream)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 8) {
                        if entry.isAnswered {
                            Label("Answered", systemImage: "checkmark.circle.fill")
                                .font(AppFont.caption(11, weight: .semibold))
                                .foregroundStyle(AppColors.gold)
                        } else {
                            Text("Believing")
                                .font(AppFont.caption(11))
                                .foregroundStyle(AppColors.lavender.opacity(0.6))
                        }
                        Text("·")
                            .foregroundStyle(AppColors.lavender.opacity(0.3))
                        Text(dateLabel)
                            .font(AppFont.caption(11))
                            .foregroundStyle(AppColors.lavender.opacity(0.5))
                    }
                }
                Spacer()
                Menu {
                    if !entry.isAnswered {
                        Button("Mark Answered", systemImage: "checkmark.circle") { showAnswerSheet = true }
                    }
                    Button("Edit", systemImage: "pencil") { onEdit() }
                    Button("Delete", systemImage: "trash", role: .destructive) { onDelete() }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.lavender.opacity(0.4))
                        .padding(8)
                }
            }

            if !entry.detail.isEmpty {
                Text(entry.detail)
                    .font(AppFont.body(13))
                    .foregroundStyle(AppColors.lavender)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if entry.isAnswered, !entry.answeredNote.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(AppColors.gold)
                        .padding(.top, 3)
                    Text("Answer: \(entry.answeredNote)")
                        .font(AppFont.body(13))
                        .foregroundStyle(AppColors.gold.opacity(0.85))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(10)
                .background(AppColors.gold.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(18)
        .background(
            entry.isAnswered
                ? LinearGradient(colors: [AppColors.gold.opacity(0.1), AppColors.deepViolet.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                : LinearGradient(colors: [AppColors.deepViolet.opacity(0.7), AppColors.deepViolet.opacity(0.7)], startPoint: .top, endPoint: .bottom),
            in: RoundedRectangle(cornerRadius: 18)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(entry.isAnswered ? AppColors.gold.opacity(0.3) : AppColors.purple.opacity(0.2), lineWidth: 1)
        )
        .sheet(isPresented: $showAnswerSheet) {
            AnswerSheet { note in
                entry.answeredNote = note
                entry.isAnswered   = true
                entry.answeredAt   = Date()
            }
        }
    }
}

// MARK: - Answer Sheet

private struct AnswerSheet: View {
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var note = ""

    var body: some View {
        ZStack {
            AppColors.deepViolet.ignoresSafeArea()
            VStack(spacing: 22) {
                Image(systemName: "star.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(AppColors.gold)
                    .padding(.top, 36)
                Text("God Answered!")
                    .font(AppFont.serifHeadline(26))
                    .foregroundStyle(AppColors.cream)
                Text("How was this prayer answered? (optional)")
                    .font(AppFont.body(14))
                    .foregroundStyle(AppColors.lavender)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                TextField("Describe how God moved...", text: $note, axis: .vertical)
                    .font(AppFont.body(15))
                    .foregroundStyle(AppColors.cream)
                    .lineLimit(4...8)
                    .padding(14)
                    .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(AppColors.gold.opacity(0.3), lineWidth: 1))
                    .padding(.horizontal, 24)
                Spacer()
                Button {
                    onSave(note)
                    dismiss()
                } label: {
                    Text("Record This Blessing")
                        .frame(maxWidth: .infinity)
                }
                .warmButtonStyle()
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            }
        }
        .presentationDetents([.medium])
        .preferredColorScheme(.dark)
    }
}

// MARK: - Prayer Editor Sheet

private struct PrayerEditorSheet: View {
    let entry: PrayerEntry?
    let onSave: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var petition = ""
    @State private var detail   = ""

    var body: some View {
        ZStack {
            AppColors.deepViolet.ignoresSafeArea()
            VStack(spacing: 22) {
                Text(entry == nil ? "New Prayer" : "Edit Prayer")
                    .font(AppFont.serifHeadline(24))
                    .foregroundStyle(AppColors.cream)
                    .padding(.top, 32)

                VStack(alignment: .leading, spacing: 8) {
                    Text("What are you praying for?")
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColors.lavender)
                    TextField("e.g. Reunion with my twin flame in God's perfect timing", text: $petition, axis: .vertical)
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.cream)
                        .lineLimit(2...4)
                        .padding(14)
                        .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(AppColors.purple.opacity(0.4), lineWidth: 1))
                }
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Prayer details (optional)")
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColors.lavender)
                    TextField("Share more of your heart...", text: $detail, axis: .vertical)
                        .font(AppFont.body(14))
                        .foregroundStyle(AppColors.cream)
                        .lineLimit(4...8)
                        .padding(14)
                        .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(AppColors.purple.opacity(0.4), lineWidth: 1))
                }
                .padding(.horizontal, 24)

                Spacer()
                Button {
                    let p = petition.trimmingCharacters(in: .whitespaces)
                    guard !p.isEmpty else { return }
                    onSave(p, detail)
                    dismiss()
                } label: {
                    Text("Log Prayer")
                        .frame(maxWidth: .infinity)
                }
                .warmButtonStyle()
                .disabled(petition.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            }
        }
        .presentationDetents([.large])
        .preferredColorScheme(.dark)
        .onAppear {
            if let e = entry { petition = e.petition; detail = e.detail }
        }
    }
}
