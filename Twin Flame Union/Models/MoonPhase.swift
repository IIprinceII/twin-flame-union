//
//  MoonPhase.swift
//  Twin Flame Union
//
//  Pure-math lunar phase calculator — no API needed.
//

import Foundation

struct MoonPhase {
    let name: String
    let emoji: String
    let meaning: String
    let illumination: Double  // 0–1

    static func current() -> MoonPhase {
        // Reference new moon: 6 Jan 2000 18:14 UTC
        let referenceNewMoon = Date(timeIntervalSince1970: 947182440)
        let lunarCycleSeconds = 29.53058867 * 86400

        let elapsed = Date().timeIntervalSince(referenceNewMoon)
        let phase = (elapsed.truncatingRemainder(dividingBy: lunarCycleSeconds)) / lunarCycleSeconds

        let illumination = 0.5 * (1 - cos(2 * .pi * phase))

        switch phase {
        case 0..<0.0625, 0.9375...:
            return MoonPhase(name: "New Moon",         emoji: "🌑", meaning: "Plant seeds of intention",       illumination: illumination)
        case 0.0625..<0.1875:
            return MoonPhase(name: "Waxing Crescent",  emoji: "🌒", meaning: "Build momentum",                 illumination: illumination)
        case 0.1875..<0.3125:
            return MoonPhase(name: "First Quarter",    emoji: "🌓", meaning: "Take decisive action",           illumination: illumination)
        case 0.3125..<0.4375:
            return MoonPhase(name: "Waxing Gibbous",   emoji: "🌔", meaning: "Refine and trust the process",   illumination: illumination)
        case 0.4375..<0.5625:
            return MoonPhase(name: "Full Moon",        emoji: "🌕", meaning: "Illuminate your truth",          illumination: illumination)
        case 0.5625..<0.6875:
            return MoonPhase(name: "Waning Gibbous",   emoji: "🌖", meaning: "Share your wisdom",              illumination: illumination)
        case 0.6875..<0.8125:
            return MoonPhase(name: "Last Quarter",     emoji: "🌗", meaning: "Release what no longer serves",  illumination: illumination)
        default:
            return MoonPhase(name: "Waning Crescent",  emoji: "🌘", meaning: "Rest and surrender",             illumination: illumination)
        }
    }
}

// MARK: - Streak Tracker

struct StreakTracker {
    private static let defaults = UserDefaults.standard

    static var current: Int { defaults.integer(forKey: "streakCount") }

    @discardableResult
    static func checkIn() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let lastDate = defaults.object(forKey: "lastOpenDate") as? Date
        var streak = defaults.integer(forKey: "streakCount")

        if let last = lastDate {
            let lastDay = Calendar.current.startOfDay(for: last)
            let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 0 { return streak }   // already checked in today
            if diff == 1 { streak += 1 }     // consecutive day
            else { streak = 1 }              // streak broken
        } else {
            streak = 1  // first ever open
        }

        defaults.set(streak, forKey: "streakCount")
        defaults.set(today, forKey: "lastOpenDate")
        return streak
    }
}
