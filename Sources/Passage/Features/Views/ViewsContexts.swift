import Vapor

// MARK: - View Context

extension Passage.Views {

    struct Context<Params>: Sendable, Encodable where Params: Sendable & Encodable {
        let theme: Theme.Resolved
        let params: Params
    }

}

// MARK: - Reset Password Request View Context

extension Passage.Views {

    struct ResetPasswordRequestViewContext: Content {
        let error: String?
        let success: String?
    }

}

// MARK: - Reset Password Confirmation View Context

extension Passage.Views {

    struct ResetPasswordConfirmationViewParams: Content {
        let code: String
        let email: String?
        let error: String?
        let success: String?
        let endpoint: String
    }

}
