//
//  DivineCouncilView.swift
//  Twin Flame Union
//
//  Honors the Deity governing today (and the Days ahead). Replaces the old
//  planetary-transit screen — the Gods and Goddesses, not the stars.
//

import SwiftUI

struct DivineCouncilView: View {
    private let today = DivinePantheon.today
    private var upcoming: [Deity] { (1...4).map { DivinePantheon.deity(dayOffset: $0) } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("The Deity governing today")
                    .font(.caption)
                    .foregroundStyle(AppColors.lavender)
                    .padding(.horizontal, 20)

                todayCard

                Text("The Days ahead")
                    .font(AppFont.serifTitle(20))
                    .foregroundStyle(AppColors.gold)
                    .padding(.horizontal, 20)

                ForEach(Array(upcoming.enumerated()), id: \.offset) { _, deity in
                    upcomingRow(deity)
                }
            }
            .padding(.vertical, 20)
        }
        .background(AppColors.deepViolet.ignoresSafeArea())
        .navigationTitle("Divine Council Today")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var todayCard: some View {
        VStack(spacing: 14) {
            Image(systemName: today.symbol)
                .font(.system(size: 44))
                .foregroundStyle(today.color)
                .accessibilityHidden(true)
            Text(today.name)
                .font(AppFont.serifHeadline(30))
                .foregroundStyle(AppColors.cream)
            Text(today.culture)
                .font(.caption).bold()
                .foregroundStyle(AppColors.lavender)
            Text(today.domain)
                .font(.subheadline)
                .foregroundStyle(AppColors.cream.opacity(0.85))
                .multilineTextAlignment(.center)
            Text(today.invocation)
                .font(.callout.italic())
                .foregroundStyle(AppColors.gold)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(today.color.opacity(0.14))
        .cornerRadius(20)
        .padding(.horizontal, 20)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Today: \(today.name), \(today.culture). \(today.domain). \(today.invocation)")
    }

    private func upcomingRow(_ deity: Deity) -> some View {
        HStack(spacing: 14) {
            Image(systemName: deity.symbol)
                .font(.system(size: 20))
                .foregroundStyle(deity.color)
                .frame(width: 36)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(deity.name).font(.headline).foregroundStyle(AppColors.cream)
                Text(deity.domain).font(.caption).foregroundStyle(AppColors.lavender)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(14)
        .background(AppColors.purple.opacity(0.12))
        .cornerRadius(14)
        .padding(.horizontal, 20)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(deity.name), \(deity.culture). \(deity.domain)")
    }
}
