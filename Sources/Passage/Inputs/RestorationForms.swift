import Vapor

// MARK: - Email Password Reset Forms

public protocol EmailPasswordResetRequestForm: Form {
    var email: String { get }
}

public protocol EmailPasswordResetVerifyForm: Form {
    var email: String { get }
    var code: String { get }
    var newPassword: String { get }
}

public protocol EmailPasswordResetResendForm: Form {
    var email: String { get }
}

// MARK: - Phone Password Reset Forms

public protocol PhonePasswordResetRequestForm: Form {
    var phone: String { get }
}

public protocol PhonePasswordResetVerifyForm: Form {
    var phone: String { get }
    var code: String { get }
    var newPassword: String { get }
}

public protocol PhonePasswordResetResendForm: Form {
    var phone: String { get }
}
