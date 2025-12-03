import Vapor

// MARK: - Login Form Default Implementation

extension Passage {
    struct DefaultLoginForm: LoginForm {
        static func validations(_ validations: inout Validations) {
            validations.add("email", as: String?.self, is: .email || .nil, required: false)
            validations.add("password", as: String.self, is: .count(6...))
        }
        
        let email: String?
        let phone: String?
        let username: String?
        let password: String

        func validate() throws {
            // No additional validation needed for login form
        }
    }
}

// MARK: - Register Form Default Implementation

extension Passage {

    struct DefaultRegisterForm: RegisterForm {
        static func validations(_ validations: inout Validations) {
            validations.add("email", as: String?.self, is: .email || .nil, required: false)
            validations.add("password", as: String.self, is: .count(6...))
            validations.add("confirmPassword", as: String.self, is: .count(6...))
        }

        let email: String?
        let phone: String?
        let username: String?
        let password: String
        let confirmPassword: String

        func validate() throws {
            if password != confirmPassword {
                throw AuthenticationError.passwordsDoNotMatch
            }
        }
    }

}

// MARK: - RefreshToken Form Default Implementation

extension Passage {
    struct DefaultRefreshTokenForm: RefreshTokenForm {
        static func validations(_ validations: inout Validations) {
            validations.add("refreshToken", as: String.self, is: !.empty)
        }
        
        let refreshToken: String

        func validate() throws {
            // No additional validation needed for refresh token form
        }
    }
}

// MARK: - Verification Default Forms Default Implementation

extension Passage {

    struct DefaultEmailVerificationForm: EmailVerificationForm {
        static func validations(_ validations: inout Validations) {
            validations.add("code", as: String.self, is: .count(6...20))
        }

        let code: String
    }

    struct DefaultPhoneVerificationForm: PhoneVerificationForm {
        static func validations(_ validations: inout Validations) {
            validations.add("code", as: String.self, is: .count(6...20))
        }

        let code: String
    }

}

// MARK: - Restoration Default Forms Default Implementation

extension Passage {

    // MARK: Email Password Reset Request Form

    struct DefaultEmailPasswordResetRequestForm: EmailPasswordResetRequestForm {
        static func validations(_ validations: inout Validations) {
            validations.add("email", as: String.self, is: .email)
        }

        let email: String
    }

    struct DefaultEmailPasswordResetVerifyForm: EmailPasswordResetVerifyForm {
        static func validations(_ validations: inout Validations) {
            validations.add("email", as: String.self, is: .email)
            validations.add("code", as: String.self, is: .count(6...20))
            validations.add("newPassword", as: String.self, is: .count(6...))
        }

        let email: String
        let code: String
        let newPassword: String
    }

    struct DefaultEmailPasswordResetResendForm: EmailPasswordResetResendForm {
        static func validations(_ validations: inout Validations) {
            validations.add("email", as: String.self, is: .email)
        }

        let email: String
    }

    // MARK: Phone Password Reset Request Form

    struct DefaultPhonePasswordResetRequestForm: PhonePasswordResetRequestForm {
        static func validations(_ validations: inout Validations) {
            validations.add("phone", as: String.self, is: .count(6...))
        }

        let phone: String
    }

    struct DefaultPhonePasswordResetVerifyForm: PhonePasswordResetVerifyForm {
        static func validations(_ validations: inout Validations) {
            validations.add("phone", as: String.self, is: .count(6...))
            validations.add("code", as: String.self, is: .count(6...20))
            validations.add("newPassword", as: String.self, is: .count(6...))
        }

        let phone: String
        let code: String
        let newPassword: String
    }

    struct DefaultPhonePasswordResetResendForm: PhonePasswordResetResendForm {
        static func validations(_ validations: inout Validations) {
            validations.add("phone", as: String.self, is: .count(6...))
        }

        let phone: String
    }

}
