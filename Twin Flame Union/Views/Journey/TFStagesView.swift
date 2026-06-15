//
//  TFStagesView.swift
//  Twin Flame Union
//
//  Interactive tracker for the 8 twin flame journey stages.
//

import SwiftUI

// MARK: - Stage Model

private struct TFStage: Identifiable {
    let id: Int   // 0-indexed
    let name: String
    let subtitle: String
    let icon: String
    let color: Color
    let description: String
    let shadowWork: String
    let affirmation: String
}

private let stages: [TFStage] = [
    .init(id: 0, name: "Recognition",
          subtitle: "The Awakening",
          icon: "eye.fill",
          color: Color(hex: "8B5CF6"),
          description: "The first encounter — an inexplicable, overwhelming sense of knowing. Time stops. You see yourself reflected in another's eyes. This is no ordinary meeting.",
          shadowWork: "Examine your fear of being truly seen. Ask: am I afraid of this depth of recognition?",
          affirmation: "I recognize the divine in my twin. I am ready to be known completely."),
    .init(id: 1, name: "Testing",
          subtitle: "The Honeymoon & Friction",
          icon: "bolt.fill",
          color: Color(hex: "9B59B6"),
          description: "The connection deepens but so do the triggers. Old wounds surface. The relationship tests your capacity for love — not because it is wrong, but because it is real.",
          shadowWork: "Notice which patterns are being activated. Whose voice is really speaking when you argue?",
          affirmation: "Every trigger is a teacher. I welcome the growth this love calls forth."),
    .init(id: 2, name: "Crisis",
          subtitle: "The Eruption",
          icon: "flame.fill",
          color: Color(hex: "D97B4A"),
          description: "The relationship reaches a breaking point. Buried fears and unresolved trauma erupt to the surface. This is not destruction — it is purification.",
          shadowWork: "Go deep: what core wound is being healed here? What are you learning about yourself?",
          affirmation: "I trust the fire. What burns away was never truly mine to keep."),
    .init(id: 3, name: "Runner & Chaser",
          subtitle: "The Sacred Dance",
          icon: "arrow.left.and.right",
          color: Color(hex: "E74C8B"),
          description: "One retreats; one pursues. This is not rejection — it is the nervous system protecting what it cannot yet hold. Both roles carry a spiritual lesson.",
          shadowWork: "Runner: what are you afraid to feel? Chaser: where does your worth come from?",
          affirmation: "I release the chase. I trust the divine timing of our reunion."),
    .init(id: 4, name: "Surrender",
          subtitle: "The Letting Go",
          icon: "hand.raised.fill",
          color: Color(hex: "4A90D9"),
          description: "You stop trying to force the connection and give it to God. This is not giving up — it is the most courageous act of the journey. Surrender creates space for miracles.",
          shadowWork: "Practice releasing outcomes daily. Journal: what would my life look like if I fully trusted God here?",
          affirmation: "I surrender this union to the divine. God's plan is perfect and I trust it completely."),
    .init(id: 5, name: "Illumination",
          subtitle: "The Inner Work",
          icon: "sun.max.fill",
          color: Color(hex: "F0C040"),
          description: "Separated but growing. The focus shifts inward. Both twins do the deep healing, shadow integration, and spiritual development that the union requires. The real reunion begins within.",
          shadowWork: "Commit to daily inner work: therapy, prayer, journaling. Become who you are meant to be.",
          affirmation: "My healing is my reunion. As I become whole, my twin returns to wholeness too."),
    .init(id: 6, name: "Radiance",
          subtitle: "The Homecoming Within",
          icon: "sparkles",
          color: Color(hex: "7EC8A0"),
          description: "You have integrated your shadows, healed your wounds, and risen to your highest self. Whether your twin is physically present or not, you are in union with your own soul. Peace reigns.",
          shadowWork: "Ask: what gifts have I discovered about myself through this journey? Celebrate them.",
          affirmation: "I am whole. I am healed. I radiate the love I sought. My twin flame knows."),
    .init(id: 7, name: "Harmonizing Union",
          subtitle: "Sacred Union",
          icon: "heart.fill",
          color: Color(hex: "CC88FF"),
          description: "Two sovereign, healed souls choose each other freely — not from lack, but from overflow. This is the sacred union the journey prepared you for. Love flows without grasping.",
          shadowWork: "Maintain your individual spiritual practice. Union requires two whole souls, not two halves.",
          affirmation: "We choose each other freely from love. Our union is a gift to the world."),
]

// MARK: - View

struct TFStagesView: View {
    @AppStorage("tfCurrentStage") private var currentStageID = 0
    @State private var expandedID: Int? = nil

    var body: some View {
        ZStack {
            CosmicBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Header
                    VStack(spacing: 8) {
                        Text("Stage \(currentStageID + 1) of 8")
                            .font(AppFont.body(13, weight: .semibold))
                            .foregroundStyle(AppColors.lavender)
                        Text(stages[currentStageID].name)
                            .font(AppFont.serifHeadline(28))
                            .foregroundStyle(AppColors.cream)
                        Text("Your current stage")
                            .font(AppFont.caption(12))
                            .foregroundStyle(AppColors.lavender.opacity(0.6))
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(AppColors.purple.opacity(0.2))
                                .frame(height: 6)
                            Capsule()
                                .fill(AppGradients.warm)
                                .frame(width: geo.size.width * CGFloat(currentStageID + 1) / 8.0, height: 6)
                                .animation(.spring(response: 0.6), value: currentStageID)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                    // Stage cards
                    VStack(spacing: 12) {
                        ForEach(stages) { stage in
                            StageCard(
                                stage: stage,
                                isCurrent: stage.id == currentStageID,
                                isExpanded: expandedID == stage.id,
                                onSelect: {
                                    currentStageID = stage.id
                                    withAnimation(.spring(response: 0.4)) {
                                        expandedID = expandedID == stage.id ? nil : stage.id
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 32)
                }
            }
        }
        .navigationTitle("TF Stages")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Stage Card

private struct StageCard: View {
    let stage: TFStage
    let isCurrent: Bool
    let isExpanded: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 0) {

                // Header row
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(stage.color.opacity(isCurrent ? 0.3 : 0.12))
                            .frame(width: 48, height: 48)
                        Image(systemName: stage.icon)
                            .font(.system(size: 20))
                            .foregroundStyle(stage.color)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 8) {
                            Text("Stage \(stage.id + 1)")
                                .font(AppFont.caption(11, weight: .semibold))
                                .foregroundStyle(stage.color)
                            if isCurrent {
                                Text("YOU ARE HERE")
                                    .font(AppFont.caption(9, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(stage.color.opacity(0.7), in: Capsule())
                            }
                        }
                        Text(stage.name)
                            .font(AppFont.body(16, weight: .semibold))
                            .foregroundStyle(AppColors.cream)
                        Text(stage.subtitle)
                            .font(AppFont.caption(12))
                            .foregroundStyle(AppColors.lavender)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColors.lavender.opacity(0.5))
                }
                .padding(18)

                // Expanded content
                if isExpanded {
                    VStack(alignment: .leading, spacing: 16) {
                        Divider().background(stage.color.opacity(0.25))
                            .padding(.horizontal, 18)

                        Text(stage.description)
                            .font(AppFont.body(14))
                            .foregroundStyle(AppColors.cream)
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 18)

                        // Shadow work
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Shadow Work", systemImage: "moon.fill")
                                .font(AppFont.caption(12, weight: .semibold))
                                .foregroundStyle(AppColors.lavender)
                            Text(stage.shadowWork)
                                .font(AppFont.body(13))
                                .foregroundStyle(AppColors.lavender)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(14)
                        .background(AppColors.deepViolet.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 18)

                        // Affirmation
                        Text("\"\(stage.affirmation)\"")
                            .font(AppFont.serifTitle(14))
                            .foregroundStyle(AppColors.cream)
                            .lineSpacing(4)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 18)

                        if !isCurrent {
                            Button {
                                withAnimation(.spring(response: 0.4)) {
                                    // handled by parent via onSelect
                                }
                            } label: {
                                Text("I'm in this stage")
                                    .frame(maxWidth: .infinity)
                            }
                            .warmButtonStyle()
                            .padding(.horizontal, 18)
                            .padding(.bottom, 18)
                            .simultaneousGesture(TapGesture().onEnded { onSelect() })
                        }
                    }
                }
            }
            .background(
                isCurrent
                    ? stage.color.opacity(0.12)
                    : AppColors.deepViolet.opacity(0.7),
                in: RoundedRectangle(cornerRadius: 20)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        isCurrent ? stage.color.opacity(0.5) : AppColors.purple.opacity(0.2),
                        lineWidth: isCurrent ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
