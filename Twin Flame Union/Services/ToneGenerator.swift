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
    private var phase: Double = 0
    private var timerTask: Task<Void, Never>?

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

        let node = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList in
            guard let self else { return noErr }
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let phaseInc = 2.0 * .pi * self.currentFrequency / sampleRate
            for frame in 0..<Int(frameCount) {
                let value = Float(sin(self.phase)) * 0.25
                self.phase += phaseInc
                if self.phase > 2.0 * .pi { self.phase -= 2.0 * .pi }
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
        phase = 0
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
}
