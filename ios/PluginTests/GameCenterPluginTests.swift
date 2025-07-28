import XCTest
import Capacitor
import GameKit
@testable import Plugin

class MockLocalPlayer: LocalPlayerProtocol {
    var isAuthenticated: Bool = false
    var authenticateHandler: ((UIViewController?, Error?) -> Void)?
    var teamPlayerID: String = "testPlayer"
    var fetchHandler: (() async throws -> (URL, Data, Data, UInt64))?
    var legacyHandler: ((@escaping (URL?, Data?, Data?, UInt64, Error?) -> Void) -> Void)?
    var photoHandler: ((GKPlayer.PhotoSize) async throws -> UIImage?)?

    func fetchIdentityVerificationItems() async throws -> (URL, Data, Data, UInt64) {
        if let handler = fetchHandler {
            return try await handler()
        }
        return (URL(string: "https://static.gc.apple.com")!, Data(), Data(), 0)
    }

    func generateIdentityVerificationSignature(_ completionHandler: @escaping (URL?, Data?, Data?, UInt64, Error?) -> Void) {
        if let handler = legacyHandler {
            handler(completionHandler)
        } else {
            completionHandler(URL(string: "https://static.gc.apple.com"), Data(), Data(), 0, nil)
        }
    }

    @available(iOS 14.0, *)
    func loadPhoto(for size: GKPlayer.PhotoSize) async throws -> UIImage? {
        if let handler = photoHandler {
            return try await handler(size)
        }
        return nil
    }
}

class GameCenterPluginTests: XCTestCase {
    func testSuccessAuthenticationEmitsEvent() {
        let plugin = GameCenterPlugin()
        let player = MockLocalPlayer()
        plugin.localPlayer = player
        let expectation = self.expectation(description: "resolved")

        let call = CAPPluginCall(callbackId: "0", methodName: "authenticateSilent", options: [:], success: { result, _ in
            if let data = result?.data as? [String: Bool], data["authenticated"] == true {
                expectation.fulfill()
            }
        }, error: { _ in })

        player.authenticateHandler = { _, _ in
            player.isAuthenticated = true
        }

        plugin.authenticateSilent(call)
        waitForExpectations(timeout: 1)
    }

    func testGameCenterUnavailableRejects() {
        let plugin = GameCenterPlugin()
        let player = MockLocalPlayer()
        plugin.localPlayer = player
        let expectation = self.expectation(description: "rejected")

        let call = CAPPluginCall(callbackId: "1", methodName: "authenticateSilent", options: [:], success: { _, _ in }, error: { err in
            if err.code == PluginError.gcUnavailable.rawValue {
                expectation.fulfill()
            }
        })

        player.authenticateHandler = { _, handlerError in
            player.isAuthenticated = false
            let error = GKError(.gameServicesUnavailable)
            handlerError?(error)
        }

        plugin.authenticateSilent(call)
        waitForExpectations(timeout: 1)
    }

    func testGetVerificationDataSuccess() {
        let plugin = GameCenterPlugin()
        let player = MockLocalPlayer()
        plugin.localPlayer = player
        player.isAuthenticated = true
        player.teamPlayerID = "player123"
        player.fetchHandler = {
            return (URL(string: "https://static.gc.apple.com")!, Data([1,2]), Data([3,4]), 123)
        }

        let expectation = self.expectation(description: "resolved")
        let call = CAPPluginCall(callbackId: "2", methodName: "getVerificationData", options: [:], success: { result, _ in
            if let dict = result?.data as? [String: Any], dict["playerId"] as? String == "player123" {
                expectation.fulfill()
            }
        }, error: { _ in })

        Task { await plugin.getVerificationData(call) }
        waitForExpectations(timeout: 1)
    }

    func testGetVerificationDataNotAuthenticated() {
        let plugin = GameCenterPlugin()
        let player = MockLocalPlayer()
        plugin.localPlayer = player
        player.isAuthenticated = false

        let expectation = self.expectation(description: "rejected")
        let call = CAPPluginCall(callbackId: "3", methodName: "getVerificationData", options: [:], success: { _, _ in }, error: { err in
            if err.code == PluginError.notAuthenticated.rawValue {
                expectation.fulfill()
            }
        })

        Task { await plugin.getVerificationData(call) }
        waitForExpectations(timeout: 1)
    }

    func testGetVerificationDataInvalidDomain() {
        let plugin = GameCenterPlugin()
        let player = MockLocalPlayer()
        plugin.localPlayer = player
        player.isAuthenticated = true
        player.fetchHandler = {
            return (URL(string: "https://evil.com")!, Data(), Data(), 100)
        }

        let expectation = self.expectation(description: "rejected")
        let call = CAPPluginCall(callbackId: "4", methodName: "getVerificationData", options: [:], success: { _, _ in }, error: { err in
            if err.code == PluginError.internalError.rawValue {
                expectation.fulfill()
            }
        })

        Task { await plugin.getVerificationData(call) }
        waitForExpectations(timeout: 1)
    }

    func testLegacySignatureAPI() {
        let plugin = GameCenterPlugin()
        let player = MockLocalPlayer()
        plugin.localPlayer = player
        plugin.osOverride = OperatingSystemVersion(majorVersion: 13, minorVersion: 5, patchVersion: 0)
        player.isAuthenticated = true
        player.teamPlayerID = "legacy"
        player.legacyHandler = { completion in
            completion(URL(string: "https://static.gc.apple.com")!, Data([9]), Data([8]), 42, nil)
        }

        let expectation = self.expectation(description: "resolved")
        let call = CAPPluginCall(callbackId: "legacy", methodName: "getVerificationData", options: [:], success: { result, _ in
            if let dict = result?.data as? [String: Any], dict["playerId"] as? String == "legacy" {
                expectation.fulfill()
            }
        }, error: { _ in })

        Task { await plugin.getVerificationData(call) }
        waitForExpectations(timeout: 1)
    }

    func testGetProfileNotAuthenticated() async {
        let plugin = GameCenterPlugin()
        let player = MockLocalPlayer()
        plugin.localPlayer = player
        player.isAuthenticated = false

        let expectation = self.expectation(description: "rejected")
        let call = CAPPluginCall(callbackId: "5", methodName: "getProfile", options: [:], success: { _, _ in }, error: { err in
            if err.code == PluginError.notAuthenticated.rawValue {
                expectation.fulfill()
            }
        })

        await plugin.getProfile(call)
        waitForExpectations(timeout: 1)
    }

    func testGetProfileSuccessReturnsDataUrl() async {
        let plugin = GameCenterPlugin()
        let player = MockLocalPlayer()
        plugin.localPlayer = player
        player.isAuthenticated = true
        player.teamPlayerID = "player555"
        player.photoHandler = { _ in
            return UIImage(named: "TestAvatar")
        }

        let expectedLength = UIImage(named: "TestAvatar")!.pngData()!.base64EncodedString().count
        let expectation = self.expectation(description: "resolved")
        let call = CAPPluginCall(callbackId: "6", methodName: "getProfile", options: ["size": "small"], success: { result, _ in
            if let dict = result?.data as? [String: String],
               let url = dict["avatarUrl"],
               url.hasPrefix("data:image/png;base64,") {
                let b64 = url.replacingOccurrences(of: "data:image/png;base64,", with: "")
                if b64.count == expectedLength {
                    expectation.fulfill()
                }
            }
        }, error: { _ in })

        await plugin.getProfile(call)
        waitForExpectations(timeout: 1)
    }

    func testGetProfileNoAvatar() async {
        let plugin = GameCenterPlugin()
        let player = MockLocalPlayer()
        plugin.localPlayer = player
        player.isAuthenticated = true
        player.teamPlayerID = "player777"
        player.photoHandler = { _ in
            return nil
        }

        let expectation = self.expectation(description: "resolved")
        let call = CAPPluginCall(callbackId: "7", methodName: "getProfile", options: [:], success: { result, _ in
            if let dict = result?.data as? [String: String],
               let url = dict["avatarUrl"],
               url.isEmpty {
                expectation.fulfill()
            }
        }, error: { _ in })

        await plugin.getProfile(call)
        waitForExpectations(timeout: 1)
    }
}
