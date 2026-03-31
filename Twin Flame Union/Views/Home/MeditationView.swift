//
//  MeditationView.swift
//  Twin Flame Union
//
//  Guided meditation with breathing orb, ambient sounds, and Live Activity.
//

import SwiftUI
import ActivityKit
import AVFoundation

// MARK: - Breath Phase

enum BreathPhase: String, CaseIterable {
    case inhale  = "Inhale"
    case holdIn  = "Hold"
    case exhale  = "Exhale"
    case holdOut = "Rest"

    var duration: Double { 4 }

    var next: BreathPhase {
        switch self {
        case .inhale:  return .holdIn
        case .holdIn:  return .exhale
        case .exhale:  return .holdOut
        case .holdOut: return .inhale
        }
    }

    var orbScale: CGFloat {
        switch self {
        case .inhale, .holdIn:  return 1.25
        case .exhale, .holdOut: return 0.72
        }
    }

    var instruction: String {
        switch self {
        case .inhale:  return "Breathe in"
        case .holdIn:  return "Hold"
        case .exhale:  return "Breathe out"
        case .holdOut: return "Rest"
        }
    }
}

// MARK: - Session Preset

struct MeditationSession: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let duration: TimeInterval
    let icon: String
    let color: Color
}

// MARK: - Ambient Sound

enum AmbientSound: String, CaseIterable {
    case silence      = "Silence"
    case rain         = "Rain"
    case tibetanBowls = "Tibetan Bowls"
    case forest       = "Forest"
    case ocean        = "Ocean"

    var icon: String {
        switch self {
        case .silence:      return "speaker.slash.fill"
        case .rain:         return "cloud.rain.fill"
        case .tibetanBowls: return "circle.grid.2x2.fill"
        case .forest:       return "leaf.fill"
        case .ocean:        return "water.waves"
        }
    }

    var filename: String {
        switch self {
        case .silence:      return ""
        case .rain:         return "rain"
        case .tibetanBowls: return "tibetan_bowls"
        case .forest:       return "forest"
        case .ocean:        return "ocean"
        }
    }
}

// MARK: - Ambient Sound Player

final class AmbientSoundPlayer {
    private var player: AVAudioPlayer?

    func play(sound: AmbientSound) {
        guard sound != .silence, !sound.filename.isEmpty else {
            stop()
            return
        }

        // Try common audio extensions
        let extensions = ["mp3", "m4a", "wav", "aiff"]
        var url: URL?
        for ext in extensions {
            if let found = Bundle.main.url(forResource: sound.filename, withExtension: ext) {
                url = found
                break
            }
        }

        guard let audioURL = url else {
            // File not found in bundle — silent fallback
            stop()
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: audioURL)
            player?.numberOfLoops = -1
            player?.volume = 0.6
            player?.play()
        } catch {
            // Audio session or playback failed — silent fallback
            player = nil
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }
}

// MARK: - ViewModel

@Observable
@MainActor
final class MeditationViewModel {

    var selectedSession = MeditationViewModel.sessions[0]
    var selectedSound: AmbientSound = .silence
    var isRunning = false
    var timeRemaining: TimeInterval = 0
    var currentPhase: BreathPhase = .inhale
    var orbScale: CGFloat = 0.72
    var isComplete = false

    @ObservationIgnored
    private var timerTask: Task<Void, Never>?
    @ObservationIgnored
    private var breathTask: Task<Void, Never>?
    @ObservationIgnored
    private var liveActivity: Activity<MeditationActivityAttributes>?
    @ObservationIgnored
    private let soundPlayer = AmbientSoundPlayer()

    static let sessions: [MeditationSession] = [
        MeditationSession(name: "Ground & Center",        subtitle: "5 min",  duration:  5 * 60, icon: "leaf.fill",            color: Color(hex: "4CAF82")),
        MeditationSession(name: "Heart Opening",          subtitle: "10 min", duration: 10 * 60, icon: "heart.fill",           color: Color(hex: "FF6B9D")),
        MeditationSession(name: "Deep Surrender",         subtitle: "15 min", duration: 15 * 60, icon: "moon.stars.fill",      color: Color(hex: "4A90D9")),
        MeditationSession(name: "Twin Flame Union",       subtitle: "20 min", duration: 20 * 60, icon: "flame.fill",           color: Color(hex: "A78BCA")),
        MeditationSession(name: "Crown Activation",       subtitle: "15 min", duration: 15 * 60, icon: "sparkles",             color: Color(hex: "E0D4F7")),
        MeditationSession(name: "Return to Sender",       subtitle: "10 min", duration: 10 * 60, icon: "shield.fill",          color: Color(hex: "4169E1")),
        MeditationSession(name: "Covenant Prayer",        subtitle: "20 min", duration: 20 * 60, icon: "hands.sparkles.fill",  color: Color(hex: "C39BD3")),
        MeditationSession(name: "Archangel Michael",      subtitle: "12 min", duration: 12 * 60, icon: "cross.fill",           color: Color(hex: "1E90FF")),
    ]

    var timeString: String {
        let m = Int(timeRemaining) / 60
        let s = Int(timeRemaining) % 60
        return String(format: "%d:%02d", m, s)
    }

    func start() {
        isComplete = false
        timeRemaining = selectedSession.duration
        currentPhase = .inhale
        isRunning = true
        startBreathCycle()
        startCountdown()
        startLiveActivity()
        soundPlayer.play(sound: selectedSound)
    }

    func stop() {
        isRunning = false
        timerTask?.cancel()
        breathTask?.cancel()
        timerTask = nil
        breathTask = nil
        orbScale = 0.72
        currentPhase = .inhale
        endLiveActivity()
        soundPlayer.stop()
    }

    private func startCountdown() {
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled, let self else { return }
                timeRemaining -= 1
                if timeRemaining <= 0 {
                    isComplete = true
                    stop()
                    return
                }
            }
        }
    }

    private func startBreathCycle() {
        breathTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                let phase = currentPhase
                withAnimation(.easeInOut(duration: phase.duration)) {
                    orbScale = phase.orbScale
                }
                try? await Task.sleep(for: .seconds(phase.duration))
                guard !Task.isCancelled else { return }
                currentPhase = phase.next
            }
        }
    }

    // MARK: Live Activity

    private func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let endDate = Date().addingTimeInterval(selectedSession.duration)
        let attrs = MeditationActivityAttributes(
            sessionName: selectedSession.name,
            totalDuration: selectedSession.duration
        )
        let state = MeditationActivityAttributes.ContentState(
            endDate: endDate,
            phase: currentPhase.instruction,
            isRunning: true,
            sessionName: selectedSession.name
        )
        do {
            liveActivity = try Activity.request(
                attributes: attrs,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            // Live Activities not supported on this device/OS
        }
    }

    private func endLiveActivity() {
        Task { [weak self] in
            await self?.liveActivity?.end(nil, dismissalPolicy: .immediate)
            self?.liveActivity = nil
        }
    }
}

// MARK: - Meditation View

struct MeditationView: View {
    @State private var viewModel = MeditationViewModel()

    var body: some View {
        ZStack {
            CosmicBackground()

            GeometryReader { geo in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // MARK: Session Picker
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(MeditationViewModel.sessions) { session in
                                    SessionChip(
                                        session: session,
                                        isSelected: viewModel.selectedSession.id == session.id
                                    ) {
                                        guard !viewModel.isRunning else { return }
                                        viewModel.selectedSession = session
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 4)
                        }
                        .padding(.top, 16)

                        // MARK: Ambient Sound Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ambient Sound")
                                .font(AppFont.caption(12, weight: .semibold))
                                .foregroundStyle(AppColors.lavender)
                                .padding(.horizontal, 28)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(AmbientSound.allCases, id: \.self) { sound in
                                        SoundChip(
                                            sound: sound,
                                            isSelected: viewModel.selectedSound == sound
                                        ) {
                                            guard !viewModel.isRunning else { return }
                                            viewModel.selectedSound = sound
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(.top, 12)

                        Spacer(minLength: 24)

                        // MARK: Breathing Orb
                        ZStack {
                            // Outer ambient glow
                            Circle()
                                .fill(viewModel.selectedSession.color.opacity(0.12))
                                .frame(width: 280, height: 280)
                                .scaleEffect(viewModel.orbScale * 1.15)
                                .blur(radius: 24)
                                .animation(.easeInOut(duration: viewModel.currentPhase.duration), value: viewModel.orbScale)

                            // Mid ring
                            Circle()
                                .strokeBorder(viewModel.selectedSession.color.opacity(0.25), lineWidth: 1)
                                .frame(width: 230, height: 230)
                                .scaleEffect(viewModel.orbScale * 1.05)
                                .animation(.easeInOut(duration: viewModel.currentPhase.duration), value: viewModel.orbScale)

                            // Core orb
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            viewModel.selectedSession.color.opacity(0.85),
                                            viewModel.selectedSession.color.opacity(0.3),
                                            viewModel.selectedSession.color.opacity(0.05),
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 110
                                    )
                                )
                                .frame(width: 210, height: 210)
                                .scaleEffect(viewModel.orbScale)
                                .animation(.easeInOut(duration: viewModel.currentPhase.duration), value: viewModel.orbScale)

                            // Center content
                            if viewModel.isRunning {
                                VStack(spacing: 6) {
                                    Text(viewModel.currentPhase.instruction)
                                        .font(AppFont.serifHeadline(22))
                                        .foregroundStyle(.white)
                                        .contentTransition(.opacity)
                                        .animation(.easeInOut(duration: 0.4), value: viewModel.currentPhase)
                                    Text(viewModel.timeString)
                                        .font(AppFont.body(14))
                                        .foregroundStyle(.white.opacity(0.6))
                                        .monospacedDigit()
                                }
                            } else if viewModel.isComplete {
                                VStack(spacing: 6) {
                                    Text("✨")
                                        .font(.system(size: 32))
                                    Text("Complete")
                                        .font(AppFont.serifHeadline(20))
                                        .foregroundStyle(.white)
                                }
                            } else {
                                VStack(spacing: 6) {
                                    Image(systemName: viewModel.selectedSession.icon)
                                        .font(.system(size: 34))
                                        .foregroundStyle(viewModel.selectedSession.color)
                                    Text(viewModel.selectedSession.subtitle)
                                        .font(AppFont.caption(13))
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                            }
                        }

                        Spacer(minLength: 24)

                        // MARK: Session Name + Breath Pattern
                        if viewModel.isRunning {
                            VStack(spacing: 6) {
                                Text(viewModel.selectedSession.name)
                                    .font(AppFont.serifTitle(18))
                                    .foregroundStyle(AppColors.cream)
                                Text("Box breathing · 4 · 4 · 4 · 4")
                                    .font(AppFont.caption(12))
                                    .foregroundStyle(AppColors.lavender)
                            }
                            .padding(.bottom, 28)
                        } else {
                            Text("Box breathing · 4 · 4 · 4 · 4")
                                .font(AppFont.caption(12))
                                .foregroundStyle(AppColors.lavender)
                                .padding(.bottom, 28)
                        }

                        // MARK: Start / Stop Button
                        Button {
                            if viewModel.isRunning {
                                HapticManager.impact(.medium)
                                viewModel.stop()
                            } else {
                                HapticManager.notification(.success)
                                viewModel.start()
                            }
                        } label: {
                            Text(viewModel.isRunning ? "End Session" : "Begin")
                                .font(AppFont.body(17, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 200, height: 54)
                                .background(
                                    viewModel.isRunning
                                        ? AnyShapeStyle(AppColors.deepViolet.opacity(0.9))
                                        : AnyShapeStyle(AppGradients.warm),
                                    in: Capsule()
                                )
                                .overlay(
                                    Capsule().strokeBorder(
                                        viewModel.isRunning ? AppColors.purple.opacity(0.5) : Color.clear,
                                        lineWidth: 1
                                    )
                                )
                        }
                        .padding(.bottom, 52)
                    }
                    .frame(minHeight: geo.size.height)
                }
            }
        }
        .navigationTitle("Meditations")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onDisappear { viewModel.stop() }
    }
}

// MARK: - Session Chip

private struct SessionChip: View {
    let session: MeditationSession
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Image(systemName: session.icon)
                    .font(.system(size: 12))
                    .foregroundStyle(isSelected ? .white : session.color)
                VStack(alignment: .leading, spacing: 1) {
                    Text(session.name)
                        .font(AppFont.body(13, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? .white : AppColors.cream)
                    Text(session.subtitle)
                        .font(AppFont.caption(11))
                        .foregroundStyle(isSelected ? .white.opacity(0.7) : AppColors.lavender)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                isSelected ? session.color.opacity(0.85) : AppColors.deepViolet.opacity(0.7),
                in: Capsule()
            )
            .overlay(
                Capsule().strokeBorder(
                    isSelected ? session.color : AppColors.purple.opacity(0.3),
                    lineWidth: 1
                )
            )
        }
    }
}

// MARK: - Sound Chip

private struct SoundChip: View {
    let sound: AmbientSound
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: sound.icon)
                    .font(.system(size: 12))
                    .foregroundStyle(isSelected ? .white : AppColors.lavender)
                Text(sound.rawValue)
                    .font(AppFont.body(13, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .white : AppColors.lavender)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isSelected ? AppColors.purple.opacity(0.7) : AppColors.deepViolet.opacity(0.5),
                in: Capsule()
            )
            .overlay(
                Capsule().strokeBorder(
                    isSelected ? AppColors.purple : AppColors.purple.opacity(0.25),
                    lineWidth: 1
                )
            )
        }
    }
}
