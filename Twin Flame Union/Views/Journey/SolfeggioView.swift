//
//  SolfeggioView.swift
//  Twin Flame Union
//
//  Solfeggio & binaural frequency player using AVAudioEngine sine-wave synthesis.
//

import SwiftUI
import AVFoundation

// MARK: - Frequency Model

private struct SolfeggioFreq: Identifiable {
    let id = UUID()
    let hz: Double
    let name: String
    let subtitle: String
    let color: Color
    let icon: String
    let twinFlameBenefit: String
    let affirmation: String
}

private let frequencies: [SolfeggioFreq] = [
    .init(hz: 174, name: "174 Hz", subtitle: "Foundation of Safety",
          color: Color(hex: "E53935"), icon: "mountain.2.fill",
          twinFlameBenefit: "Traditionally associated with feelings of safety and grounding as you release fear around reunion.",
          affirmation: "I am safe. I am grounded. Love is safe to receive."),
    .init(hz: 285, name: "285 Hz", subtitle: "Energetic Renewal",
          color: Color(hex: "FF7043"), icon: "leaf.fill",
          twinFlameBenefit: "Often used in sound practice for a sense of renewal and energetic wholeness.",
          affirmation: "My energy field is restored and whole."),
    .init(hz: 396, name: "396 Hz", subtitle: "Release Fear & Guilt",
          color: Color(hex: "FDD835"), icon: "lock.open.fill",
          twinFlameBenefit: "Liberates guilt and fear — the two deepest blocks to twin flame union.",
          affirmation: "I release all fear. I release all guilt. I am free."),
    .init(hz: 417, name: "417 Hz", subtitle: "Facilitate Change",
          color: Color(hex: "43A047"), icon: "arrow.triangle.2.circlepath",
          twinFlameBenefit: "Used in sound practice to support a sense of release and openness to change in the connection.",
          affirmation: "I welcome transformation. I am ready for the new."),
    .init(hz: 528, name: "528 Hz", subtitle: "The Love Frequency",
          color: Color(hex: "4CAF50"), icon: "heart.fill",
          twinFlameBenefit: "Known in sound tradition as the love frequency — associated with the heart and a felt sense of divine love.",
          affirmation: "I am love. I am loved. My twin flame feels this love now."),
    .init(hz: 639, name: "639 Hz", subtitle: "Connection & Harmony",
          color: Color(hex: "1E88E5"), icon: "person.2.fill",
          twinFlameBenefit: "Enhances communication, connection, and harmony. Draws twin flames back into resonance.",
          affirmation: "My twin flame and I are in perfect harmony and connection."),
    .init(hz: 741, name: "741 Hz", subtitle: "Intuition & Expression",
          color: Color(hex: "5E35B1"), icon: "waveform",
          twinFlameBenefit: "Awakens intuition, clears blocks in self-expression, and activates the throat and third eye chakras.",
          affirmation: "I speak my truth. My intuition is clear and strong."),
    .init(hz: 852, name: "852 Hz", subtitle: "Return to Spiritual Order",
          color: Color(hex: "8B5CF6"), icon: "sparkles",
          twinFlameBenefit: "Returns you to spiritual order. Awakens intuition and reconnects you to your soul's original purpose.",
          affirmation: "I am aligned with my highest spiritual purpose."),
    .init(hz: 963, name: "963 Hz", subtitle: "Crown & Divine Connection",
          color: Color(hex: "CC88FF"), icon: "crown.fill",
          twinFlameBenefit: "Activates the crown chakra, enabling direct communion with God and alignment with the divine plan for your union.",
          affirmation: "I am one with God. Divine love flows through me freely."),
    .init(hz: 1111, name: "1111 Hz", subtitle: "Twin Flame Activation",
          color: Color(hex: "F0C040"), icon: "flame.fill",
          twinFlameBenefit: "The twin flame activation frequency. 1111 is the code of awakening and magnetic reunion between twin souls.",
          affirmation: "My twin flame and I are awakening. Union is encoded in my frequency."),
]

// MARK: - View

struct SolfeggioView: View {
    @Environment(ToneGenerator.self) private var generator
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulseAnim = false
    @AppStorage(WellnessDisclaimer.ackKey) private var disclaimerAcked = false
    @State private var showDisclaimer = false

    private var selected: SolfeggioFreq? {
        frequencies.first { $0.hz == generator.currentFrequency }
    }

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // Playing orb
                    if generator.isPlaying, let freq = selected {
                        playingOrb(freq: freq)
                            .padding(.top, 16)
                    } else {
                        VStack(spacing: 6) {
                            Text("Select a frequency to begin")
                                .font(AppFont.body(14))
                                .foregroundStyle(AppColors.lavender.opacity(0.6))
                            Text("Audio continues when you leave this screen")
                                .font(AppFont.caption(12))
                                .foregroundStyle(AppColors.lavender.opacity(0.35))
                        }
                        .padding(.top, 24)
                    }

                    // Frequency list
                    VStack(spacing: 10) {
                        ForEach(frequencies) { freq in
                            FrequencyRow(
                                freq: freq,
                                isPlaying: generator.isPlaying && generator.currentFrequency == freq.hz,
                                onTap: { toggle(freq) }
                            )
                        }
                    }
                    .padding(.horizontal, 24)

                    DisclaimerFooter()
                        .padding(.horizontal, 24)

                    Spacer().frame(height: 32)
                }
            }
        }
        .onAppear {
            if !disclaimerAcked { showDisclaimer = true }
        }
        .sheet(isPresented: $showDisclaimer) {
            WellnessDisclaimerSheet()
        }
        .navigationTitle("Frequencies")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    // MARK: Playing Orb

    private func playingOrb(freq: SolfeggioFreq) -> some View {
        VStack(spacing: 16) {
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(freq.color.opacity(0.08 - Double(i) * 0.02))
                        .frame(width: CGFloat(100 + i * 36), height: CGFloat(100 + i * 36))
                        .scaleEffect(pulseAnim ? 1.12 : 0.92)
                        .animation(
                            .calm(reduceMotion, .easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(Double(i) * 0.3)),
                            value: pulseAnim
                        )
                        .accessibilityHidden(true)
                }
                Circle()
                    .fill(freq.color.opacity(0.35))
                    .frame(width: 100, height: 100)
                VStack(spacing: 2) {
                    Text(freq.name)
                        .font(AppFont.serifHeadline(20))
                        .foregroundStyle(.white)
                    Text(formatTime(generator.elapsedSeconds))
                        .font(AppFont.caption(13))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }

            Text(freq.subtitle)
                .font(AppFont.serifTitle(16))
                .foregroundStyle(AppColors.cream)

            Button {
                HapticManager.impact(.medium)
                generator.stop()
            } label: {
                Label("Stop", systemImage: "stop.fill")
                    .font(AppFont.body(14, weight: .semibold))
                    .foregroundStyle(AppColors.cream)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(AppColors.deepViolet.opacity(0.7), in: Capsule())
                    .overlay(Capsule().strokeBorder(AppColors.purple.opacity(0.4), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .onAppear { pulseAnim = true }
    }

    // MARK: Logic

    private func toggle(_ freq: SolfeggioFreq) {
        if generator.isPlaying && generator.currentFrequency == freq.hz {
            generator.stop()
        } else {
            generator.play(frequency: freq.hz, name: freq.name, color: freq.color)
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

// MARK: - Frequency Row

private struct FrequencyRow: View {
    let freq: SolfeggioFreq
    let isPlaying: Bool
    let onTap: () -> Void
    @State private var isExpanded = false

    var body: some View {
        Button {
            HapticManager.impact(.medium)
            if isPlaying {
                withAnimation(.spring(response: 0.35)) { isExpanded.toggle() }
            } else {
                onTap()
                withAnimation(.spring(response: 0.35)) { isExpanded = true }
            }
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(freq.color.opacity(isPlaying ? 0.35 : 0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: isPlaying ? "waveform" : freq.icon)
                            .font(.system(size: 18))
                            .foregroundStyle(freq.color)
                            .symbolEffect(.variableColor, isActive: isPlaying)
                    }
                    .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(freq.name)
                            .font(AppFont.body(16, weight: .semibold))
                            .foregroundStyle(AppColors.cream)
                        Text(freq.subtitle)
                            .font(AppFont.caption(12))
                            .foregroundStyle(AppColors.lavender)
                    }

                    Spacer()

                    if isPlaying {
                        Text("NOW PLAYING")
                            .font(AppFont.caption(9, weight: .semibold))
                            .foregroundStyle(freq.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(freq.color.opacity(0.15), in: Capsule())
                    } else {
                        Image(systemName: "play.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(AppColors.lavender.opacity(0.5))
                            .accessibilityHidden(true)
                    }
                }
                .padding(16)

                if isExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        Divider().background(freq.color.opacity(0.25)).padding(.horizontal, 16)
                        Text(freq.twinFlameBenefit)
                            .font(AppFont.body(13))
                            .foregroundStyle(AppColors.lavender)
                            .lineSpacing(4)
                            .padding(.horizontal, 16)
                        Text("\"\(freq.affirmation)\"")
                            .font(AppFont.serifTitle(13))
                            .foregroundStyle(AppColors.cream.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 14)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(
                isPlaying ? freq.color.opacity(0.1) : AppColors.deepViolet.opacity(0.6),
                in: RoundedRectangle(cornerRadius: 18)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(isPlaying ? freq.color.opacity(0.5) : AppColors.purple.opacity(0.2), lineWidth: isPlaying ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
