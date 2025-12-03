import Foundation
import Vapor

// MARK: - Verification Configuration

extension Passage.Configuration {

    public struct Verification: Sendable {

        let email: Email
        let phone: Phone
        let useQueues: Bool

        public init(
            email: Email = .init(),
            phone: Phone = .init(),
            useQueues: Bool = false
        ) {
            self.email = email
            self.phone = phone
            self.useQueues = useQueues
        }
    }

}

// MARK: - Email Verification Configuration

extension Passage.Configuration.Verification {

    public struct Email: Sendable {
        let routes: Routes
        let codeLength: Int
        let codeExpiration: TimeInterval
        let maxAttempts: Int

        // MARK: Routes

        public struct Routes: Sendable {

            public struct Verify: Sendable {
                public static let `default` = Verify(path: "email", "verify")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            public struct Resend: Sendable {
                public static let `default` = Resend(path: "email", "resend")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            let verify: Verify
            let resend: Resend

            public init(
                verify: Verify = .default,
                resend: Resend = .default
            ) {
                self.verify = verify
                self.resend = resend
            }
        }

        public init(
            routes: Routes = .init(),
            codeLength: Int = 6,
            codeExpiration: TimeInterval = 15 * 60,
            maxAttempts: Int = 3,
        ) {
            self.routes = routes
            self.codeLength = codeLength
            self.codeExpiration = codeExpiration
            self.maxAttempts = maxAttempts
        }
    }

}

// MARK: - Phone Verification Configuration

extension Passage.Configuration.Verification {

    public struct Phone: Sendable {
        let routes: Routes
        let codeLength: Int
        let codeExpiration: TimeInterval
        let maxAttempts: Int

        // MARK: Routes

        public struct Routes: Sendable {
            public struct SendCode: Sendable {
                public static let `default` = SendCode(path: "phone", "send-code")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            public struct Verify: Sendable {
                public static let `default` = Verify(path: "phone", "verify")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            public struct Resend: Sendable {
                public static let `default` = Resend(path: "phone", "resend")
                let path: [PathComponent]
                public init(path: PathComponent...) {
                    self.path = path
                }
            }

            let sendCode: SendCode
            let verify: Verify
            let resend: Resend

            public init(
                sendCode: SendCode = .default,
                verify: Verify = .default,
                resend: Resend = .default
            ) {
                self.sendCode = sendCode
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

// MARK: - Verification URLs

extension Passage.Configuration {

    var emailVerificationURL: URL {
        origin.appending(path: (routes.group + verification.email.routes.verify.path).string)
    }

    var phoneVerificationURL: URL {
        origin.appending(path: (routes.group + verification.phone.routes.verify.path).string)
    }

}
