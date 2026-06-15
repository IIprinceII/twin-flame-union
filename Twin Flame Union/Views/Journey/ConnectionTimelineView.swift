//
//  ConnectionTimelineView.swift
//  Twin Flame Union
//
//  A chronological log of significant moments in the twin flame journey.
//

import SwiftUI
import SwiftData

// MARK: - Category Definitions

private let momentCategories: [(name: String, icon: String, color: Color)] = [
    ("First Contact",   "star.fill",              Color(hex: "F0C040")),
    ("First Meeting",   "person.2.fill",           Color(hex: "8B5CF6")),
    ("Spiritual Sign",  "sparkles",                Color(hex: "CC88FF")),
    ("Separation",      "arrow.left.and.right",    Color(hex: "4A90D9")),
    ("Reconnection",    "arrow.2.circlepath",      Color(hex: "7EC8A0")),
    ("Breakthrough",    "bolt.fill",               Color(hex: "D97B4A")),
    ("Dream",           "moon.zzz.fill",           Color(hex: "5E35B1")),
    ("Milestone",       "flag.fill",               Color(hex: "E74C8B")),
    ("Healing",         "cross.case.fill",         Color(hex: "43A047")),
    ("Other",           "circle.fill",             Color(hex: "A898B8")),
]

private func categoryInfo(for name: String) -> (icon: String, color: Color) {
    momentCategories.first { $0.name == name }.map { ($0.icon, $0.color) } ?? ("circle.fill", AppColors.lavender)
}

// MARK: - View

struct ConnectionTimelineView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ConnectionMoment.date) private var moments: [ConnectionMoment]

    @State private var showAddSheet     = false
    @State private var momentToEdit: ConnectionMoment? = nil
    @State private var showPatternAnalysis = false
    @State private var showPaywall = false

    var body: some View {
        ZStack {
            CosmicBackground()

            if moments.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(moments.enumerated()), id: \.element.id) { index, moment in
                            TimelineRow(
                                moment: moment,
                                isLast: index == moments.count - 1,
                                onEdit: { momentToEdit = moment },
                                onDelete: { context.delete(moment) }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
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
        .navigationTitle("Connection Timeline")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if moments.count >= 3 {
                    Button {
                        if StoreService.shared.isPremium {
                            showPatternAnalysis = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12))
                            Text("Pattern")
                                .font(AppFont.caption(12, weight: .semibold))
                        }
                        .foregroundStyle(AppColors.gold)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showAddSheet) {
            MomentEditorSheet(moment: nil) { title, detail, category, date in
                let m = ConnectionMoment(title: title, detail: detail, category: category, date: date)
                context.insert(m)
                GamificationService.shared.awardXP(amount: 20, source: "connection", framework: .vibrationalGame, skillKey: "vg_connections", detail: "Logged connection moment")
            }
        }
        .sheet(item: $momentToEdit) { moment in
            MomentEditorSheet(moment: moment) { title, detail, category, date in
                moment.title    = title
                moment.detail   = detail
                moment.category = category
                moment.date     = date
            }
        }
        .sheet(isPresented: $showPatternAnalysis) {
            let fmt = DateFormatter()
            let _ = (fmt.dateStyle = .medium)
            let timeline = moments.map { "[\(fmt.string(from: $0.date))] \($0.category): \($0.title) — \($0.detail)" }.joined(separator: "\n")
            SacredInsightSheet(
                type: .timelinePattern,
                content: "My twin flame connection timeline (\(moments.count) events):\n\n\(timeline)"
            )
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "timeline.selection")
                .font(.system(size: 52))
                .foregroundStyle(AppColors.purple.opacity(0.5))
            Text("No moments logged yet")
                .font(AppFont.serifTitle(20))
                .foregroundStyle(AppColors.cream)
            Text("Tap + to log your first connection moment")
                .font(AppFont.body(14))
                .foregroundStyle(AppColors.lavender)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

// MARK: - Timeline Row

private struct TimelineRow: View {
    let moment: ConnectionMoment
    let isLast: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void

    private var info: (icon: String, color: Color) { categoryInfo(for: moment.category) }

    private var formattedDate: String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        return fmt.string(from: moment.date)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Timeline spine
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(info.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: info.icon)
                        .font(.system(size: 16))
                        .foregroundStyle(info.color)
                }
                if !isLast {
                    Rectangle()
                        .fill(AppColors.purple.opacity(0.3))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 4)
                }
            }
            .frame(width: 40)

            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(moment.title)
                            .font(AppFont.body(16, weight: .semibold))
                            .foregroundStyle(AppColors.cream)
                        HStack(spacing: 8) {
                            Text(moment.category)
                                .font(AppFont.caption(10, weight: .semibold))
                                .foregroundStyle(info.color)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(info.color.opacity(0.15), in: Capsule())
                            Text(formattedDate)
                                .font(AppFont.caption(12))
                                .foregroundStyle(AppColors.lavender)
                        }
                    }
                    Spacer()

                    Menu {
                        Button("Edit", systemImage: "pencil") { onEdit() }
                        Button("Delete", systemImage: "trash", role: .destructive) { onDelete() }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.lavender.opacity(0.5))
                            .padding(8)
                    }
                }

                if !moment.detail.isEmpty {
                    Text(moment.detail)
                        .font(AppFont.body(14))
                        .foregroundStyle(AppColors.lavender)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.deepViolet.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.leading, 16)
            .padding(.bottom, isLast ? 24 : 20)
        }
    }
}

// MARK: - Moment Editor Sheet

private struct MomentEditorSheet: View {
    let moment: ConnectionMoment?
    let onSave: (String, String, String, Date) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var title    = ""
    @State private var detail   = ""
    @State private var category = "Milestone"
    @State private var date     = Date()

    var body: some View {
        ZStack {
            AppColors.deepViolet.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 22) {
                    Text(moment == nil ? "Log a Moment" : "Edit Moment")
                        .font(AppFont.serifHeadline(24))
                        .foregroundStyle(AppColors.cream)
                        .padding(.top, 32)

                    field(label: "Title", placeholder: "e.g. We first met at the coffee shop") {
                        TextField("", text: $title)
                            .font(AppFont.body(16))
                            .foregroundStyle(AppColors.cream)
                    }

                    // Category picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(AppFont.caption(12))
                            .foregroundStyle(AppColors.lavender)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(momentCategories, id: \.name) { cat in
                                    Button {
                                        category = cat.name
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: cat.icon)
                                                .font(.system(size: 12))
                                            Text(cat.name)
                                                .font(AppFont.caption(12, weight: .semibold))
                                        }
                                        .foregroundStyle(category == cat.name ? .white : AppColors.lavender)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(
                                            category == cat.name ? cat.color : AppColors.deepViolet.opacity(0.6),
                                            in: Capsule()
                                        )
                                        .overlay(Capsule().strokeBorder(cat.color.opacity(category == cat.name ? 0 : 0.4), lineWidth: 1))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    // Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date")
                            .font(AppFont.caption(12))
                            .foregroundStyle(AppColors.lavender)
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .colorScheme(.dark)
                            .labelsHidden()
                            .tint(AppColors.purple)
                    }
                    .padding(.horizontal, 24)

                    field(label: "Details (optional)", placeholder: "Describe what happened, how it felt...") {
                        TextField("", text: $detail, axis: .vertical)
                            .font(AppFont.body(15))
                            .foregroundStyle(AppColors.cream)
                            .lineLimit(4...8)
                    }

                    Button {
                        let t = title.trimmingCharacters(in: .whitespaces)
                        guard !t.isEmpty else { return }
                        onSave(t, detail, category, date)
                        dismiss()
                    } label: {
                        Text("Save Moment")
                            .frame(maxWidth: .infinity)
                    }
                    .warmButtonStyle()
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .presentationDetents([.large])
        .preferredColorScheme(.dark)
        .onAppear {
            if let m = moment {
                title = m.title; detail = m.detail; category = m.category; date = m.date
            }
        }
    }

    private func field<Content: View>(label: String, placeholder: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AppFont.caption(12))
                .foregroundStyle(AppColors.lavender)
            content()
                .padding(14)
                .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(AppColors.purple.opacity(0.4), lineWidth: 1))
        }
        .padding(.horizontal, 24)
    }
}
