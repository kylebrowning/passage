import Foundation
import Vapor

// MARK: - Restoration Configuration (Password Reset)

extension Passage.Configuration {

    public struct Restoration: Sendable {

        /// Preferred delivery channel for password reset when user is looked up by username
        public enum PreferredDelivery: Sendable {
            case email
            case phone
        }

        let preferredDelivery: PreferredDelivery
        let email: Email
        let phone: Phone
        let useQueues: Bool

        public init(
            preferredDelivery: PreferredDelivery = .email,
            email: Email = .init(),
            phone: Phone = .init(),
            useQueues: Bool = false
        ) {
            self.preferredDelivery = preferredDelivery
            self.email = email
            self.phone = phone
            self.useQueues = useQueues
        }
    }

}

// MARK: - Restoration by Email Configuration

extension Passage.Configuration.Restoration {

    public struct Email: Sendable {

        public struct Routes: Sendable {

            public struct Request: Sendable {
                public static let `default` = Request(path: "password", "reset", "email")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            public struct Verify: Sendable {
                public static let `default` = Verify(path: "password", "reset", "email", "verify")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            public struct Resend: Sendable {
                public static let `default` = Resend(path: "password", "reset", "email", "resend")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            let request: Request
            let verify: Verify
            let resend: Resend

            public init(
                request: Request = .default,
                verify: Verify = .default,
                resend: Resend = .default
            ) {
                self.request = request
                self.verify = verify
                self.resend = resend
            }
        }

        public struct WebForm: Sendable {

            public struct Route: Sendable {
                public static let `default` = Route(path: "password", "reset")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
                public init(path: [PathComponent]) {
                    self.path = path
                }
            }

            public static let `default` = WebForm(
                enabled: true,
                template: "password-reset-form",
                route: .default
            )

            let enabled: Bool
            let template: String
            let route: Route

            public init(
                enabled: Bool = true,
                template: String = "password-reset-form",
                route: Route = .default
            ) {
                self.enabled = enabled
                self.template = template
                self.route = route
            }
        }

        let routes: Routes
        let codeLength: Int
        let codeExpiration: TimeInterval
        let maxAttempts: Int
        let resetLinkBaseURL: URL?
        let webForm: WebForm

        public init(
            routes: Routes = .init(),
            codeLength: Int = 6,
            codeExpiration: TimeInterval = 15 * 60,  // 15 minutes
            maxAttempts: Int = 3,
            resetLinkBaseURL: URL? = nil,
            webForm: WebForm = .default
        ) {
            self.routes = routes
            self.codeLength = codeLength
            self.codeExpiration = codeExpiration
            self.maxAttempts = maxAttempts
            self.resetLinkBaseURL = resetLinkBaseURL
            self.webForm = webForm
        }
    }

}

// MARK: - Restoration by Phone Configuration

extension Passage.Configuration.Restoration {

    public struct Phone: Sendable {
        let routes: Routes
        let codeLength: Int
        let codeExpiration: TimeInterval
        let maxAttempts: Int

        public struct Routes: Sendable {

            public struct Request: Sendable {
                public static let `default` = Request(path: "password", "reset", "phone")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            public struct Verify: Sendable {
                public static let `default` = Verify(path: "password", "reset", "phone", "verify")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            public struct Resend: Sendable {
                public static let `default` = Resend(path: "password", "reset", "phone", "resend")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            let request: Request
            let verify: Verify
            let resend: Resend

            public init(
                request: Request = .default,
                verify: Verify = .default,
                resend: Resend = .default
            ) {
                self.request = request
                self.verify = verify
                self.resend = resend
            }
        }

        public init(
            routes: Routes = .init(),
            codeLength: Int = 6,
            codeExpiration: TimeInterval = 5 * 60,  // 5 minutes for SMS
            maxAttempts: Int = 3
        ) {
            self.routes = routes
            self.codeLength = codeLength
            self.codeExpiration = codeExpiration
            self.maxAttempts = maxAttempts
        }
    }

}

// MARK: - Restoration URLs

extension Passage.Configuration {

    var emailPasswordResetURL: URL {
        origin.appending(path: (routes.group + restoration.email.routes.verify.path).string)
    }

    var emailPasswordResetFormURL: URL {
        origin.appending(path: (routes.group + restoration.email.webForm.route.path).string)
    }

    /// URL for password reset link in email.
    /// If resetLinkBaseURL is set, uses that; otherwise uses the web form route if enabled,
    /// or falls back to the API verify endpoint.
    func emailPasswordResetLinkURL(code: String, email: String) -> URL {
        let baseURL: URL
        if let customURL = restoration.email.resetLinkBaseURL {
            baseURL = customURL
        } else if restoration.email.webForm.enabled {
            baseURL = emailPasswordResetFormURL
        } else {
            baseURL = emailPasswordResetURL
        }

        return baseURL.appending(queryItems: [
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "email", value: email)
        ])
    }

    var phonePasswordResetURL: URL {
        origin.appending(path: (routes.group + restoration.phone.routes.verify.path).string)
    }

}
