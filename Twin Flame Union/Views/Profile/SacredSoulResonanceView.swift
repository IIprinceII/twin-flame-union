//
//  SacredSoulResonanceView.swift
//  Twin Flame Union
//
//  The sacred resonance between the soul's Guiding Deity and their twin flame's —
//  channeled through the Gods and Goddesses, never through star signs.
//

import SwiftUI

struct SacredSoulResonanceView: View {
    @AppStorage("myGuidingDeity")      private var myGuidingDeity      = ""
    @AppStorage("partnerGuidingDeity") private var partnerGuidingDeity = ""

    private var pair: (Deity, Deity)? {
        guard let mine = DivinePantheon.deity(named: myGuidingDeity),
              let theirs = DivinePantheon.deity(named: partnerGuidingDeity) else { return nil }
        return (mine, theirs)
    }

    var body: some View {
        ScrollView {
            if let (mine, theirs) = pair {
                let reading = DeityResonanceService.resonance(mine: mine, theirs: theirs)
                VStack(alignment: .leading, spacing: 22) {
                    HStack(spacing: 16) {
                        deityBadge(mine, label: "You")
                        Image(systemName: "infinity").foregroundStyle(AppColors.gold).accessibilityHidden(true)
                        deityBadge(theirs, label: "Your Twin Flame")
                    }
                    .frame(maxWidth: .infinity)

                    Text(reading.narrative)
                        .font(.body)
                        .foregroundStyle(AppColors.cream)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 20)

                    ForEach(reading.themes) { theme in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(theme.title).font(.headline).foregroundStyle(AppColors.gold)
                            Text(theme.body).font(.subheadline).foregroundStyle(AppColors.cream.opacity(0.85))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.purple.opacity(0.12))
                        .cornerRadius(14)
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 20)
            } else {
                emptyState
            }
        }
        .background(AppColors.deepViolet.ignoresSafeArea())
        .navigationTitle("Soul Resonance")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private func deityBadge(_ deity: Deity, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: deity.symbol).font(.system(size: 30)).foregroundStyle(deity.color)
                .accessibilityHidden(true)
            Text(deity.name).font(.headline).foregroundStyle(AppColors.cream)
            Text(label).font(.caption2).foregroundStyle(AppColors.lavender)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(deity.name)")
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "sparkles").font(.system(size: 40)).foregroundStyle(AppColors.gold)
                .accessibilityHidden(true)
            Text("Choose your Guiding Deities first")
                .font(AppFont.serifTitle(22)).foregroundStyle(AppColors.cream)
            Text("In Profile, choose the God or Goddess who walks with you — and with your twin flame — to reveal your Sacred Resonance.")
                .font(.subheadline).foregroundStyle(AppColors.lavender)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }
}
