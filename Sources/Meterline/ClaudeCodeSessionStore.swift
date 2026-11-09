// SPDX-License-Identifier: GPL-3.0-only
import Foundation

/// Reads — never writes — the OAuth session Claude Code keeps in its own Keychain item.
///
/// The profile-scoped token is used for the free usage endpoint. Meterline never launches
/// Claude Code or renews this session; it picks up credentials when the user updates them.
enum ClaudeCodeSessionStore {
    struct Session {
        let accessToken: String
        let expiresAt: Date?

        var isExpired: Bool {
            guard let expiresAt else { return false }
            return expiresAt <= Date()
        }
    }

    private static let keychainService = "Claude Code-credentials"

    private static func rawItem() -> Data? {
        ClaudeKeychainReader.read(service: keychainService)
    }

    static func read() -> Session? {
        guard
            let data = rawItem(),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let oauth = json["claudeAiOauth"] as? [String: Any],
            let accessToken = oauth["accessToken"] as? String
        else {
            return nil
        }
        // Claude Code stores this as a JS Date.now()-style millisecond epoch.
        let expiresAtMs = oauth["expiresAt"] as? Double
        return Session(
            accessToken: accessToken,
            expiresAt: expiresAtMs.map { Date(timeIntervalSince1970: $0 / 1_000) }
        )
    }

}
