import Vapor

public protocol RegisterForm: Content, Validatable {
    var email: String? { get }
    var phone: String? { get }
    var username: String? { get }
    var password: String { get }
    var confirmPassword: String { get }

    func validate() throws
}

// MARK: - Register Form Extension

extension RegisterForm {

    func asCredential(hash: String) throws -> Credential {
        if let email = email {
            return .email(email: email, passwordHash: hash)
        } else if let phone = phone {
            return .phone(phone: phone, passwordHash: hash)
        } else if let username = username {
            return .username(username: username, passwordHash: hash)
        } else {
            throw AuthenticationError.identifierNotSpecified
        }
    }

}
