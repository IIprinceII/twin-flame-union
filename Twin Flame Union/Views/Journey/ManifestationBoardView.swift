//
//  ManifestationBoardView.swift
//  Twin Flame Union
//
//  Visual manifestation board for setting and tracking divine intentions.
//

import SwiftUI
import SwiftData

struct ManifestationBoardView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ManifestationItem.createdAt) private var items: [ManifestationItem]

    @State private var showAddSheet  = false
    @State private var filterMode    = FilterMode.all
    @State private var showManifested = false

    enum FilterMode: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case manifested = "Manifested"
    }

    private var filtered: [ManifestationItem] {
        switch filterMode {
        case .all:        return items
        case .active:     return items.filter { !$0.isManifested }
        case .manifested: return items.filter { $0.isManifested }
        }
    }

    let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        ZStack {
            CosmicBackground()

            VStack(spacing: 0) {

                // Filter pills
                HStack(spacing: 10) {
                    ForEach(FilterMode.allCases, id: \.self) { mode in
                        Button {
                            withAnimation(.spring(response: 0.35)) { filterMode = mode }
                        } label: {
                            Text(mode.rawValue)
                                .font(AppFont.caption(13, weight: .semibold))
                                .foregroundStyle(filterMode == mode ? AppColors.cream : AppColors.lavender)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    filterMode == mode ? AppColors.purple : AppColors.deepViolet.opacity(0.6),
                                    in: Capsule()
                                )
                                .overlay(Capsule().strokeBorder(AppColors.purple.opacity(filterMode == mode ? 0 : 0.3), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)

                if filtered.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(filtered) { item in
                                IntentionCard(item: item) {
                                    withAnimation(.spring(response: 0.4)) {
                                        item.isManifested.toggle()
                                        if item.isManifested {
                                            GamificationService.shared.awardXP(amount: 50, source: "manifestation_fulfilled", framework: .vibrationalGame, skillKey: "vg_generating", detail: "Manifestation fulfilled!")
                                        }
                                    }
                                } onDelete: {
                                    context.delete(item)
                                }
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
                    Button {
                        showAddSheet = true
                    } label: {
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
        .navigationTitle("Manifestation Board")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showAddSheet) {
            AddIntentionSheet { intention, emoji in
                let item = ManifestationItem(intention: intention, emoji: emoji)
                context.insert(item)
                GamificationService.shared.awardXP(amount: 15, source: "manifestation", framework: .vibrationalGame, skillKey: "vg_generating", detail: "Set manifestation intention")
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 52))
                .foregroundStyle(AppColors.purple.opacity(0.5))
            Text(filterMode == .all ? "Your board is empty" : "No \(filterMode.rawValue.lowercased()) intentions")
                .font(AppFont.serifTitle(20))
                .foregroundStyle(AppColors.cream)
            Text("Tap + to add your first intention")
                .font(AppFont.body(14))
                .foregroundStyle(AppColors.lavender)
            Spacer()
        }
    }
}

// MARK: - Intention Card

private struct IntentionCard: View {
    let item: ManifestationItem
    let onToggle: () -> Void
    let onDelete: () -> Void

    @State private var showConfirmDelete = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 14) {
                Text(item.emoji)
                    .font(.system(size: 38))

                Text(item.intention)
                    .font(AppFont.body(14, weight: .semibold))
                    .foregroundStyle(item.isManifested ? AppColors.gold : AppColors.cream)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: onToggle) {
                    Text(item.isManifested ? "Manifested ✓" : "Mark Manifested")
                        .font(AppFont.caption(11, weight: .semibold))
                        .foregroundStyle(item.isManifested ? AppColors.gold : AppColors.lavender)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(
                            (item.isManifested ? AppColors.gold : AppColors.lavender).opacity(0.12),
                            in: Capsule()
                        )
                        .overlay(Capsule().strokeBorder((item.isManifested ? AppColors.gold : AppColors.lavender).opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                item.isManifested
                    ? LinearGradient(colors: [AppColors.gold.opacity(0.15), AppColors.deepViolet.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                    : LinearGradient(colors: [AppColors.purple.opacity(0.12), AppColors.deepViolet.opacity(0.7)], startPoint: .top, endPoint: .bottom),
                in: RoundedRectangle(cornerRadius: 20)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        item.isManifested ? AppColors.gold.opacity(0.4) : AppColors.purple.opacity(0.25),
                        lineWidth: item.isManifested ? 1.5 : 1
                    )
            )

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(AppColors.lavender.opacity(0.4))
                    .background(AppColors.deepViolet, in: Circle())
            }
            .buttonStyle(.plain)
            .offset(x: 6, y: -6)
        }
    }
}

// MARK: - Add Intention Sheet

private struct AddIntentionSheet: View {
    let onAdd: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var intention = ""
    @State private var emoji     = "✨"

    private let emojiOptions = ["✨", "💜", "🔥", "💫", "🌙", "🌹", "💎", "🙏", "🌟", "💝", "🌺", "🦋", "🕊️", "🌈", "💍", "❤️", "🌸", "⚡"]

    var body: some View {
        ZStack {
            AppColors.deepViolet.ignoresSafeArea()

            VStack(spacing: 24) {
                Text("New Intention")
                    .font(AppFont.serifHeadline(24))
                    .foregroundStyle(AppColors.cream)
                    .padding(.top, 32)

                // Emoji picker
                VStack(alignment: .leading, spacing: 10) {
                    Text("Choose a Symbol")
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColors.lavender)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(emojiOptions, id: \.self) { e in
                                Button {
                                    emoji = e
                                } label: {
                                    Text(e)
                                        .font(.system(size: 28))
                                        .padding(10)
                                        .background(
                                            emoji == e ? AppColors.purple.opacity(0.35) : AppColors.deepViolet.opacity(0.6),
                                            in: RoundedRectangle(cornerRadius: 12)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .strokeBorder(emoji == e ? AppColors.purple : Color.clear, lineWidth: 1.5)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }
                .padding(.horizontal, 24)

                // Intention text
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Intention")
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColors.lavender)
                    TextField("e.g. My twin flame and I are in harmonious union", text: $intention, axis: .vertical)
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.cream)
                        .lineLimit(3...5)
                        .padding(14)
                        .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(AppColors.purple.opacity(0.4), lineWidth: 1))
                }
                .padding(.horizontal, 24)

                Spacer()

                Button {
                    let text = intention.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { return }
                    onAdd(text, emoji)
                    dismiss()
                } label: {
                    Text("Add to Board")
                        .frame(maxWidth: .infinity)
                }
                .warmButtonStyle()
                .disabled(intention.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .presentationDetents([.medium, .large])
        .preferredColorScheme(.dark)
    }
}
