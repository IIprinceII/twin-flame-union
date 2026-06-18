import Testing
import Foundation
@testable import The_Twin_Flame_Union_App

struct ClaudeProxyServiceTests {
    // Supabase's edge-function gateway rejects calls with 401 "Missing authorization header"
    // unless the request carries `Authorization: Bearer <jwt>` IN ADDITION to the `apikey`
    // header. The anon key is a valid JWT and serves as the bearer token. This guards the
    // header that was missing and silently 401'd every Seraphina / AI call.
    @Test func requestCarriesBothApikeyAndBearerAuthorization() throws {
        let url = URL(string: "https://example.supabase.co/functions/v1/claude-proxy")!
        let body = ClaudeProxyService.Request(
            model: "claude-haiku-4-5-20251001",
            max_tokens: 50,
            system: nil,
            messages: [ClaudeProxyService.Message(role: "user", content: "hi")],
            stream: false
        )

        let req = try ClaudeProxyService.makeURLRequest(url: url, anonKey: "ANON_JWT", body: body)

        #expect(req.httpMethod == "POST")
        #expect(req.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(req.value(forHTTPHeaderField: "apikey") == "ANON_JWT")
        #expect(req.value(forHTTPHeaderField: "Authorization") == "Bearer ANON_JWT")
        #expect(req.httpBody != nil)
    }
}
