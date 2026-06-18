//
//  GuidingDeityPickerView.swift
//  Twin Flame Union
//
//  A reverent browser of the full Divine Council. The soul chooses the God or
//  Goddess who walks with them; the chosen name is written to the bound storage.
//

import SwiftUI

struct GuidingDeityPickerView: View {
    /// The @AppStorage-backed Deity name this picker writes to (mine or the twin's).
    @Binding var selectedName: String
    let title: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    ForEach(DivinePantheon.grouped(), id: \.culture) { group in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(group.culture)
                                .font(AppFont.serifTitle(20))
                                .foregroundStyle(AppColors.gold)
                                .padding(.horizontal, 16)

                            ForEach(group.deities, id: \.name) { deity in
                                Button {
                                    selectedName = deity.name
                                    HapticManager.impact(.light)
                                    dismiss()
                                } label: {
                                    deityRow(deity)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            .background(AppColors.deepViolet.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.foregroundStyle(AppColors.lavender)
                }
            }
        }
    }

    private func deityRow(_ deity: Deity) -> some View {
        let isChosen = selectedName == deity.name
        return HStack(spacing: 14) {
            Image(systemName: deity.symbol)
                .font(.system(size: 22))
                .foregroundStyle(deity.color)
                .frame(width: 40)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(deity.name)
                    .font(.headline)
                    .foregroundStyle(AppColors.cream)
                Text(deity.domain)
                    .font(.caption)
                    .foregroundStyle(AppColors.lavender)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            if isChosen {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(AppColors.gold)
            }
        }
        .padding(14)
        .background(AppColors.purple.opacity(0.12))
        .cornerRadius(14)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(deity.name), \(deity.culture). \(deity.domain)\(isChosen ? ". Currently chosen" : "")")
    }
}
