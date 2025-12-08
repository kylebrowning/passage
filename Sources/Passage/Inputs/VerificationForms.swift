import Vapor

// MARK: - Verification Forms

public protocol VerificationRequestForm: Form {
    // No common fields yet
}

public protocol VerificationConfirmForm: Form {
    var code: String { get }
}

// MARK: - Phone Verification Forms

public protocol PhoneVerificationRequestForm: Form {
    var phone: String { get }
}

public protocol PhoneVerificationConfirmForm: VerificationConfirmForm {
    var phone: String { get }
}

// MARK: - Email Verification Forms

public protocol EmailVerificationRequestForm: Form {
    var email: String { get }
}

public protocol EmailVerificationConfirmForm: VerificationConfirmForm {
    var email: String { get }
}
