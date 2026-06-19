//
//  PairingService.swift
//  Twin Flame Union
//
//  Manages twin-flame pairing via the Supabase `pairings` table + `accept_pairing` RPC.
//  Active pairing id is persisted via UserDefaults (key "activePairingId").
//

import Foundation
import Security

// MARK: - Pairing Model

struct Pairing: Codable, Identifiable {
    let id: String
    let inviteCode: String
    let creatorId: String
    let partnerId: String?
    let status: String         // "pending" | "active"
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case inviteCode  = "invite_code"
        case creatorId   = "creator_id"
        case partnerId   = "partner_id"
        case status
        case createdAt   = "created_at"
    }

    var isActive: Bool {
        status == "active" || partnerId != nil
    }
}

// MARK: - Insert Body

private struct PairingInsert: Encodable {
    let invite_code: String
}

// MARK: - PairingService

enum PairingService {

    // MARK: - Local State Key

    static let activePairingIdKey = "activePairingId"

    // MARK: - Pure Helper — Invite Code Generator

    /// Generates a cryptographically-random 8-character invite code from an
    /// unambiguous base32 alphabet (no 0/O/1/I to avoid visual confusion).
    static func generateInviteCode() -> String {
        // Unambiguous base32 subset: 32 chars — excludes 0, O, 1, I
        let alphabet: [Character] = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        var bytes = [UInt8](repeating: 0, count: 8)
        _ = SecRandomCopyBytes(kSecRandomDefault, 8, &bytes)
        return String(bytes.map { alphabet[Int($0) % alphabet.count] })
    }

    // MARK: - Fetch My Pairing

    /// GET pairings — RLS returns only rows where creator_id or partner_id = auth.uid().
    /// Returns the most recent result.
    @MainActor
    static func myPairing() async throws -> Pairing? {
        let data = try await SupabaseClient.shared.authedRequest(
            method: "GET",
            path: "pairings",
            query: ["select": "*", "order": "created_at.desc", "limit": "1"],
            extraHeaders: ["Accept": "application/json"]
        )
        let pairings = try JSONDecoder().decode([Pairing].self, from: data)
        return pairings.first
    }

    // MARK: - Create Invite

    /// Inserts a new pairing row with a generated invite code.
    /// creator_id defaults server-side to auth.uid().
    @MainActor
    static func createInvite() async throws -> Pairing {
        let code = generateInviteCode()
        let insert = PairingInsert(invite_code: code)
        let body = try JSONEncoder().encode(insert)

        let data = try await SupabaseClient.shared.authedRequest(
            method: "POST",
            path: "pairings",
            body: body,
            extraHeaders: [
                "Prefer": "return=representation",
                "Accept": "application/json"
            ]
        )

        // Supabase returns an array with Prefer: return=representation
        let pairings = try JSONDecoder().decode([Pairing].self, from: data)
        guard let pairing = pairings.first else { throw SupabaseError.unexpectedResponse }
        UserDefaults.standard.set(pairing.id, forKey: activePairingIdKey)
        return pairing
    }

    // MARK: - Accept Invite

    /// Calls the `accept_pairing(p_code)` RPC which links partner_id to auth.uid()
    /// and sets status = 'active'. Returns the updated pairing.
    @MainActor
    static func acceptInvite(code: String) async throws -> Pairing {
        let data = try await SupabaseClient.shared.rpc("accept_pairing", params: ["p_code": code])
        // RPC returns a single row object (not an array)
        let pairing = try JSONDecoder().decode(Pairing.self, from: data)
        UserDefaults.standard.set(pairing.id, forKey: activePairingIdKey)
        return pairing
    }
}
