import Foundation
import Capacitor
import GameKit

@objc public enum PluginError: String {
    case notAuthenticated = "NOT_AUTHENTICATED"
    case gcUnavailable = "GC_UNAVAILABLE"
    case osUnsupported = "OS_UNSUPPORTED"
    case internalError = "INTERNAL"
}

protocol LocalPlayerProtocol {
    var isAuthenticated: Bool { get }
    var authenticateHandler: ((UIViewController?, Error?) -> Void)? { get set }
    var teamPlayerID: String { get }
    @available(iOS 14.0, *)
    func fetchIdentityVerificationItems() async throws -> (URL, Data, Data, UInt64)
}

extension GKLocalPlayer: LocalPlayerProtocol {
    @available(iOS 14.0, *)
    func fetchIdentityVerificationItems() async throws -> (URL, Data, Data, UInt64) {
        try await fetchItems(forIdentityVerificationSignature: ())
    }
}

@objc(GameCenterPlugin)
public class GameCenterPlugin: CAPPlugin {
    internal var localPlayer: LocalPlayerProtocol = GKLocalPlayer.local
    private let cacheKey = "gc_auth_state"

    private func cacheAuthState(_ state: Bool) {
        let data = Data([state ? 1 : 0])
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: cacheKey,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "GameCenterPlugin"
        ]
        SecItemDelete(query as CFDictionary)
        var attributes = query
        attributes[kSecValueData as String] = data
        SecItemAdd(attributes as CFDictionary, nil)
    }

    private func cachedAuthState() -> Bool? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: cacheKey,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "GameCenterPlugin",
            kSecReturnData as String: true
        ]
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data, let byte = data.first else {
            return nil
        }
        return byte == 1
    }

    @objc public func authenticateSilent(_ call: CAPPluginCall) {
        guard #available(iOS 14.0, *) else {
            call.reject("iOS version unsupported", PluginError.osUnsupported.rawValue)
            notifyListeners("authStateChanged", data: ["authenticated": false])
            return
        }

        if let cached = cachedAuthState(), cached, localPlayer.isAuthenticated {
            call.resolve(["authenticated": true])
            notifyListeners("authStateChanged", data: ["authenticated": true])
            return
        }

        Task {
            localPlayer.authenticateHandler = { [weak self] viewController, error in
                guard let self else { return }
                if viewController != nil {
                    call.reject("Not authenticated", PluginError.notAuthenticated.rawValue)
                    self.cacheAuthState(false)
                    self.notifyListeners("authStateChanged", data: ["authenticated": false])
                    return
                }

                if self.localPlayer.isAuthenticated {
                    call.resolve(["authenticated": true])
                    self.cacheAuthState(true)
                    self.notifyListeners("authStateChanged", data: ["authenticated": true])
                } else if let gkError = error as? GKError {
                    switch gkError.code {
                    case .gameServicesUnavailable, .serviceNotAvailable, .networkUnavailable:
                        call.reject("Game Center unavailable", PluginError.gcUnavailable.rawValue)
                    case .notAuthenticated:
                        call.reject("Not authenticated", PluginError.notAuthenticated.rawValue)
                    default:
                        call.reject("Internal error", PluginError.internalError.rawValue)
                    }
                    self.cacheAuthState(false)
                    self.notifyListeners("authStateChanged", data: ["authenticated": false])
                } else if error != nil {
                    call.reject("Internal error", PluginError.internalError.rawValue)
                    self.cacheAuthState(false)
                    self.notifyListeners("authStateChanged", data: ["authenticated": false])
                } else {
                    call.reject("Not authenticated", PluginError.notAuthenticated.rawValue)
                    self.cacheAuthState(false)
                    self.notifyListeners("authStateChanged", data: ["authenticated": false])
                }
            }
        }
    }

    @objc public func getVerificationData(_ call: CAPPluginCall) async {
        guard #available(iOS 14.0, *) else {
            call.reject("iOS version unsupported", PluginError.osUnsupported.rawValue)
            return
        }

        guard localPlayer.isAuthenticated else {
            call.reject("Not authenticated", PluginError.notAuthenticated.rawValue)
            return
        }

        do {
            let (url, signature, salt, timestamp) = try await localPlayer.fetchIdentityVerificationItems()
            guard let host = url.host,
                  host == "static.gc.apple.com" || host == "sandbox.gc.apple.com" else {
                call.reject("Internal error", PluginError.internalError.rawValue)
                return
            }

            struct VerificationPayload: Codable {
                let playerId: String
                let bundleId: String
                let publicKeyUrl: String
                let timestamp: UInt64
                let signature: String
                let salt: String
            }

            let payload = VerificationPayload(
                playerId: localPlayer.teamPlayerID,
                bundleId: Bundle.main.bundleIdentifier ?? "",
                publicKeyUrl: url.absoluteString,
                timestamp: timestamp,
                signature: signature.base64EncodedString(),
                salt: salt.base64EncodedString()
            )

            let encoder = JSONEncoder()
            guard let data = try? encoder.encode(payload),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                call.reject("Internal error", PluginError.internalError.rawValue)
                return
            }

            call.resolve(json)
        } catch {
            call.reject("Internal error", PluginError.internalError.rawValue)
        }
    }
}
