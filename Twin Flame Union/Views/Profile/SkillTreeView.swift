//
//  SkillTreeView.swift
//  Twin Flame Union
//
//  Skill tree visualization for a single framework.
//

import SwiftUI

struct SkillTreeView: View {
    let framework: SacredFramework
    @Environment(GamificationService.self) private var gamification
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicBackground()

                RadialGradient(
                    colors: [framework.color.opacity(0.08), Color.clear],
                    center: .top, startRadius: 0, endRadius: 300
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(framework.color.opacity(0.2))
                                    .frame(width: 64, height: 64)
                                Image(systemName: framework.icon)
                                    .font(.system(size: 26))
                                    .foregroundStyle(framework.color)
                            }
                            Text(framework.title)
                                .font(AppFont.serifHeadline(22))
                                .foregroundStyle(AppColors.cream)
                            Text(framework.subtitle)
                                .font(AppFont.caption(12))
                                .foregroundStyle(framework.color.opacity(0.7))
                            Text("Level \(gamification.frameworkLevel(for: framework))")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(AppColors.gold)
                        }
                        .padding(.top, 12)

                        // Skill Nodes
                        ForEach(framework.nodes) { node in
                            SkillNodeCard(
                                node: node,
                                level: gamification.profile?.skillLevel(for: node.id) ?? 0,
                                xp: gamification.profile?.skillLevels[node.id + "_xp"] ?? 0,
                                isUnlocked: isNodeUnlocked(node)
                            )
                            .padding(.horizontal, 20)
                        }

                        Spacer().frame(height: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AppColors.lavender.opacity(0.6))
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
        }
    }

    private func isNodeUnlocked(_ node: SkillNode) -> Bool {
        guard let profile = gamification.profile else { return node.prerequisites.isEmpty }
        for prereq in node.prerequisites {
            if profile.skillLevel(for: prereq) < 3 { return false }
        }
        return true
    }
}

// MARK: - Skill Node Card

private struct SkillNodeCard: View {
    let node: SkillNode
    let level: Int
    let xp: Int
    let isUnlocked: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? node.color.opacity(0.18) : Color.gray.opacity(0.1))
                    .frame(width: 52, height: 52)
                if isUnlocked {
                    Image(systemName: node.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(node.color)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.lavender.opacity(0.3))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(node.title)
                    .font(AppFont.body(15, weight: .semibold))
                    .foregroundStyle(isUnlocked ? AppColors.cream : AppColors.lavender.opacity(0.4))

                if isUnlocked {
                    // Level indicator
                    HStack(spacing: 3) {
                        ForEach(0..<node.maxLevel, id: \.self) { i in
                            Circle()
                                .fill(i < level ? node.color : node.color.opacity(0.15))
                                .frame(width: 6, height: 6)
                        }
                    }

                    Text("Level \(level) / \(node.maxLevel) · \(xp) XP")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColors.lavender.opacity(0.5))
                } else {
                    Text("Requires prerequisite skills at level 3")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColors.lavender.opacity(0.3))
                }

                Text(node.description)
                    .font(AppFont.caption(11))
                    .foregroundStyle(AppColors.lavender.opacity(isUnlocked ? 0.6 : 0.25))
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isUnlocked
                      ? AppColors.deepViolet.opacity(0.75)
                      : AppColors.deepViolet.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(
                            isUnlocked ? node.color.opacity(0.25) : Color.gray.opacity(0.1),
                            lineWidth: 1
                        )
                )
        )
        .opacity(isUnlocked ? 1 : 0.6)
    }
}
