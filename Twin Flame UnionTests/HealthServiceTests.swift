import Testing
import HealthKit
@testable import The_Twin_Flame_Union_App

struct HealthServiceTests {

    // The exact bug: the old code claimed authorization regardless of the real status.
    // Only `.sharingAuthorized` may count as authorized.
    @Test func onlySharingAuthorizedCountsAsAuthorized() {
        #expect(HealthService.isShareAuthorized(.sharingAuthorized) == true)
        #expect(HealthService.isShareAuthorized(.sharingDenied) == false)
        #expect(HealthService.isShareAuthorized(.notDetermined) == false)
    }

    // On the simulator with no prior grant, the live property must be false (not a stale true).
    @Test @MainActor func isAuthorizedFalseWhenNotGranted() {
        #expect(HealthService.shared.isAuthorized == false)
    }
}
