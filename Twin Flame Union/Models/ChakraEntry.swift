//
//  ChakraEntry.swift
//  Twin Flame Union
//
//  SwiftData model for daily chakra alignment check-ins.
//  Each chakra is rated 1–5: 1 = blocked, 3 = balanced, 5 = overactive.
//

import Foundation
import SwiftData

@Model
final class ChakraEntry {
    var id: UUID = UUID()
    var date: Date = Date()
    var root: Int = 3
    var sacral: Int = 3
    var solarPlexus: Int = 3
    var heart: Int = 3
    var throat: Int = 3
    var thirdEye: Int = 3
    var crown: Int = 3
    var note: String = ""

    init(date: Date = Date(),
         root: Int = 3, sacral: Int = 3, solarPlexus: Int = 3,
         heart: Int = 3, throat: Int = 3, thirdEye: Int = 3,
         crown: Int = 3, note: String = "") {
        self.id          = UUID()
        self.date        = date
        self.root        = root
        self.sacral      = sacral
        self.solarPlexus = solarPlexus
        self.heart       = heart
        self.throat      = throat
        self.thirdEye    = thirdEye
        self.crown       = crown
        self.note        = note
    }
}
