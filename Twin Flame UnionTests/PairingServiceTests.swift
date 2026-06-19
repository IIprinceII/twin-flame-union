//
//  PairingServiceTests.swift
//  Twin Flame UnionTests
//
//  Tests the PURE parts of PairingService — no network calls.
//

import Testing
import Foundation
@testable import The_Twin_Flame_Union_App

@MainActor
struct PairingServiceTests {

    // MARK: - generateInviteCode: Length

    @Test func inviteCodeIsEightCharacters() {
        let code = PairingService.generateInviteCode()
        #expect(code.count == 8, "Invite code must be exactly 8 characters, got \(code.count)")
    }

    // MARK: - generateInviteCode: Charset

    @Test func inviteCodeUsesOnlyUnambiguousCharacters() {
        // Unambiguous base32: A-Z minus O and I, digits 2-9 (no 0 or 1)
        let allowed = CharacterSet(charactersIn: "ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        let code = PairingService.generateInviteCode()
        for char in code.unicodeScalars {
            #expect(allowed.contains(char),
                    "Character '\(char)' in code '\(code)' is outside the unambiguous alphabet")
        }
    }

    @Test func inviteCodeContainsNoAmbiguousCharacters() {
        // Run many iterations to surface any alphabet bug
        let ambiguous = CharacterSet(charactersIn: "01OI")
        for _ in 0..<500 {
            let code = PairingService.generateInviteCode()
            for scalar in code.unicodeScalars {
                #expect(!ambiguous.contains(scalar),
                        "Ambiguous character '\(scalar)' found in code '\(code)'")
            }
        }
    }

    // MARK: - generateInviteCode: Uniqueness

    @Test func inviteCodesAreUnique() {
        // 1000 codes should all be distinct (collision probability is negligible for 8-char base32)
        var seen = Set<String>()
        for _ in 0..<1000 {
            let code = PairingService.generateInviteCode()
            #expect(!seen.contains(code), "Duplicate invite code generated: \(code)")
            seen.insert(code)
        }
    }

    // MARK: - Pairing JSON Decoding

    @Test func pairingDecodesSnakeCaseFields() throws {
        let json = """
        {
            "id": "pairing-uuid-0001",
            "invite_code": "ABCDE234",
            "creator_id": "user-uuid-0001",
            "partner_id": null,
            "status": "pending",
            "created_at": "2026-06-18T00:00:00Z"
        }
        """.data(using: .utf8)!

        let pairing = try JSONDecoder().decode(Pairing.self, from: json)

        #expect(pairing.id == "pairing-uuid-0001")
        #expect(pairing.inviteCode == "ABCDE234")
        #expect(pairing.creatorId == "user-uuid-0001")
        #expect(pairing.partnerId == nil)
        #expect(pairing.status == "pending")
        #expect(pairing.createdAt == "2026-06-18T00:00:00Z")
        #expect(pairing.isActive == false)
    }

    @Test func pairingDecodesWithPartnerAndActiveStatus() throws {
        let json = """
        {
            "id": "pairing-uuid-0002",
            "invite_code": "XYZ78923",
            "creator_id": "user-uuid-0001",
            "partner_id": "user-uuid-0002",
            "status": "active",
            "created_at": "2026-06-18T01:00:00Z"
        }
        """.data(using: .utf8)!

        let pairing = try JSONDecoder().decode(Pairing.self, from: json)

        #expect(pairing.partnerId == "user-uuid-0002")
        #expect(pairing.status == "active")
        #expect(pairing.isActive == true)
    }

    @Test func pairingIsActiveWhenPartnerPresentEvenIfStatusPending() throws {
        // Edge: server may set partner_id before updating status field
        let json = """
        {
            "id": "pairing-uuid-0003",
            "invite_code": "QRSTUV56",
            "creator_id": "user-uuid-0001",
            "partner_id": "user-uuid-0003",
            "status": "pending",
            "created_at": "2026-06-18T02:00:00Z"
        }
        """.data(using: .utf8)!

        let pairing = try JSONDecoder().decode(Pairing.self, from: json)
        // isActive = (status == "active" || partnerId != nil)
        #expect(pairing.isActive == true,
                "isActive should be true when partnerId is set, regardless of status string")
    }

    @Test func pairingArrayDecodesSuccessfully() throws {
        // Supabase REST returns arrays; verify array decode path used by myPairing()/createInvite()
        let json = """
        [
            {
                "id": "pairing-uuid-0004",
                "invite_code": "MNPQRS78",
                "creator_id": "user-uuid-0004",
                "partner_id": null,
                "status": "pending",
                "created_at": "2026-06-18T03:00:00Z"
            }
        ]
        """.data(using: .utf8)!

        let pairings = try JSONDecoder().decode([Pairing].self, from: json)
        #expect(pairings.count == 1)
        #expect(pairings[0].inviteCode == "MNPQRS78")
    }
}
