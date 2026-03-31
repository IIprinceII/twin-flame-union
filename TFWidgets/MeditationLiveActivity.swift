//
//  MeditationLiveActivity.swift
//  TFWidgets
//
//  Dynamic Island + Lock Screen Live Activity for meditation sessions.
//

import ActivityKit
import WidgetKit
import SwiftUI

private let flameColor   = Color(red: 1.0, green: 0.70, blue: 0.30)
private let bgColor      = Color(red: 0.07, green: 0.03, blue: 0.15)
private let lavender     = Color(red: 0.72, green: 0.65, blue: 0.90)

struct MeditationLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MeditationActivityAttributes.self) { context in

            // MARK: Lock Screen / Banner
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(flameColor.opacity(0.2))
                        .frame(width: 44, height: 44)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(flameColor)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(context.state.sessionName)
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                        .foregroundStyle(.white)
                    Text(context.state.phase)
                        .font(.system(size: 12))
                        .foregroundStyle(lavender)
                }

                Spacer()

                if context.state.isRunning {
                    Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                        .font(.system(size: 22, weight: .semibold, design: .serif).monospacedDigit())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 72, alignment: .trailing)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(bgColor)
            .activityBackgroundTint(bgColor)

        } dynamicIsland: { context in
            DynamicIsland {

                // MARK: Expanded — Leading
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(flameColor)
                        Text(context.state.phase)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(lavender)
                    }
                    .padding(.leading, 4)
                }

                // MARK: Expanded — Trailing
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isRunning {
                        Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                            .font(.system(size: 18, weight: .semibold).monospacedDigit())
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.trailing)
                            .padding(.trailing, 4)
                    }
                }

                // MARK: Expanded — Center
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.sessionName)
                        .font(.system(size: 13, weight: .medium, design: .serif))
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(1)
                }

                // MARK: Expanded — Bottom
                DynamicIslandExpandedRegion(.bottom) {
                    BreathProgressBar(phase: context.state.phase)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 6)
                }

            } compactLeading: {
                Image(systemName: "flame.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(flameColor)

            } compactTrailing: {
                if context.state.isRunning {
                    Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                        .font(.system(size: 12).monospacedDigit())
                        .foregroundStyle(.white)
                        .frame(width: 44, alignment: .trailing)
                }

            } minimal: {
                Image(systemName: "flame.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(flameColor)
            }
            .keylineTint(flameColor)
        }
    }
}

// MARK: - Breath Phase Progress Bar

private struct BreathProgressBar: View {
    let phase: String

    private let phases = ["Breathe in", "Hold", "Breathe out", "Rest"]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(phases, id: \.self) { p in
                Capsule()
                    .fill(p == phase ? flameColor : Color.white.opacity(0.2))
                    .frame(height: 3)
                    .animation(.easeInOut(duration: 0.3), value: phase)
            }
        }
    }
}
