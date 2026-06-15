//
//  HealthService.swift
//  Twin Flame Union
//
//  HealthKit wrapper for mindful session logging.
//

import Foundation
import SwiftUI

#if canImport(HealthKit)
import HealthKit
#endif

// MARK: - HealthService

@MainActor
final class HealthService {

    static let shared = HealthService()

    private init() {}

    // MARK: - Availability

    var isAvailable: Bool {
        #if canImport(HealthKit)
        return HKHealthStore.isHealthDataAvailable()
        #else
        return false
        #endif
    }

    var isAuthorized: Bool = false

    // MARK: - Authorization

    func requestAuthorization() async throws {
        guard isAvailable else { return }

        #if canImport(HealthKit)
        let store = HKHealthStore()
        guard let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else { return }

        let typesToShare: Set<HKSampleType> = [mindfulType]
        let typesToRead: Set<HKObjectType> = [mindfulType]

        try await store.requestAuthorization(toShare: typesToShare, read: typesToRead)
        isAuthorized = true
        #endif
    }

    // MARK: - Log Mindful Session

    func logMindfulSession(duration: TimeInterval) async throws {
        guard isAvailable, isAuthorized else { return }

        #if canImport(HealthKit)
        let store = HKHealthStore()
        guard let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else { return }

        let end = Date()
        let start = end.addingTimeInterval(-duration)

        let sample = HKCategorySample(
            type: mindfulType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: start,
            end: end
        )

        try await store.save(sample)
        #endif
    }

    // MARK: - Fetch Recent Sessions

    func fetchRecentSessions(days: Int) async -> [Any] {
        guard isAvailable, isAuthorized else { return [] }

        #if canImport(HealthKit)
        let store = HKHealthStore()
        guard let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else { return [] }

        let since = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: since, end: Date(), options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: mindfulType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, _ in
                continuation.resume(returning: samples ?? [])
            }
            store.execute(query)
        }
        #else
        return []
        #endif
    }

    // MARK: - Typed Fetch (HealthKit only)

    #if canImport(HealthKit)
    func fetchRecentHKSessions(days: Int) async -> [HKCategorySample] {
        let results = await fetchRecentSessions(days: days)
        return results.compactMap { $0 as? HKCategorySample }
    }
    #endif
}
