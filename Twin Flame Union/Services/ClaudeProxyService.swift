//
//  ClaudeProxyService.swift
//  Twin Flame Union
//
//  All Claude API calls route through the Supabase Edge Function so the
//  Anthropic key never ships inside the app binary.
//

import Foundation

enum ClaudeProxyService {

    // MARK: - Request / Response Types

    struct Message: Encodable {
        let role: String
        let content: String
    }

    struct Request: Encodable {
        let model: String
        let max_tokens: Int
        let system: String?
        let messages: [Message]
        let stream: Bool?
    }

    // MARK: - Non-streaming call

    static func send(
        model: String = "claude-haiku-4-5-20251001",
        maxTokens: Int = 300,
        system: String? = nil,
        messages: [Message]
    ) async throws -> String {
        let (url, anonKey) = try loadConfig()

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(anonKey, forHTTPHeaderField: "apikey")

        let body = Request(model: model, max_tokens: maxTokens, system: system, messages: messages, stream: nil)
        req.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: req)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let err = json["error"] as? [String: Any],
               let msg = err["message"] as? String {
                throw ProxyError.apiError(msg)
            }
            throw ProxyError.apiError("HTTP \(http.statusCode)")
        }

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let content = json["content"] as? [[String: Any]],
            let text = content.first?["text"] as? String
        else { throw ProxyError.unexpectedResponse }

        return text
    }

    // MARK: - Streaming call (returns AsyncThrowingStream of text chunks)

    static func stream(
        model: String = "claude-sonnet-4-6",
        maxTokens: Int = 1024,
        system: String? = nil,
        messages: [Message]
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let (url, anonKey) = try loadConfig()

                    var req = URLRequest(url: url)
                    req.httpMethod = "POST"
                    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    req.setValue(anonKey, forHTTPHeaderField: "apikey")

                    let body = Request(model: model, max_tokens: maxTokens, system: system,
                                       messages: messages, stream: true)
                    req.httpBody = try JSONEncoder().encode(body)

                    let (bytes, _) = try await URLSession.shared.bytes(for: req)

                    for try await line in bytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let payload = String(line.dropFirst(6))
                        guard payload != "[DONE]" else { break }
                        if let data = payload.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let delta = json["delta"] as? [String: Any],
                           let text = delta["text"] as? String {
                            continuation.yield(text)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: - Config

    private static func loadConfig() throws -> (URL, String) {
        guard
            let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
            let config = NSDictionary(contentsOfFile: path),
            let baseURL = config["SUPABASE_URL"] as? String,
            let anonKey = config["SUPABASE_ANON_KEY"] as? String,
            !baseURL.isEmpty, !anonKey.isEmpty
        else { throw ProxyError.missingConfig }

        guard let url = URL(string: "\(baseURL)/functions/v1/claude-proxy")
        else { throw ProxyError.missingConfig }

        return (url, anonKey)
    }
}

// MARK: - Errors

enum ProxyError: LocalizedError {
    case missingConfig
    case unexpectedResponse
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .missingConfig:         return "Supabase URL or anon key not configured."
        case .unexpectedResponse:    return "Unexpected response from Claude proxy."
        case .apiError(let message): return "API error: \(message)"
        }
    }
}
