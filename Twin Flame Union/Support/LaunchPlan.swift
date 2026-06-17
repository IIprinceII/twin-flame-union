//
//  LaunchPlan.swift
//  Twin Flame Union
//
//  Decides how the launch animation plays. Pure + testable.
//

import Foundation

enum LaunchMode: Equatable { case full, brief, staticLogo }

enum LaunchPlan {
    static let seenKey = "hasSeenLaunchAnimation"

    /// Reduce Motion → instant static logo. Otherwise the full sequence the first time,
    /// then a brief fade on later launches.
    static func mode(hasSeen: Bool, reduceMotion: Bool) -> LaunchMode {
        if reduceMotion { return .staticLogo }
        return hasSeen ? .brief : .full
    }
}
