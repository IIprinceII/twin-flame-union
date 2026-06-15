//
//  ShareableAffirmationsView.swift
//  Twin Flame Union
//
//  Shareable affirmation quote cards with ImageRenderer export.
//

import SwiftUI

private struct ShareAffirmation: Identifiable {
    let id = UUID()
    let text: String
    let category: String
    let color: Color
}

private let allAffirmations: [ShareAffirmation] = [
    .init(text: "My twin flame and I are walking toward each other right now.", category: "Union", color: Color(hex: "8B5CF6")),
    .init(text: "God ordained this union. What He joins, no force can separate.", category: "Faith", color: Color(hex: "4A90D9")),
    .init(text: "I am protected by Archangel Michael. Fear has no place here.", category: "Protection", color: Color(hex: "1E88E5")),
    .init(text: "Return to sender — all that is not mine leaves now.", category: "Protection", color: Color(hex: "5E35B1")),
    .init(text: "My crown is activated. I receive divine truth clearly.", category: "Spiritual", color: Color(hex: "CC88FF")),
    .init(text: "The telepathy between us is real. Our hearts speak without words.", category: "Connection", color: Color(hex: "E74C8B")),
    .init(text: "I surrender deeply and God moves powerfully on my behalf.", category: "Surrender", color: Color(hex: "D97B4A")),
    .init(text: "I am free. I am healed. I am whole in my higher self.", category: "Healing", color: Color(hex: "43A047")),
    .init(text: "I shift into the frequency of reunion and stay there.", category: "Union", color: Color(hex: "8B5CF6")),
    .init(text: "My prayer is heard. Heaven moves with me right now.", category: "Faith", color: Color(hex: "F0C040")),
    .init(text: "I rebuke every lie that says union is not mine. It is done.", category: "Faith", color: Color(hex: "4A90D9")),
    .init(text: "I am a magnet for divine love. My twin flame feels me now.", category: "Connection", color: Color(hex: "E74C8B")),
    .init(text: "Every trigger is a teacher. I welcome the growth this love brings.", category: "Healing", color: Color(hex: "7EC8A0")),
    .init(text: "My healing is my reunion. As I become whole, love returns.", category: "Healing", color: Color(hex: "43A047")),
    .init(text: "I vibrate at the frequency of unconditional love.", category: "Frequency", color: Color(hex: "CC88FF")),
    .init(text: "I trust divine timing completely. The universe is never late.", category: "Surrender", color: Color(hex: "D97B4A")),
    .init(text: "Our bond is eternal and no force in heaven or earth breaks it.", category: "Union", color: Color(hex: "8B5CF6")),
    .init(text: "I am worthy of the love I seek. I receive it now.", category: "Worthiness", color: Color(hex: "E74C8B")),
    .init(text: "I face my shadow with courage. The gold is buried there.", category: "Healing", color: Color(hex: "5E35B1")),
    .init(text: "I am the alchemist of my own story. Pain becomes wisdom.", category: "Healing", color: Color(hex: "F0C040")),
    .init(text: "My inner child is safe, loved, and whole.", category: "Healing", color: Color(hex: "FF7043")),
    .init(text: "Separation is sacred. I use this time to become who love requires.", category: "Growth", color: Color(hex: "4A90D9")),
    .init(text: "I release the chase. What is mine returns freely.", category: "Surrender", color: Color(hex: "D97B4A")),
    .init(text: "My twin flame's higher self hears my heart right now.", category: "Connection", color: Color(hex: "E74C8B")),
    .init(text: "I am the divine feminine/masculine in full bloom.", category: "Spiritual", color: Color(hex: "CC88FF")),
    .init(text: "528 Hz. I am tuned to the love frequency.", category: "Frequency", color: Color(hex: "43A047")),
    .init(text: "GOD is the author of this love story. I trust His pen.", category: "Faith", color: Color(hex: "F0C040")),
    .init(text: "I honor the sacred contract between our souls.", category: "Spiritual", color: Color(hex: "8B5CF6")),
]

private let categories = ["All"] + Array(Set(allAffirmations.map { $0.category })).sorted()

struct ShareableAffirmationsView: View {
    @State private var selectedCategory = "All"
    @State private var selectedAffirmation: ShareAffirmation? = nil
    @State private var showShareSheet = false
    @State private var renderedImage: UIImage? = nil

    private var filtered: [ShareAffirmation] {
        selectedCategory == "All" ? allAffirmations : allAffirmations.filter { $0.category == selectedCategory }
    }

    let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        ZStack {
            CosmicBackground()

            VStack(spacing: 0) {
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories, id: \.self) { cat in
                            Button {
                                withAnimation(.spring(response: 0.35)) { selectedCategory = cat }
                            } label: {
                                Text(cat)
                                    .font(AppFont.caption(12, weight: .semibold))
                                    .foregroundStyle(selectedCategory == cat ? AppColors.cream : AppColors.lavender)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedCategory == cat ? AppColors.purple : AppColors.deepViolet.opacity(0.6),
                                        in: Capsule()
                                    )
                                    .overlay(Capsule().strokeBorder(AppColors.purple.opacity(selectedCategory == cat ? 0 : 0.3), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.vertical, 14)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(filtered) { affirmation in
                            AffirmationCard(affirmation: affirmation) {
                                selectedAffirmation = affirmation
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Affirmations")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .sheet(item: $selectedAffirmation) { affirmation in
            AffirmationShareSheet(affirmation: affirmation)
        }
    }
}

// MARK: - Affirmation Card

private struct AffirmationCard: View {
    let affirmation: ShareAffirmation
    let onShare: () -> Void

    var body: some View {
        Button(action: onShare) {
            VStack(alignment: .leading, spacing: 12) {
                Text(affirmation.category)
                    .font(AppFont.caption(10, weight: .semibold))
                    .foregroundStyle(affirmation.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(affirmation.color.opacity(0.15), in: Capsule())

                Text("\"\(affirmation.text)\"")
                    .font(AppFont.serifTitle(14))
                    .foregroundStyle(AppColors.cream)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                HStack {
                    Spacer()
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.lavender.opacity(0.5))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(affirmation.color.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Share Sheet

private struct AffirmationShareSheet: View {
    let affirmation: ShareAffirmation
    @Environment(\.dismiss) private var dismiss

    @MainActor
    private var shareCard: some View {
        ZStack {
            LinearGradient(
                colors: [affirmation.color.opacity(0.6), AppColors.deepViolet],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            VStack(spacing: 20) {
                Image(systemName: "sparkles")
                    .font(.system(size: 28))
                    .foregroundStyle(.white.opacity(0.8))
                Text("\"\(affirmation.text)\"")
                    .font(.custom("Georgia", size: 18))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 20)
                Text("Twin Flame Union")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
                    .kerning(2)
            }
            .padding(32)
        }
        .frame(width: 360, height: 360)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    @MainActor
    private func renderImage() -> UIImage? {
        let renderer = ImageRenderer(content: shareCard)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }

    var body: some View {
        ZStack {
            AppColors.deepViolet.ignoresSafeArea()
            VStack(spacing: 24) {
                Text("Share This Affirmation")
                    .font(AppFont.serifHeadline(22))
                    .foregroundStyle(AppColors.cream)
                    .padding(.top, 32)

                shareCard
                    .shadow(color: affirmation.color.opacity(0.4), radius: 24, y: 12)

                if let img = renderImage() {
                    ShareLink(item: Image(uiImage: img), preview: SharePreview(affirmation.text, image: Image(uiImage: img))) {
                        Label("Share Card", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .warmButtonStyle()
                    .padding(.horizontal, 32)
                }

                Button("Close") { dismiss() }
                    .font(AppFont.body(14))
                    .foregroundStyle(AppColors.lavender)
                    .padding(.bottom, 32)
            }
        }
        .presentationDetents([.large])
        .preferredColorScheme(.dark)
    }
}
