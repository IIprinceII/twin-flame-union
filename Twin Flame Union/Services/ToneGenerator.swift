//
//  ToneGenerator.swift
//  Twin Flame Union
//
//  Global singleton tone generator — persists across navigation and in background.
//

import AVFoundation
import SwiftUI

@Observable
@MainActor
final class ToneGenerator {
    // MARK: Public state (observed by views)
    var isPlaying = false
    var currentFrequency: Double = 0
    var currentFrequencyName: String = ""
    var currentFrequencyColor: Color = .clear
    var elapsedSeconds = 0

    // MARK: Private
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private var timerTask: Task<Void, Never>?
    private var audioObservers: [NSObjectProtocol] = []

    // MARK: Playback

    func play(frequency: Double, name: String, color: Color) {
        stop()
        currentFrequency = frequency
        currentFrequencyName = name
        currentFrequencyColor = color
        elapsedSeconds = 0

        let sr = engine.outputNode.outputFormat(forBus: 0).sampleRate
        let sampleRate = sr == 0 ? 44100.0 : sr
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else { return }

        // The render block runs on a realtime audio thread. It must NOT read
        // MainActor-isolated state. Capture the frequency once (it never changes
        // mid-playback — play() always stops first) into a plain holder the audio
        // thread alone mutates.
        let state = ToneState(phaseInc: 2.0 * .pi * frequency / sampleRate)
        let node = AVAudioSourceNode { _, _, frameCount, audioBufferList in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for frame in 0..<Int(frameCount) {
                let value = Float(sin(state.phase)) * 0.25
                state.phase += state.phaseInc
                if state.phase > 2.0 * .pi { state.phase -= 2.0 * .pi }
                for buf in ablPointer {
                    UnsafeMutableBufferPointer<Float>(buf)[frame] = value
                }
            }
            return noErr
        }
        sourceNode = node

        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
            isPlaying = true
            startTimer()
            registerAudioObservers()
        } catch {
            stop()
        }
    }

    func stop() {
        timerTask?.cancel()
        timerTask = nil
        if let node = sourceNode {
            engine.detach(node)
            sourceNode = nil
        }
        if engine.isRunning { engine.stop() }
        isPlaying = false
        currentFrequency = 0
        currentFrequencyName = ""
        currentFrequencyColor = .clear
        elapsedSeconds = 0
    }

    // MARK: Timer

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard let self, !Task.isCancelled else { return }
                await MainActor.run { self.elapsedSeconds += 1 }
            }
        }
    }

    // MARK: Audio session handling

    // Stop cleanly when the system interrupts audio (phone call, Siri) or the
    // output route disappears (headphones unplugged) — otherwise isPlaying and the
    // timer desync from reality.
    private func registerAudioObservers() {
        guard audioObservers.isEmpty else { return }
        let nc = NotificationCenter.default
        let session = AVAudioSession.sharedInstance()

        let interruption = nc.addObserver(
            forName: AVAudioSession.interruptionNotification, object: session, queue: .main
        ) { [weak self] note in
            guard let self,
                  let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: raw),
                  type == .began else { return }
            MainActor.assumeIsolated { self.stop() }
        }

        let routeChange = nc.addObserver(
            forName: AVAudioSession.routeChangeNotification, object: session, queue: .main
        ) { [weak self] note in
            guard let self,
                  let raw = note.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
                  let reason = AVAudioSession.RouteChangeReason(rawValue: raw),
                  reason == .oldDeviceUnavailable else { return }
            MainActor.assumeIsolated { self.stop() }
        }

        audioObservers = [interruption, routeChange]
    }

    deinit {
        audioObservers.forEach { NotificationCenter.default.removeObserver($0) }
    }
}

// Plain reference holder for the realtime audio render thread. Only the audio
// thread mutates `phase` after creation, so it never races with the main actor.
private final class ToneState: @unchecked Sendable {
    var phase: Double = 0
    let phaseInc: Double
    init(phaseInc: Double) { self.phaseInc = phaseInc }
}
