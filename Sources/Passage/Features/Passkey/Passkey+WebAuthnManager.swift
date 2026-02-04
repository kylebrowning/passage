import Vapor
import WebAuthn

extension Application {

    struct WebAuthnManagerKey: StorageKey {
        typealias Value = WebAuthnManager
    }

    var webAuthn: WebAuthnManager {
        get {
            guard let manager = storage[WebAuthnManagerKey.self] else {
                fatalError("WebAuthnManager not configured. Enable passkey in Passage configuration.")
            }
            return manager
        }
        set {
            storage[WebAuthnManagerKey.self] = newValue
        }
    }
}

extension Request {

    var webAuthn: WebAuthnManager {
        application.webAuthn
    }

}
