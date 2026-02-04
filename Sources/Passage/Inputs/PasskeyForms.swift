import Vapor
import WebAuthn

// MARK: - Passkey Signup Begin Form

public protocol PasskeySignupBeginForm: Form {
    var username: String? { get }
}

// MARK: - Passkey Authentication Begin Response

struct PasskeyBeginAuthenticationResponse: Content {
    let options: PublicKeyCredentialRequestOptions
    let challengeKey: String
}

// MARK: - Passkey Signup Begin Response

struct PasskeyBeginSignupResponse: Content {
    let options: PublicKeyCredentialCreationOptions
    let challengeKey: String
}

// MARK: - Passkey Authentication Finish Form

public protocol PasskeyAuthenticationFinishForm: Form {
    var credential: AuthenticationCredential { get }
    var challengeKey: String { get }
}

// MARK: - Passkey Signup Finish Form

public protocol PasskeySignupFinishForm: Form {
    var credential: RegistrationCredential { get }
    var challengeKey: String { get }
}

// MARK: - Default Implementations

extension Passage {

    struct DefaultPasskeySignupBeginForm: PasskeySignupBeginForm {
        static func validations(_ validations: inout Validations) {}

        let username: String?
    }

    struct DefaultPasskeyAuthenticationFinishForm: PasskeyAuthenticationFinishForm {
        static func validations(_ validations: inout Validations) {
            validations.add("challengeKey", as: String.self, is: !.empty)
        }

        let credential: AuthenticationCredential
        let challengeKey: String
    }

    struct DefaultPasskeySignupFinishForm: PasskeySignupFinishForm {
        static func validations(_ validations: inout Validations) {
            validations.add("challengeKey", as: String.self, is: !.empty)
        }

        let credential: RegistrationCredential
        let challengeKey: String
    }

}
