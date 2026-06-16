//
//  MeditationView.swift
//  Twin Flame Union
//
//  Sacred meditation temple — each session channelled through a specific deity.
//  Hypnos & Nyx preside over the entire space.
//

import SwiftUI
import ActivityKit
import AVFoundation

// MARK: - Meditation Clock

/// Wall-clock source of truth for a meditation countdown. Pure and testable —
/// computing remaining time from an absolute `endDate` means backgrounding never
/// drifts the timer (a suspended Task-sleep loop would).
struct MeditationClock {
    let endDate: Date
    func remaining(at now: Date) -> TimeInterval { max(0, endDate.timeIntervalSince(now)) }
    func isComplete(at now: Date) -> Bool { now >= endDate }
}

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
    // Deity channelling
    let deity: String
    let deitySymbol: String
    let deityColor: Color
    let invocation: String
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
        let extensions = ["mp3", "m4a", "wav", "aiff"]
        var url: URL?
        for ext in extensions {
            if let found = Bundle.main.url(forResource: sound.filename, withExtension: ext) {
                url = found
                break
            }
        }
        guard let audioURL = url else { stop(); return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: audioURL)
            player?.numberOfLoops = -1
            player?.volume = 0.6
            player?.play()
        } catch {
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
    var showInvocation = false

    @ObservationIgnored
    private var timerTask: Task<Void, Never>?
    @ObservationIgnored
    private var breathTask: Task<Void, Never>?
    @ObservationIgnored
    private var clock: MeditationClock?
    @ObservationIgnored
    private var liveActivity: Activity<MeditationActivityAttributes>?
    @ObservationIgnored
    private let soundPlayer = AmbientSoundPlayer()

    static let sessions: [MeditationSession] = [
        // ── Earth & Grounding ──
        MeditationSession(
            name: "Ground & Center",        subtitle: "5 min",  duration:  5 * 60,
            icon: "leaf.fill",              color: Color(hex: "4CAF82"),
            deity: "Persephone",            deitySymbol: "leaf.fill",
            deityColor: Color(hex: "7EC8A0"),
            invocation: "The descent was never punishment. It was preparation for your crown."
        ),
        // ── Heart Opening ──
        MeditationSession(
            name: "Heart Opening",          subtitle: "10 min", duration: 10 * 60,
            icon: "heart.fill",             color: Color(hex: "E8739A"),
            deity: "Aphrodite",             deitySymbol: "heart.fill",
            deityColor: Color(hex: "E8739A"),
            invocation: "Let love flow through you without condition or fear."
        ),
        // ── Isis Healing ──
        MeditationSession(
            name: "Isis Healing Ritual",    subtitle: "15 min", duration: 15 * 60,
            icon: "hands.sparkles.fill",    color: Color(hex: "3D9BE9"),
            deity: "Isis",                  deitySymbol: "hands.sparkles.fill",
            deityColor: Color(hex: "3D9BE9"),
            invocation: "Isis searched the entire world and reassembled her beloved. So do you."
        ),
        // ── Twin Flame Union ──
        MeditationSession(
            name: "Twin Flame Union",       subtitle: "20 min", duration: 20 * 60,
            icon: "flame.fill",             color: Color(hex: "A78BCA"),
            deity: "Eros · Psyche",         deitySymbol: "arrow.up.heart.fill",
            deityColor: Color(hex: "FF6B8A"),
            invocation: "The arrow has already been released. Trust where it lands."
        ),
        // ── Crown Activation ──
        MeditationSession(
            name: "Crown Activation",       subtitle: "15 min", duration: 15 * 60,
            icon: "sparkles",               color: Color(hex: "E0D4F7"),
            deity: "Ra",                    deitySymbol: "sun.max.fill",
            deityColor: Color(hex: "FFD700"),
            invocation: "Ra's light reaches every corner of separation. Nothing stays dark forever."
        ),
        // ── Selene Lunar Blessing ──
        MeditationSession(
            name: "Lunar Blessing",         subtitle: "12 min", duration: 12 * 60,
            icon: "moon.stars.fill",        color: Color(hex: "B8A8FF"),
            deity: "Selene",                deitySymbol: "moon.stars.fill",
            deityColor: Color(hex: "B8A8FF"),
            invocation: "She illuminates what the sun cannot reach. Trust the lunar light."
        ),
        // ── Anubis Shadow Journey ──
        MeditationSession(
            name: "Shadow Journey",         subtitle: "20 min", duration: 20 * 60,
            icon: "moon.fill",              color: Color(hex: "5E35B1"),
            deity: "Anubis",                deitySymbol: "figure.walk",
            deityColor: Color(hex: "8B7355"),
            invocation: "Anubis guides safely through the underworld. You are protected in the dark."
        ),
        // ── Sekhmet Fierce Release ──
        MeditationSession(
            name: "Fierce Release",         subtitle: "15 min", duration: 15 * 60,
            icon: "flame.circle.fill",      color: Color(hex: "FF4500"),
            deity: "Sekhmet",               deitySymbol: "flame.fill",
            deityColor: Color(hex: "FF4500"),
            invocation: "Sekhmet's fire destroys what blocks love. Let the sacred rage do its work."
        ),
        // ── Nyx Cosmic Void ──
        MeditationSession(
            name: "Cosmic Void",            subtitle: "25 min", duration: 25 * 60,
            icon: "star.fill",              color: Color(hex: "1A0A3C"),
            deity: "Nyx · The Most High",   deitySymbol: "star.fill",
            deityColor: Color(hex: "8B7EC8"),
            invocation: "Enter the darkness meditation. The astral linkage to the Most High is strongest in the void. Move your awareness through the pitch black — feel the Most High activating your full energy grid."
        ),
        // ── Hecate Crossroads ──
        MeditationSession(
            name: "Crossroads Clarity",     subtitle: "18 min", duration: 18 * 60,
            icon: "sparkles",               color: Color(hex: "9B59B6"),
            deity: "Hecate",                deitySymbol: "sparkles",
            deityColor: Color(hex: "9B59B6"),
            invocation: "Stand at the crossroads without fear. The dark holds the answers."
        ),
        // ── Kundalini ──
        MeditationSession(
            name: "Kundalini Rising",       subtitle: "25 min", duration: 25 * 60,
            icon: "bolt.fill",              color: Color(hex: "E53935"),
            deity: "Sekhmet · Apollo · The Most High",  deitySymbol: "bolt.fill",
            deityColor: Color(hex: "FFD700"),
            invocation: "The Most High sends spiritual fire through the astral linkage. Your vibrational constitution is upgrading — use the elimination system. Breathe, release, ascend."
        ),
        // ── Thoth Deep Surrender ──
        MeditationSession(
            name: "Deep Surrender",         subtitle: "20 min", duration: 20 * 60,
            icon: "text.book.closed.fill",  color: Color(hex: "4A90D9"),
            deity: "Thoth",                 deitySymbol: "text.book.closed.fill",
            deityColor: Color(hex: "5B8CFF"),
            invocation: "Thoth has already written the end of this story. It is a reunion."
        ),
        // ── Covenant Prayer ──
        MeditationSession(
            name: "Covenant Prayer",        subtitle: "20 min", duration: 20 * 60,
            icon: "hands.sparkles.fill",    color: Color(hex: "C39BD3"),
            deity: "Ra · Amun · The Most High", deitySymbol: "wind",
            deityColor: Color(hex: "4169E1"),
            invocation: "Prayer is direct communion through the astral linkage — the soul speaking upward through the same cord that the Most High speaks downward through. Amun breathes hidden power into every prayer spoken in faith."
        ),
        // ── Heart Healing ──
        MeditationSession(
            name: "Heart Healing",          subtitle: "15 min", duration: 15 * 60,
            icon: "heart.circle.fill",      color: Color(hex: "43A047"),
            deity: "Panacea",               deitySymbol: "cross.circle.fill",
            deityColor: Color(hex: "7EC8A0"),
            invocation: "There is a remedy for every wound. The healing is already underway."
        ),
        // ── Inner Child ──
        MeditationSession(
            name: "Inner Child Reunion",    subtitle: "18 min", duration: 18 * 60,
            icon: "figure.and.child.holdinghands", color: Color(hex: "FF7043"),
            deity: "Hestia",                deitySymbol: "flame.fill",
            deityColor: Color(hex: "FF9A6C"),
            invocation: "Your heart is a sacred hearth. Tend it. Keep it burning."
        ),
    ]

    var timeString: String {
        let m = Int(timeRemaining) / 60
        let s = Int(timeRemaining) % 60
        return String(format: "%d:%02d", m, s)
    }

    func start() {
        isComplete = false
        timeRemaining = selectedSession.duration
        clock = MeditationClock(endDate: Date().addingTimeInterval(selectedSession.duration))
        currentPhase = .inhale
        isRunning = true
        // Ask for Apple Health permission once, on the user's first meditation.
        if !UserDefaults.standard.bool(forKey: "hasRequestedMeditationHealth") {
            UserDefaults.standard.set(true, forKey: "hasRequestedMeditationHealth")
            Task { try? await HealthService.shared.requestAuthorization() }
        }
        showInvocation = false
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
                guard !Task.isCancelled, let self, let clock = self.clock else { return }
                let now = Date()
                timeRemaining = clock.remaining(at: now)
                if clock.isComplete(at: now) {
                    complete()
                    return
                }
            }
        }
    }

    /// Full-completion path: stop, award XP, and log the mindful session to Apple Health.
    /// Guarded by `isComplete` so it runs once per session.
    private func complete() {
        guard !isComplete else { return }
        isComplete = true
        timeRemaining = 0
        let loggedDuration = selectedSession.duration
        stop()
        GamificationService.shared.awardXP(amount: 30, source: "meditation", framework: .apollux, skillKey: "ap_focus", detail: "Completed meditation: \(selectedSession.name)")
        Task { try? await HealthService.shared.logMindfulSession(duration: loggedDuration) }
    }

    /// Re-evaluate the timer against the wall clock when the app returns to the foreground.
    /// If the session finished while backgrounded, complete it now.
    func syncToWallClock() {
        guard isRunning, let clock else { return }
        let now = Date()
        timeRemaining = clock.remaining(at: now)
        if clock.isComplete(at: now) { complete() }
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
        } catch {}
    }

    private func endLiveActivity() {
        Task { @MainActor [weak self] in
            await self?.liveActivity?.end(nil, dismissalPolicy: .immediate)
            self?.liveActivity = nil
        }
    }
}

// MARK: - Meditation View

struct MeditationView: View {
    @AppStorage(WellnessDisclaimer.ackKey) private var disclaimerAcked = false
    @State private var showDisclaimer = false
    @State private var viewModel = MeditationViewModel()
    @State private var appeared = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            CosmicBackground()

            GeometryReader { geo in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // ── Deity Header ──
                        deityHeader
                            .padding(.top, 8)
                            .padding(.bottom, 16)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 12)

                        // ── Session Picker ──
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(MeditationViewModel.sessions) { session in
                                    SessionChip(
                                        session: session,
                                        isSelected: viewModel.selectedSession.id == session.id
                                    ) {
                                        guard !viewModel.isRunning else { return }
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            viewModel.selectedSession = session
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 4)
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)

                        // ── Ambient Sound Picker ──
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ambient Sound")
                                .font(AppFont.caption(11, weight: .semibold))
                                .tracking(1.5)
                                .foregroundStyle(AppColors.lavender.opacity(0.7))
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
                        .padding(.top, 14)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 8)

                        Spacer(minLength: 20)

                        // ── Sacred Invocation (pre-session) ──
                        if !viewModel.isRunning && !viewModel.isComplete {
                            invocationCard
                                .padding(.horizontal, 24)
                                .padding(.bottom, 20)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // ── Breathing Orb ──
                        breathingOrb
                            .padding(.vertical, 8)

                        Spacer(minLength: 16)

                        // ── Session name + breath pattern ──
                        VStack(spacing: 5) {
                            Text(viewModel.selectedSession.name)
                                .font(AppFont.serifTitle(18))
                                .foregroundStyle(AppColors.cream)
                            Text("Box breathing  ·  4 · 4 · 4 · 4")
                                .font(AppFont.caption(11))
                                .tracking(0.8)
                                .foregroundStyle(AppColors.lavender.opacity(0.6))
                        }
                        .padding(.bottom, 24)

                        DisclaimerFooter()

                        // ── Start / Stop Button ──
                        beginButton
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
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) { appeared = true }
            if !disclaimerAcked { showDisclaimer = true }
        }
        .sheet(isPresented: $showDisclaimer) { WellnessDisclaimerSheet() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { viewModel.syncToWallClock() }
        }
        .onDisappear { viewModel.stop() }
        .animation(.easeInOut(duration: 0.3), value: viewModel.isRunning)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isComplete)
    }

    // MARK: - Deity Header

    private var deityHeader: some View {
        HStack(spacing: 14) {
            // Deity orb
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                viewModel.selectedSession.deityColor.opacity(0.5),
                                viewModel.selectedSession.deityColor.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 26
                        )
                    )
                    .frame(width: 52, height: 52)

                Circle()
                    .strokeBorder(viewModel.selectedSession.deityColor.opacity(0.4), lineWidth: 1)
                    .frame(width: 52, height: 52)

                Image(systemName: viewModel.selectedSession.deitySymbol)
                    .font(.system(size: 20))
                    .foregroundStyle(viewModel.selectedSession.deityColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("CHANNELLING")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .tracking(2.5)
                    .foregroundStyle(AppColors.lavender.opacity(0.55))

                Text(viewModel.selectedSession.deity)
                    .font(AppFont.serifTitle(17))
                    .foregroundStyle(viewModel.selectedSession.deityColor)

                Text(viewModel.selectedSession.subtitle)
                    .font(AppFont.caption(12))
                    .foregroundStyle(AppColors.lavender.opacity(0.65))
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Invocation Card

    private var invocationCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "quote.opening")
                .font(.system(size: 18))
                .foregroundStyle(viewModel.selectedSession.deityColor.opacity(0.7))

            Text(viewModel.selectedSession.invocation)
                .font(AppFont.serifHeadline(14))
                .foregroundStyle(AppColors.cream.opacity(0.85))
                .italic()
                .multilineTextAlignment(.leading)
                .lineSpacing(4)

            Spacer(minLength: 0)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(viewModel.selectedSession.deityColor.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(viewModel.selectedSession.deityColor.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Breathing Orb

    private var breathingOrb: some View {
        ZStack {
            // Outer ambient glow
            Circle()
                .fill(viewModel.selectedSession.color.opacity(0.10))
                .frame(width: 280, height: 280)
                .scaleEffect(viewModel.orbScale * 1.2)
                .blur(radius: 30)
                .animation(.easeInOut(duration: viewModel.currentPhase.duration), value: viewModel.orbScale)

            // Deity energy ring
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            viewModel.selectedSession.deityColor.opacity(0.5),
                            viewModel.selectedSession.deityColor.opacity(0.1),
                            viewModel.selectedSession.deityColor.opacity(0.4),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .frame(width: 240, height: 240)
                .scaleEffect(viewModel.orbScale * 1.08)
                .animation(.easeInOut(duration: viewModel.currentPhase.duration), value: viewModel.orbScale)

            // Mid ring
            Circle()
                .strokeBorder(viewModel.selectedSession.color.opacity(0.22), lineWidth: 1)
                .frame(width: 215, height: 215)
                .scaleEffect(viewModel.orbScale * 1.04)
                .animation(.easeInOut(duration: viewModel.currentPhase.duration), value: viewModel.orbScale)

            // Core orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            viewModel.selectedSession.color.opacity(0.9),
                            viewModel.selectedSession.color.opacity(0.35),
                            viewModel.selectedSession.color.opacity(0.05),
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 108
                    )
                )
                .frame(width: 210, height: 210)
                .scaleEffect(viewModel.orbScale)
                .animation(.easeInOut(duration: viewModel.currentPhase.duration), value: viewModel.orbScale)

            // Inner content
            orbContent
        }
    }

    @ViewBuilder
    private var orbContent: some View {
        if viewModel.isRunning {
            VStack(spacing: 8) {
                // Deity symbol
                Image(systemName: viewModel.selectedSession.deitySymbol)
                    .font(.system(size: 20))
                    .foregroundStyle(viewModel.selectedSession.deityColor.opacity(0.9))
                    .scaleEffect(viewModel.orbScale > 1.0 ? 1.1 : 0.95)
                    .animation(.easeInOut(duration: viewModel.currentPhase.duration), value: viewModel.orbScale)

                Text(viewModel.currentPhase.instruction)
                    .font(AppFont.serifHeadline(20))
                    .foregroundStyle(.white)
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.4), value: viewModel.currentPhase)

                Text(viewModel.timeString)
                    .font(AppFont.body(13))
                    .foregroundStyle(.white.opacity(0.55))
                    .monospacedDigit()
            }
        } else if viewModel.isComplete {
            VStack(spacing: 8) {
                Image(systemName: viewModel.selectedSession.deitySymbol)
                    .font(.system(size: 28))
                    .foregroundStyle(viewModel.selectedSession.deityColor)
                Text("Sacred")
                    .font(AppFont.caption(11))
                    .tracking(2)
                    .foregroundStyle(AppColors.lavender.opacity(0.7))
                Text("Complete")
                    .font(AppFont.serifHeadline(20))
                    .foregroundStyle(.white)
            }
        } else {
            VStack(spacing: 8) {
                Image(systemName: viewModel.selectedSession.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(viewModel.selectedSession.color)
                Text(viewModel.selectedSession.subtitle)
                    .font(AppFont.caption(12))
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
    }

    // MARK: - Begin Button

    private var beginButton: some View {
        Button {
            if viewModel.isRunning {
                HapticManager.impact(.medium)
                viewModel.stop()
            } else {
                HapticManager.notification(.success)
                viewModel.start()
            }
        } label: {
            HStack(spacing: 10) {
                if !viewModel.isRunning {
                    Image(systemName: viewModel.selectedSession.deitySymbol)
                        .font(.system(size: 15))
                }
                Text(viewModel.isRunning ? "End Session" : "Begin Sacred Session")
                    .font(AppFont.body(16, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: 240)
            .frame(height: 54)
            .background(
                viewModel.isRunning
                    ? AnyShapeStyle(AppColors.deepViolet.opacity(0.9))
                    : AnyShapeStyle(
                        LinearGradient(
                            colors: [
                                viewModel.selectedSession.deityColor.opacity(0.9),
                                viewModel.selectedSession.color.opacity(0.8),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    ),
                in: Capsule()
            )
            .overlay(
                Capsule().strokeBorder(
                    viewModel.isRunning
                        ? AppColors.purple.opacity(0.4)
                        : viewModel.selectedSession.deityColor.opacity(0.3),
                    lineWidth: 1
                )
            )
            .shadow(color: viewModel.selectedSession.deityColor.opacity(viewModel.isRunning ? 0 : 0.3), radius: 14, y: 4)
        }
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
                ZStack {
                    Circle()
                        .fill(session.deityColor.opacity(isSelected ? 0.3 : 0.12))
                        .frame(width: 26, height: 26)
                    Image(systemName: session.deitySymbol)
                        .font(.system(size: 11))
                        .foregroundStyle(isSelected ? .white : session.deityColor)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(session.name)
                        .font(AppFont.body(12, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? .white : AppColors.cream)
                    Text(session.deity)
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .tracking(0.3)
                        .foregroundStyle(isSelected ? session.deityColor.opacity(0.8) : AppColors.lavender.opacity(0.5))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                isSelected
                    ? session.color.opacity(0.25)
                    : AppColors.deepViolet.opacity(0.65),
                in: Capsule()
            )
            .overlay(
                Capsule().strokeBorder(
                    isSelected ? session.deityColor.opacity(0.6) : AppColors.purple.opacity(0.25),
                    lineWidth: 1
                )
            )
        }
        .buttonStyle(.plain)
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
                    .font(AppFont.body(12, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .white : AppColors.lavender)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isSelected ? AppColors.purple.opacity(0.65) : AppColors.deepViolet.opacity(0.5),
                in: Capsule()
            )
            .overlay(
                Capsule().strokeBorder(
                    isSelected ? AppColors.purple : AppColors.purple.opacity(0.22),
                    lineWidth: 1
                )
            )
        }
        .buttonStyle(.plain)
    }
}
