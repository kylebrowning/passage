import Vapor

public protocol VerificationForm: Form {
    var code: String { get }
}

// MARK: - Phone Verification Form

public protocol PhoneVerificationForm: VerificationForm {

}

// MARK: - Email Verification Form

public protocol EmailVerificationForm: VerificationForm {

}
