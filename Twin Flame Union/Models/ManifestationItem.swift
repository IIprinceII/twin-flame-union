//
//  ManifestationItem.swift
//  Twin Flame Union
//
//  SwiftData model for manifestation board intentions.
//

import Foundation
import SwiftData

@Model
final class ManifestationItem {
    var id: UUID
    var intention: String
    var emoji: String
    var isManifested: Bool
    var createdAt: Date

    init(intention: String = "", emoji: String = "✨", isManifested: Bool = false) {
        self.id            = UUID()
        self.intention     = intention
        self.emoji         = emoji
        self.isManifested  = isManifested
        self.createdAt     = Date()
    }
}
