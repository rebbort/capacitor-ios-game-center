import XCTest
import Capacitor
import GameKit
@testable import Plugin

class MockLocalPlayer: LocalPlayerProtocol {
    var isAuthenticated: Bool = false
    var authenticateHandler: ((UIViewController?, Error?) -> Void)?
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
}
