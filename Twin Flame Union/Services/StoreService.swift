//
//  StoreService.swift
//  Twin Flame Union
//
//  All features are currently free. This stub keeps the rest of the app
//  compiling. Re-add StoreKit logic when ready to monetise.
//

import SwiftUI

@Observable
@MainActor
final class StoreService {
    static let shared = StoreService()
    let isPremium: Bool = true
    let isLoading: Bool = false
    private init() {}
}
