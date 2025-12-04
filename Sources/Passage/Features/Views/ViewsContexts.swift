import Vapor

// MARK: - View Context

extension Passage.Views {

    struct Context<Params>: Sendable, Encodable where Params: Sendable & Encodable {
        let theme: Theme.Resolved
        let params: Params
    }

}

// MARK: - Login View Context

extension Passage.Views {

    struct LoginViewContext: Content {
        let byEmail: Bool
        let byPhone: Bool
        let byUsername: Bool
        let withApple: Bool
        let withGoogle: Bool
        let withGitHub: Bool
        let error: String?
        let success: String?
        let registerLink: String?
        let resetPasswordLink: String?

        func copyWith(
            byEmail: Bool? = nil,
            byPhone: Bool? = nil,
            byUsername: Bool? = nil,
            withApple: Bool? = nil,
            withGoogle: Bool? = nil,
            withGitHub: Bool? = nil,
            error: String? = nil,
            success: String? = nil,
            registerLink: String? = nil,
            resetPasswordLink: String? = nil,
        ) -> Self {
            .init(
                byEmail: byEmail ?? self.byEmail,
                byPhone: byPhone ?? self.byPhone,
                byUsername: byUsername ?? self.byUsername,
                withApple: withApple ?? self.withApple,
                withGoogle: withGoogle ?? self.withGoogle,
                withGitHub: withGitHub ?? self.withGitHub,
                error: error ?? self.error,
                success: success ?? self.success,
                registerLink: registerLink ?? self.registerLink,
                resetPasswordLink: resetPasswordLink ?? self.resetPasswordLink,
            )
        }
    }

}

// MARK: - Register View Context

extension Passage.Views {

    struct RegisterViewContext: Content {
        let byEmail: Bool
        let byPhone: Bool
        let byUsername: Bool
        let withApple: Bool
        let withGoogle: Bool
        let withGitHub: Bool
        let error: String?
        let success: String?
        let loginLink: String?

        func copyWith(
            byEmail: Bool? = nil,
            byPhone: Bool? = nil,
            byUsername: Bool? = nil,
            withApple: Bool? = nil,
            withGoogle: Bool? = nil,
            withGitHub: Bool? = nil,
            error: String? = nil,
            success: String? = nil,
            loginLink: String? = nil,
        ) -> Self {
            .init(
                byEmail: byEmail ?? self.byEmail,
                byPhone: byPhone ?? self.byPhone,
                byUsername: byUsername ?? self.byUsername,
                withApple: withApple ?? self.withApple,
                withGoogle: withGoogle ?? self.withGoogle,
                withGitHub: withGitHub ?? self.withGitHub,
                error: error ?? self.error,
                success: success ?? self.success,
                loginLink: loginLink ?? self.loginLink,
            )
        }
    }

}

// MARK: - Reset Password Request View Context

extension Passage.Views {

    struct ResetPasswordRequestViewContext: Content {
        let byEmail: Bool
        let byPhone: Bool
        let error: String?
        let success: String?

        func copyWith(
            byEmail: Bool? = nil,
            byPhone: Bool? = nil,
            error: String? = nil,
            success: String? = nil,
        ) -> Self {
            .init(
                byEmail: byEmail ?? self.byEmail,
                byPhone: byPhone ?? self.byPhone,
                error: error ?? self.error,
                success: success ?? self.success,
            )
        }
    }

}

// MARK: - Reset Password Confirmation View Context

extension Passage.Views {

    struct ResetPasswordConfirmViewContext: Content {
        let byEmail: Bool
        let byPhone: Bool
        let code: String
        let email: String?
        let error: String?
        let success: String?

        func copyWith(
            byEmail: Bool? = nil,
            byPhone: Bool? = nil,
            email: String? = nil,
            error: String? = nil,
            success: String? = nil,
        ) -> Self {
            .init(
                byEmail: byEmail ?? self.byEmail,
                byPhone: byPhone ?? self.byPhone,
                code: self.code,
                email: email ?? self.email,
                error: error ?? self.error,
                success: success ?? self.success,
            )
        }

    }

}
