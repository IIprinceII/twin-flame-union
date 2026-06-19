//
//  StoreService.swift
//  Twin Flame Union
//
//  Real StoreKit 2 purchase/restore/entitlement machine.
//
//  ─── GATING SAFETY SWITCH ───────────────────────────────────────────────────
//  `premiumEnforced` defaults to FALSE (stored in UserDefaults).
//  While it is false, `isPremium` returns true for EVERYONE — no features lock,
//  no behaviour changes for the owner or any user.
//
//  When the App Store Connect product is live and tested:
//    1. Flip premiumEnforced to true in UserDefaults key "premiumEnforced"
//       (e.g. via a hidden developer toggle in Settings).
//    2. Only users with an active entitlement for `productID` will get premium.
//
//  The StoreKit machinery (purchase, restore, transaction observer) is ALWAYS
//  active so the owner can test the full purchase flow in the simulator using
//  the TwinFlameUnion.storekit configuration file before flipping the gate.
//  ────────────────────────────────────────────────────────────────────────────
//
//  NOTE ON @Observable + @AppStorage INCOMPATIBILITY:
//  Swift 5.9+ @Observable synthesises a `_propertyName` backing store for every
//  stored property. @AppStorage also synthesises a `_propertyName` wrapper, so
//  the two macros collide and produce an "invalid redeclaration" error when used
//  together. The workaround is to drive UserDefaults directly via a computed
//  property and call `withMutation` / access tracking explicitly.
//  ────────────────────────────────────────────────────────────────────────────

import StoreKit
import SwiftUI

// MARK: - UserDefaults key

private let kPremiumEnforced = "premiumEnforced"

@Observable
@MainActor
final class StoreService {

    // MARK: - Singleton

    static let shared = StoreService()

    // MARK: - Product ID

    let productID = "com.twinflameunion.premium.weekly"

    // MARK: - Published State

    /// The loaded StoreKit product (nil until `loadProduct()` completes).
    private(set) var product: Product?

    /// True when StoreKit confirms an active, non-revoked subscription.
    private(set) var hasActivePremium: Bool = false

    /// True while a purchase or restore is in progress.
    private(set) var isLoading: Bool = false

    /// Non-nil when a purchase or restore operation fails.
    private(set) var purchaseError: String?

    // MARK: - Enforcement Gate
    //
    // Computed property backed by UserDefaults to avoid the @Observable / @AppStorage
    // macro conflict. Setting this to `true` is the ONLY change needed to activate
    // real feature gating once the ASC product is approved.

    var premiumEnforced: Bool {
        get {
            access(keyPath: \.premiumEnforced)
            return UserDefaults.standard.bool(forKey: kPremiumEnforced)
        }
        set {
            withMutation(keyPath: \.premiumEnforced) {
                UserDefaults.standard.set(newValue, forKey: kPremiumEnforced)
            }
        }
    }

    // MARK: - Pure Decision Helper (also used by tests)

    /// Determines whether a user should be treated as premium.
    /// Extracted as a pure static function so it can be unit-tested
    /// without touching StoreKit.
    nonisolated static func resolvePremium(hasActive: Bool, enforced: Bool) -> Bool {
        // When enforcement is off (default), everyone is premium.
        // When enforcement is on, only users with an active entitlement are.
        enforced ? hasActive : true
    }

    // MARK: - Computed isPremium

    /// The value all feature-gate call sites read.
    var isPremium: Bool {
        Self.resolvePremium(hasActive: hasActivePremium, enforced: premiumEnforced)
    }

    // MARK: - Init

    private init() {
        Task {
            await loadProduct()
            await refreshEntitlement()
            await observeTransactions()
        }
    }

    // MARK: - Load Product

    /// Fetches the product metadata from StoreKit (or the local .storekit config in the simulator).
    func loadProduct() async {
        do {
            let products = try await Product.products(for: [productID])
            product = products.first
        } catch {
            // Non-fatal — the paywall will show without a live price.
            print("[StoreService] loadProduct failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Purchase

    /// Initiates a purchase for the weekly subscription.
    func purchase() async {
        guard let product else {
            purchaseError = "Product not available — please check your connection and try again."
            return
        }

        isLoading = true
        purchaseError = nil
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshEntitlement()

            case .userCancelled:
                break   // User tapped Cancel — not an error.

            case .pending:
                // Ask-to-Buy or deferred — entitlement will arrive via observeTransactions.
                purchaseError = "Purchase is pending approval."

            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    // MARK: - Restore

    /// Triggers an App Store sync to restore prior purchases.
    func restore() async {
        isLoading = true
        purchaseError = nil
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await refreshEntitlement()
        } catch {
            purchaseError = "Restore failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Entitlement Refresh

    /// Walks `Transaction.currentEntitlements` to determine active subscription status.
    func refreshEntitlement() async {
        var foundActive = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == productID,
               transaction.revocationDate == nil {
                foundActive = true
                break
            }
        }
        hasActivePremium = foundActive
    }

    // MARK: - Transaction Observer

    /// Continuously listens for new transactions (renewals, refunds, revocations)
    /// for the lifetime of the app.
    private func observeTransactions() async {
        for await result in Transaction.updates {
            do {
                let transaction = try checkVerified(result)
                await refreshEntitlement()
                await transaction.finish()
            } catch {
                print("[StoreService] Unverified transaction: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Verification Helper

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }
}
