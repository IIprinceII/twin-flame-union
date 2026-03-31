//
//  StoreService.swift
//  Twin Flame Union
//
//  StoreKit 2 subscription management.
//

import StoreKit
import SwiftUI

// MARK: - Store Error

enum StoreError: LocalizedError {
    case unverified
    case purchaseFailed

    var errorDescription: String? {
        switch self {
        case .unverified:    return "The purchase could not be verified."
        case .purchaseFailed: return "The purchase did not complete. Please try again."
        }
    }
}

// MARK: - StoreService

@Observable
@MainActor
final class StoreService {

    static let shared = StoreService()

    private let productIDs: [String] = [
        "com.twinflameunion.premium.monthly",
        "com.twinflameunion.premium.annual"
    ]

    var products: [Product] = []
    var purchasedIDs: Set<String> = []
    var isPremium: Bool = false
    var isLoading: Bool = false

    nonisolated(unsafe) private var transactionUpdatesTask: Task<Void, Never>?

    private init() {
        transactionUpdatesTask = Task(priority: .background) { [weak self] in
            await self?.listenForTransactionUpdates()
        }
        Task {
            await loadProducts()
            await refreshPurchaseStatus()
        }
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let fetched = try await Product.products(for: productIDs)
            // Sort: monthly first, then annual
            products = fetched.sorted {
                $0.id.contains("monthly") && !$1.id.contains("monthly")
            }
        } catch {
            products = []
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws {
        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()

        case .userCancelled:
            break

        case .pending:
            break

        @unknown default:
            throw StoreError.purchaseFailed
        }
    }

    // MARK: - Restore

    func restore() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await AppStore.sync()
            await refreshPurchaseStatus()
        } catch {
            // Restore failed silently
        }
    }

    // MARK: - Verification Helper

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.unverified
        case .verified(let value):
            return value
        }
    }

    // MARK: - Refresh Purchase Status

    func refreshPurchaseStatus() async {
        await updatePurchasedProducts()
    }

    private func updatePurchasedProducts() async {
        var active: Set<String> = []

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.revocationDate == nil {
                    active.insert(transaction.productID)
                }
            } catch {
                continue
            }
        }

        purchasedIDs = active
        isPremium = !active.isEmpty
    }

    // MARK: - Background Transaction Listener

    private func listenForTransactionUpdates() async {
        for await result in Transaction.updates {
            do {
                let transaction = try checkVerified(result)
                await updatePurchasedProducts()
                await transaction.finish()
            } catch {
                continue
            }
        }
    }
}
