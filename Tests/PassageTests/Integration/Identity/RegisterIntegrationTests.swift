import Testing
import Vapor
import VaporTesting
import JWTKit
@testable import Passage
@testable import PassageOnlyForTest

@Suite("Register Integration Tests", .tags(.integration, .register))
struct RegisterIntegrationTests {

    // MARK: - Sendable Capture Helper

    /// Helper class to capture sent emails/SMS in a Sendable-compliant way
    final class CapturedMessages: @unchecked Sendable {
        var emails: [Passage.OnlyForTest.MockEmailDelivery.EphemeralEmail] = []
        var sms: [Passage.OnlyForTest.MockPhoneDelivery.EphemeralSMS] = []
    }

    // MARK: - Configuration Helper

    /// Configures a test Vapor application with Passage
    @Sendable private func configure(_ app: Application) async throws {
        try await configureWithCapture(app, captured: nil)
    }

    /// Configures a test Vapor application with Passage and message capture
    @Sendable private func configureWithCapture(
        _ app: Application,
        captured: CapturedMessages?
    ) async throws {
        // Add HMAC key directly for testing (simpler than RSA)
        await app.jwt.keys.add(
            hmac: HMACKey(from: "test-secret-key-for-jwt-signing"),
            digestAlgorithm: .sha256,
            kid: JWKIdentifier(string: "test-key")
        )

        // Configure Passage with test services
        let store = Passage.OnlyForTest.InMemoryStore()
        let emailCallback: (@Sendable (Passage.OnlyForTest.MockEmailDelivery.EphemeralEmail) -> Void)? = captured != nil ? { @Sendable in captured!.emails.append($0) } : nil
        let phoneCallback: (@Sendable (Passage.OnlyForTest.MockPhoneDelivery.EphemeralSMS) -> Void)? = captured != nil ? { @Sendable in captured!.sms.append($0) } : nil
        let emailDelivery = Passage.OnlyForTest.MockEmailDelivery(callback: emailCallback)
        let phoneDelivery = Passage.OnlyForTest.MockPhoneDelivery(callback: phoneCallback)

        let services = Passage.Services(
            store: store,
            random: DefaultRandomGenerator(),
            emailDelivery: emailDelivery,
            phoneDelivery: phoneDelivery,
            federatedLogin: nil
        )

        // Use empty JWKS since we're adding keys manually
        let emptyJwks = """
        {"keys":[]}
        """

        let configuration = try Passage.Configuration(
            origin: URL(string: "http://localhost:8080")!,
            routes: .init(),
            tokens: .init(
                issuer: "test-issuer",
                accessToken: .init(timeToLive: 3600),
                refreshToken: .init(timeToLive: 86400)
            ),
            jwt: .init(jwks: .init(json: emptyJwks)),
            verification: .init(
                email: .init(
                    codeLength: 6,
                    codeExpiration: 600,
                    maxAttempts: 5
                ),
                phone: .init(
                    codeLength: 6,
                    codeExpiration: 600,
                    maxAttempts: 5
                ),
                useQueues: false
            ),
            restoration: .init(
                email: .init(
                    codeLength: 6,
                    codeExpiration: 600,
                    maxAttempts: 5
                ),
                phone: .init(
                    codeLength: 6,
                    codeExpiration: 600,
                    maxAttempts: 5
                ),
                useQueues: false
            )
        )

        try await app.passage.configure(
            services: services,
            configuration: configuration
        )
    }

    // MARK: - Successful Registration Tests

    @Test("Registration succeeds with email identifier")
    func registerWithEmail() async throws {
        let captured = CapturedMessages()

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            // Register new user
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "email": "newuser@example.com",
                    "password": "password123",
                    "confirmPassword": "password123"
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)

                // Verify user was created
                let store = app.passage.storage.services.store
                let user = try await store.users.find(
                    byIdentifier: Identifier(kind: .email, value: "newuser@example.com")
                )

                #expect(user != nil)
                #expect(user?.email == "newuser@example.com")
                #expect(user?.isEmailVerified == false)

                // Verify verification email was sent
                #expect(captured.emails.count == 1)
                #expect(captured.emails.first?.to == "newuser@example.com")
                #expect(captured.emails.first?.type == .verification)
                #expect(captured.emails.first?.verificationCode != nil)
            })
        }
    }

    @Test("Registration succeeds with phone identifier")
    func registerWithPhone() async throws {
        let captured = CapturedMessages()

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            // Register new user
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "phone": "+1234567890",
                    "password": "password123",
                    "confirmPassword": "password123"
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)

                // Verify user was created
                let store = app.passage.storage.services.store
                let user = try await store.users.find(
                    byIdentifier: Identifier(kind: .phone, value: "+1234567890")
                )

                #expect(user != nil)
                #expect(user?.phone == "+1234567890")
                #expect(user?.isPhoneVerified == false)

                // Verify SMS was sent
                #expect(captured.sms.count == 1)
                #expect(captured.sms.first?.to == "+1234567890")
                #expect(captured.sms.first?.type == .verification)
                #expect(captured.sms.first?.code != nil)
            })
        }
    }

    @Test("Registration succeeds with username identifier")
    func registerWithUsername() async throws {
        try await withApp(configure: configure) { app in
            // Register new user with username
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "username": "testuser",
                    "password": "password123",
                    "confirmPassword": "password123"
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)

                // Verify user was created
                let store = app.passage.storage.services.store
                let user = try await store.users.find(
                    byIdentifier: Identifier(kind: .username, value: "testuser")
                )

                #expect(user != nil)
                #expect(user?.username == "testuser")
                // Username doesn't require verification
                #expect(user?.isEmailVerified == false)
                #expect(user?.isPhoneVerified == false)
            })
        }
    }

    // MARK: - Duplicate Identifier Tests

    @Test("Registration fails when email already exists")
    func registerFailsWithDuplicateEmail() async throws {
        try await withApp(configure: configure) { app in
            // Create first user
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "email": "existing@example.com",
                    "password": "password123",
                    "confirmPassword": "password123"
                ])
            }, afterResponse: { res async in
                #expect(res.status == .ok)
            })

            // Attempt to register with same email
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "email": "existing@example.com",
                    "password": "password456",
                    "confirmPassword": "password456"
                ])
            }, afterResponse: { res async in
                #expect(res.status == .conflict)
            })
        }
    }

    @Test("Registration fails when phone already exists")
    func registerFailsWithDuplicatePhone() async throws {
        try await withApp(configure: configure) { app in
            // Create first user
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "phone": "+1234567890",
                    "password": "password123",
                    "confirmPassword": "password123"
                ])
            }, afterResponse: { res async in
                #expect(res.status == .ok)
            })

            // Attempt to register with same phone
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "phone": "+1234567890",
                    "password": "password456",
                    "confirmPassword": "password456"
                ])
            }, afterResponse: { res async in
                #expect(res.status == .conflict)
            })
        }
    }

    @Test("Registration fails when username already exists")
    func registerFailsWithDuplicateUsername() async throws {
        try await withApp(configure: configure) { app in
            // Create first user
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "username": "testuser",
                    "password": "password123",
                    "confirmPassword": "password123"
                ])
            }, afterResponse: { res async in
                #expect(res.status == .ok)
            })

            // Attempt to register with same username
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "username": "testuser",
                    "password": "password456",
                    "confirmPassword": "password456"
                ])
            }, afterResponse: { res async in
                #expect(res.status == .conflict)
            })
        }
    }

    // MARK: - Form Validation Tests

    @Test("Registration fails when passwords don't match")
    func registerFailsWithMismatchedPasswords() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "email": "user@example.com",
                    "password": "password123",
                    "confirmPassword": "different_password"
                ])
            }, afterResponse: { res async in
                #expect(res.status == .badRequest)
            })
        }
    }

    @Test("Registration fails when no identifier provided")
    func registerFailsWithoutIdentifier() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "password": "password123",
                    "confirmPassword": "password123"
                ])
            }, afterResponse: { res async in
                #expect(res.status == .badRequest)
            })
        }
    }

    // MARK: - Verification Flow Tests

    @Test("User cannot login with unverified email")
    func cannotLoginWithUnverifiedEmail() async throws {
        try await withApp(configure: configure) { app in
            // Register user with email
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "email": "unverified@example.com",
                    "password": "password123",
                    "confirmPassword": "password123"
                ])
            }, afterResponse: { res async in
                #expect(res.status == .ok)
            })

            // Attempt to login without verifying
            try await app.testing().test(.POST, "auth/login", beforeRequest: { req in
                try req.content.encode([
                    "email": "unverified@example.com",
                    "password": "password123"
                ])
            }, afterResponse: { res async in
                #expect(res.status == .forbidden)
            })
        }
    }

    @Test("User cannot login with unverified phone")
    func cannotLoginWithUnverifiedPhone() async throws {
        try await withApp(configure: configure) { app in
            // Register user with phone
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "phone": "+1234567890",
                    "password": "password123",
                    "confirmPassword": "password123"
                ])
            }, afterResponse: { res async in
                #expect(res.status == .ok)
            })

            // Attempt to login without verifying
            try await app.testing().test(.POST, "auth/login", beforeRequest: { req in
                try req.content.encode([
                    "phone": "+1234567890",
                    "password": "password123"
                ])
            }, afterResponse: { res async in
                #expect(res.status == .forbidden)
            })
        }
    }

    @Test("Username registration allows immediate login")
    func usernameRegistrationAllowsImmediateLogin() async throws {
        try await withApp(configure: configure) { app in
            // Register user with username
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "username": "testuser",
                    "password": "password123",
                    "confirmPassword": "password123"
                ])
            }, afterResponse: { res async in
                #expect(res.status == .ok)
            })

            // Login immediately (no verification required for username)
            try await app.testing().test(.POST, "auth/login", beforeRequest: { req in
                try req.content.encode([
                    "username": "testuser",
                    "password": "password123"
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)

                let authUser = try res.content.decode(AuthUser.self)
                #expect(!authUser.accessToken.isEmpty)
                #expect(!authUser.refreshToken.isEmpty)
            })
        }
    }

    // MARK: - Email Verification Tests

    @Test("Email verification succeeds via GET request with code")
    func emailVerificationSucceeds() async throws {
        let captured = CapturedMessages()

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            var accessToken = ""

            // Register user
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "email": "verify@example.com",
                    "password": "password123",
                    "confirmPassword": "password123"
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                #expect(captured.emails.count == 1)

                // Get user to create access token for verification
                let store = app.passage.storage.services.store
                let user = try await store.users.find(
                    byIdentifier: Identifier(kind: .email, value: "verify@example.com")
                )
                #expect(user != nil)

                // Create access token for verification request
                let token = AccessToken(
                    userId: try user!.requiredIdAsString,
                    expiresAt: .now.addingTimeInterval(3600),
                    issuer: "test-issuer",
                    audience: nil,
                    scope: nil
                )
                accessToken = try await app.jwt.keys.sign(token)
            })

            // Verify email with code
            try await app.testing().test(
                .GET,
                "auth/email/verify?code=\(captured.emails.first!.verificationCode!)",
                beforeRequest: { req in
                    req.headers.bearerAuthorization = BearerAuthorization(token: accessToken)
                },
                afterResponse: { res async throws in
                    #expect(res.status == .ok)

                    // Verify user is now marked as verified
                    let store = app.passage.storage.services.store
                    let user = try await store.users.find(
                        byIdentifier: Identifier(kind: .email, value: "verify@example.com")
                    )
                    #expect(user?.isEmailVerified == true)
                }
            )
        }
    }

    @Test("Email verification fails with invalid code")
    func emailVerificationFailsWithInvalidCode() async throws {
        try await withApp(configure: configure) { app in
            var accessToken = ""

            // Register user
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "email": "verify@example.com",
                    "password": "password123",
                    "confirmPassword": "password123"
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)

                // Get user to create access token
                let store = app.passage.storage.services.store
                let user = try await store.users.find(
                    byIdentifier: Identifier(kind: .email, value: "verify@example.com")
                )
                #expect(user != nil)

                let token = AccessToken(
                    userId: try user!.requiredIdAsString,
                    expiresAt: .now.addingTimeInterval(3600),
                    issuer: "test-issuer",
                    audience: nil,
                    scope: nil
                )
                accessToken = try await app.jwt.keys.sign(token)
            })

            // Attempt verification with wrong code
            try await app.testing().test(
                .GET,
                "auth/email/verify?code=WRONGCODE",
                beforeRequest: { req in
                    req.headers.bearerAuthorization = BearerAuthorization(token: accessToken)
                },
                afterResponse: { res async in
                    #expect(res.status == .unauthorized)
                }
            )
        }
    }

    @Test("Verified email user can login successfully")
    func verifiedEmailUserCanLogin() async throws {
        let captured = CapturedMessages()

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            var accessToken = ""

            // Register user
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "email": "verified@example.com",
                    "password": "password123",
                    "confirmPassword": "password123"
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)

                // Get access token
                let store = app.passage.storage.services.store
                let user = try await store.users.find(
                    byIdentifier: Identifier(kind: .email, value: "verified@example.com")
                )
                let token = AccessToken(
                    userId: try user!.requiredIdAsString,
                    expiresAt: .now.addingTimeInterval(3600),
                    issuer: "test-issuer",
                    audience: nil,
                    scope: nil
                )
                accessToken = try await app.jwt.keys.sign(token)
            })

            // Verify email
            try await app.testing().test(
                .GET,
                "auth/email/verify?code=\(captured.emails.first!.verificationCode!)",
                beforeRequest: { req in
                    req.headers.bearerAuthorization = BearerAuthorization(token: accessToken)
                },
                afterResponse: { res async in
                    #expect(res.status == .ok)
                }
            )

            // Now login should succeed
            try await app.testing().test(.POST, "auth/login", beforeRequest: { req in
                try req.content.encode([
                    "email": "verified@example.com",
                    "password": "password123"
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)

                let authUser = try res.content.decode(AuthUser.self)
                #expect(!authUser.accessToken.isEmpty)
                #expect(authUser.user.email == "verified@example.com")
            })
        }
    }

    // MARK: - Phone Verification Tests

    @Test("Phone verification succeeds via POST request with code")
    func phoneVerificationSucceeds() async throws {
        let captured = CapturedMessages()

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            var accessToken = ""

            // Register user
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "phone": "+1234567890",
                    "password": "password123",
                    "confirmPassword": "password123"
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                #expect(captured.sms.count == 1)

                // Get user to create access token
                let store = app.passage.storage.services.store
                let user = try await store.users.find(
                    byIdentifier: Identifier(kind: .phone, value: "+1234567890")
                )
                #expect(user != nil)

                let token = AccessToken(
                    userId: try user!.requiredIdAsString,
                    expiresAt: .now.addingTimeInterval(3600),
                    issuer: "test-issuer",
                    audience: nil,
                    scope: nil
                )
                accessToken = try await app.jwt.keys.sign(token)
            })

            // Verify phone with POST request
            try await app.testing().test(
                .POST,
                "auth/phone/verify",
                beforeRequest: { req in
                    req.headers.bearerAuthorization = BearerAuthorization(token: accessToken)
                    try req.content.encode(["code": captured.sms.first!.code!])
                },
                afterResponse: { res async throws in
                    #expect(res.status == .ok)

                    // Verify user is now marked as verified
                    let store = app.passage.storage.services.store
                    let user = try await store.users.find(
                        byIdentifier: Identifier(kind: .phone, value: "+1234567890")
                    )
                    #expect(user?.isPhoneVerified == true)
                }
            )
        }
    }

    @Test("Phone verification fails with invalid code")
    func phoneVerificationFailsWithInvalidCode() async throws {
        try await withApp(configure: configure) { app in
            var accessToken = ""

            // Register user
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "phone": "+1234567890",
                    "password": "password123",
                    "confirmPassword": "password123"
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)

                // Get user to create access token
                let store = app.passage.storage.services.store
                let user = try await store.users.find(
                    byIdentifier: Identifier(kind: .phone, value: "+1234567890")
                )

                let token = AccessToken(
                    userId: try user!.requiredIdAsString,
                    expiresAt: .now.addingTimeInterval(3600),
                    issuer: "test-issuer",
                    audience: nil,
                    scope: nil
                )
                accessToken = try await app.jwt.keys.sign(token)
            })

            // Attempt verification with wrong code
            try await app.testing().test(
                .POST,
                "auth/phone/verify",
                beforeRequest: { req in
                    req.headers.bearerAuthorization = BearerAuthorization(token: accessToken)
                    try req.content.encode(["code": "WRONGCODE"])
                },
                afterResponse: { res async in
                    #expect(res.status == .unauthorized)
                }
            )
        }
    }

    @Test("Verified phone user can login successfully")
    func verifiedPhoneUserCanLogin() async throws {
        let captured = CapturedMessages()

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            var accessToken = ""

            // Register user
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "phone": "+1234567890",
                    "password": "password123",
                    "confirmPassword": "password123"
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)

                // Get access token
                let store = app.passage.storage.services.store
                let user = try await store.users.find(
                    byIdentifier: Identifier(kind: .phone, value: "+1234567890")
                )
                let token = AccessToken(
                    userId: try user!.requiredIdAsString,
                    expiresAt: .now.addingTimeInterval(3600),
                    issuer: "test-issuer",
                    audience: nil,
                    scope: nil
                )
                accessToken = try await app.jwt.keys.sign(token)
            })

            // Verify phone
            try await app.testing().test(
                .POST,
                "auth/phone/verify",
                beforeRequest: { req in
                    req.headers.bearerAuthorization = BearerAuthorization(token: accessToken)
                    try req.content.encode(["code": captured.sms.first!.code!])
                },
                afterResponse: { res async in
                    #expect(res.status == .ok)
                }
            )

            // Now login should succeed
            try await app.testing().test(.POST, "auth/login", beforeRequest: { req in
                try req.content.encode([
                    "phone": "+1234567890",
                    "password": "password123"
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)

                let authUser = try res.content.decode(AuthUser.self)
                #expect(!authUser.accessToken.isEmpty)
                #expect(authUser.user.phone == "+1234567890")
            })
        }
    }

    // MARK: - Verification Code Resend Tests

    @Test("Email verification code can be resent")
    func emailVerificationCodeCanBeResent() async throws {
        let captured = CapturedMessages()

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            var accessToken = ""

            // Register user (sends first code)
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "email": "resend@example.com",
                    "password": "password123",
                    "confirmPassword": "password123"
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                #expect(captured.emails.count == 1)

                // Get access token
                let store = app.passage.storage.services.store
                let user = try await store.users.find(
                    byIdentifier: Identifier(kind: .email, value: "resend@example.com")
                )
                let token = AccessToken(
                    userId: try user!.requiredIdAsString,
                    expiresAt: .now.addingTimeInterval(3600),
                    issuer: "test-issuer",
                    audience: nil,
                    scope: nil
                )
                accessToken = try await app.jwt.keys.sign(token)
            })

            // Resend verification code
            try await app.testing().test(
                .POST,
                "auth/email/resend",
                beforeRequest: { req in
                    req.headers.bearerAuthorization = BearerAuthorization(token: accessToken)
                },
                afterResponse: { res async in
                    #expect(res.status == .ok)
                    #expect(captured.emails.count == 2)
                    #expect(captured.emails.last?.verificationCode != nil)
                }
            )
        }
    }

    @Test("Phone verification code can be resent")
    func phoneVerificationCodeCanBeResent() async throws {
        let captured = CapturedMessages()

        try await withApp(configure: { app in try await configureWithCapture(app, captured: captured) }) { app in
            var accessToken = ""

            // Register user (sends first code)
            try await app.testing().test(.POST, "auth/register", beforeRequest: { req in
                try req.content.encode([
                    "phone": "+1234567890",
                    "password": "password123",
                    "confirmPassword": "password123"
                ])
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                #expect(captured.sms.count == 1)

                // Get access token
                let store = app.passage.storage.services.store
                let user = try await store.users.find(
                    byIdentifier: Identifier(kind: .phone, value: "+1234567890")
                )
                let token = AccessToken(
                    userId: try user!.requiredIdAsString,
                    expiresAt: .now.addingTimeInterval(3600),
                    issuer: "test-issuer",
                    audience: nil,
                    scope: nil
                )
                accessToken = try await app.jwt.keys.sign(token)
            })

            // Resend verification code
            try await app.testing().test(
                .POST,
                "auth/phone/resend",
                beforeRequest: { req in
                    req.headers.bearerAuthorization = BearerAuthorization(token: accessToken)
                },
                afterResponse: { res async in
                    #expect(res.status == .ok)
                    #expect(captured.sms.count == 2)
                    #expect(captured.sms.last?.code != nil)
                }
            )
        }
    }
}
