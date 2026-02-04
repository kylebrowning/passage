import Foundation
import Vapor
import WebAuthn

// MARK: - Passkey Configuration

public extension Passage.Configuration {

    struct Passkey: Sendable {
        let relyingPartyID: String
        let relyingPartyName: String
        let relyingPartyOrigin: String
        let routes: Routes
        let autoCreateUser: Bool
        let challengeTimeout: Duration
        let userVerification: UserVerificationRequirement
        let attestation: AttestationConveyancePreference
        let revokeExistingTokens: Bool

        public init(
            relyingPartyID: String,
            relyingPartyName: String,
            relyingPartyOrigin: String,
            routes: Routes = .init(),
            autoCreateUser: Bool = true,
            challengeTimeout: Duration = .seconds(5 * 60),
            userVerification: UserVerificationRequirement = .preferred,
            attestation: AttestationConveyancePreference = .none,
            revokeExistingTokens: Bool = true
        ) {
            self.relyingPartyID = relyingPartyID
            self.relyingPartyName = relyingPartyName
            self.relyingPartyOrigin = relyingPartyOrigin
            self.routes = routes
            self.autoCreateUser = autoCreateUser
            self.challengeTimeout = challengeTimeout
            self.userVerification = userVerification
            self.attestation = attestation
            self.revokeExistingTokens = revokeExistingTokens
        }
    }

}

// MARK: - Passkey Routes

public extension Passage.Configuration.Passkey {

    struct Routes: Sendable {

        public struct RegistrationOptions: Sendable {
            let path: [PathComponent]
            public init(path: PathComponent...) {
                self.path = path
            }
        }

        public struct RegistrationVerification: Sendable {
            let path: [PathComponent]
            public init(path: PathComponent...) {
                self.path = path
            }
        }

        public struct AuthenticationOptions: Sendable {
            let path: [PathComponent]
            public init(path: PathComponent...) {
                self.path = path
            }
        }

        public struct AuthenticationVerification: Sendable {
            let path: [PathComponent]
            public init(path: PathComponent...) {
                self.path = path
            }
        }

        public struct SignupOptions: Sendable {
            let path: [PathComponent]
            public init(path: PathComponent...) {
                self.path = path
            }
        }

        public struct SignupVerification: Sendable {
            let path: [PathComponent]
            public init(path: PathComponent...) {
                self.path = path
            }
        }

        let registrationOptions: RegistrationOptions
        let registrationVerification: RegistrationVerification
        let authenticationOptions: AuthenticationOptions
        let authenticationVerification: AuthenticationVerification
        let signupOptions: SignupOptions
        let signupVerification: SignupVerification

        public init(
            registrationOptions: RegistrationOptions = .init(path: "passkey", "register"),
            registrationVerification: RegistrationVerification = .init(path: "passkey", "register"),
            authenticationOptions: AuthenticationOptions = .init(path: "passkey", "authenticate"),
            authenticationVerification: AuthenticationVerification = .init(path: "passkey", "authenticate"),
            signupOptions: SignupOptions = .init(path: "passkey", "signup"),
            signupVerification: SignupVerification = .init(path: "passkey", "signup")
        ) {
            self.registrationOptions = registrationOptions
            self.registrationVerification = registrationVerification
            self.authenticationOptions = authenticationOptions
            self.authenticationVerification = authenticationVerification
            self.signupOptions = signupOptions
            self.signupVerification = signupVerification
        }
    }
}
