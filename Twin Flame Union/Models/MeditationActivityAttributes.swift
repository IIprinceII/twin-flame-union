//
//  MeditationActivityAttributes.swift
//  Twin Flame Union
//
//  Shared between main app and TFWidgets extension.
//  ⚠️ Add this file to BOTH targets in Xcode (main app + TFWidgets).
//

import ActivityKit
import Foundation

struct MeditationActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var endDate: Date
        var phase: String
        var isRunning: Bool
        var sessionName: String
    }

    let sessionName: String
    let totalDuration: TimeInterval
}
