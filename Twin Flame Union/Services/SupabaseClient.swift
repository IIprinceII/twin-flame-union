//
//  SupabaseClient.swift
//  Twin Flame Union
//
//  Raw URLSession-based Supabase client — no external dependencies.
//  Session persistence: UserDefaults (v1; Keychain is the right long-term home).
//  Stored keys:
//    • "sb_access_token"
//    • "sb_refresh_token"
//    • "sb_user_id"
//

import Foundation

// MARK: - Errors

enum SupabaseError: LocalizedError {
    case missingConfig
    case anonymousProviderDisabled         // 422 anonymous_provider_disabled
    case invalidOrTakenCode                // RPC reject
    case httpError(Int, String)
    case unexpectedResponse

    var errorDescription: String? {
        switch self {
        case .missingConfig:
            return "Supabase URL or anon key not configured in Config.plist."
        case .anonymousProviderDisabled:
            return "Anonymous sign-in is not yet enabled on this project. The owner must enable it in the Supabase dashboard under Authentication → Providers → Anonymous."
        case .invalidOrTakenCode:
            return "That invite code is invalid or has already been used."
        case .httpError(let status, let message):
            return "Server error \(status): \(message)"
        case .unexpectedResponse:
            return "Unexpected response from the server."
        }
    }
}

// MARK: - Auth Response

private struct AuthResponse: Decodable {
    let access_token: String
    let refresh_token: String
    let user: AuthUser
}

private struct AuthUser: Decodable {
    let id: String
}

// MARK: - Supabase Error Body

private struct SupabaseErrorBody: Decodable {
    let error: String?
    let error_description: String?
    let message: String?
    let code: String?
}

// MARK: - SupabaseClient

@MainActor
final class SupabaseClient {

    static let shared = SupabaseClient()
    private init() {}

    // MARK: - Persisted Session (UserDefaults — v1)

    private(set) var currentUserId: String? {
        get { UserDefaults.standard.string(forKey: "sb_user_id") }
        set { UserDefaults.standard.set(newValue, forKey: "sb_user_id") }
    }

    private var accessToken: String? {
        get { UserDefaults.standard.string(forKey: "sb_access_token") }
        set { UserDefaults.standard.set(newValue, forKey: "sb_access_token") }
    }

    private var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: "sb_refresh_token") }
        set { UserDefaults.standard.set(newValue, forKey: "sb_refresh_token") }
    }

    // MARK: - Config

    func loadConfig() throws -> (baseURL: String, anonKey: String) {
        guard
            let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
            let config = NSDictionary(contentsOfFile: path),
            let baseURL = config["SUPABASE_URL"] as? String,
            let anonKey = config["SUPABASE_ANON_KEY"] as? String,
            !baseURL.isEmpty, !anonKey.isEmpty
        else { throw SupabaseError.missingConfig }
        return (baseURL, anonKey)
    }

    // MARK: - Sign In Anonymously

    func signInAnonymously() async throws {
        let (baseURL, anonKey) = try loadConfig()

        guard let url = URL(string: "\(baseURL)/auth/v1/signup") else {
            throw SupabaseError.missingConfig
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(anonKey, forHTTPHeaderField: "apikey")
        // Empty body → anonymous sign-in
        req.httpBody = try JSONSerialization.data(withJSONObject: [:])

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw SupabaseError.unexpectedResponse
        }

        if http.statusCode == 422 {
            if let body = try? JSONDecoder().decode(SupabaseErrorBody.self, from: data),
               body.error == "anonymous_provider_disabled" || body.code == "anonymous_provider_disabled" {
                throw SupabaseError.anonymousProviderDisabled
            }
            // Any other 422 also surfaces as anonymous disabled (most likely cause)
            throw SupabaseError.anonymousProviderDisabled
        }

        guard (200..<300).contains(http.statusCode) else {
            let msg = parseErrorMessage(from: data) ?? "HTTP \(http.statusCode)"
            throw SupabaseError.httpError(http.statusCode, msg)
        }

        let auth = try JSONDecoder().decode(AuthResponse.self, from: data)
        accessToken   = auth.access_token
        refreshToken  = auth.refresh_token
        currentUserId = auth.user.id
    }

    // MARK: - Refresh Token

    func refreshSession() async throws {
        guard let rt = refreshToken else {
            try await signInAnonymously()
            return
        }

        let (baseURL, anonKey) = try loadConfig()
        guard let url = URL(string: "\(baseURL)/auth/v1/token?grant_type=refresh_token") else {
            throw SupabaseError.missingConfig
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(anonKey, forHTTPHeaderField: "apikey")
        req.httpBody = try JSONSerialization.data(withJSONObject: ["refresh_token": rt])

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw SupabaseError.unexpectedResponse
        }

        guard (200..<300).contains(http.statusCode) else {
            // Refresh token expired — sign in fresh
            accessToken   = nil
            refreshToken  = nil
            currentUserId = nil
            try await signInAnonymously()
            return
        }

        let auth = try JSONDecoder().decode(AuthResponse.self, from: data)
        accessToken   = auth.access_token
        refreshToken  = auth.refresh_token
        currentUserId = auth.user.id
    }

    // MARK: - Ensure Session

    /// Signs in anonymously if no session exists. Refreshes if a refresh token is on hand.
    func ensureSession() async throws {
        if accessToken == nil {
            try await signInAnonymously()
        } else if refreshToken != nil {
            try await refreshSession()
        }
    }

    // MARK: - Authenticated REST Request

    func authedRequest(
        method: String,
        path: String,
        query: [String: String] = [:],
        body: Data? = nil,
        extraHeaders: [String: String] = [:]
    ) async throws -> Data {
        try await ensureSession()

        let (baseURL, anonKey) = try loadConfig()

        guard let token = accessToken else { throw SupabaseError.unexpectedResponse }

        guard var components = URLComponents(string: "\(baseURL)/rest/v1/\(path)") else {
            throw SupabaseError.missingConfig
        }
        if !query.isEmpty {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = components.url else { throw SupabaseError.missingConfig }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(anonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        for (key, value) in extraHeaders {
            req.setValue(value, forHTTPHeaderField: key)
        }
        req.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw SupabaseError.unexpectedResponse
        }

        guard (200..<300).contains(http.statusCode) else {
            // Surface RPC domain errors
            if let errBody = try? JSONDecoder().decode(SupabaseErrorBody.self, from: data),
               errBody.message == "invalid_or_taken_code" || errBody.code == "invalid_or_taken_code" {
                throw SupabaseError.invalidOrTakenCode
            }
            let msg = parseErrorMessage(from: data) ?? "HTTP \(http.statusCode)"
            throw SupabaseError.httpError(http.statusCode, msg)
        }

        return data
    }

    // MARK: - RPC Convenience

    func rpc(_ name: String, params: [String: String]) async throws -> Data {
        let body = try JSONSerialization.data(withJSONObject: params)
        return try await authedRequest(method: "POST", path: "rpc/\(name)", body: body)
    }

    // MARK: - Helpers

    private func parseErrorMessage(from data: Data) -> String? {
        if let body = try? JSONDecoder().decode(SupabaseErrorBody.self, from: data) {
            return body.error_description ?? body.message ?? body.error
        }
        return nil
    }
}
