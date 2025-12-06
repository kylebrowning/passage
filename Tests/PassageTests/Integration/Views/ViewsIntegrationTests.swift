import Testing
import Vapor
import VaporTesting
import JWTKit
import Leaf
@testable import Passage
@testable import PassageOnlyForTest

@Suite("Views Integration Tests", .tags(.integration))
struct ViewsIntegrationTests {

    // MARK: - Configuration Helpers

    /// Configures a test Vapor application with Passage (views disabled for testing)
    @Sendable private func configure(_ app: Application, viewsConfig: Passage.Configuration.Views) async throws {
        // Note: We don't configure Leaf in tests because template loading from .build directory
        // has security restrictions. These tests verify route registration and 404 behavior only.

        // Add HMAC key for JWT
        await app.jwt.keys.add(
            hmac: HMACKey(from: "test-secret-key-for-jwt-signing"),
            digestAlgorithm: .sha256,
            kid: JWKIdentifier(string: "test-key")
        )

        // Configure Passage with test services
        let store = Passage.OnlyForTest.InMemoryStore()
        let emailDelivery = Passage.OnlyForTest.MockEmailDelivery()
        let phoneDelivery = Passage.OnlyForTest.MockPhoneDelivery()

        let services = Passage.Services(
            store: store,
            random: DefaultRandomGenerator(),
            emailDelivery: emailDelivery,
            phoneDelivery: phoneDelivery,
            federatedLogin: nil
        )

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
            ),
            views: viewsConfig
        )

        try await app.passage.configure(
            services: services,
            configuration: configuration
        )
    }

    // MARK: - Login View 404 Tests

    @Test("Login view returns 404 when not configured")
    func loginViewNotConfigured() async throws {
        let viewsConfig = Passage.Configuration.Views()

        try await withApp(configure: { app in try await configure(app, viewsConfig: viewsConfig) }) { app in
            try await app.testing().test(.GET, "/auth/login", afterResponse: { res in
                #expect(res.status == .notFound)
            })
        }
    }

    // MARK: - Register View 404 Tests

    @Test("Register view returns 404 when not configured")
    func registerViewNotConfigured() async throws {
        let viewsConfig = Passage.Configuration.Views()

        try await withApp(configure: { app in try await configure(app, viewsConfig: viewsConfig) }) { app in
            try await app.testing().test(.GET, "/auth/register", afterResponse: { res in
                #expect(res.status == .notFound)
            })
        }
    }

    // MARK: - Password Reset Request View 404 Tests

    @Test("Password reset request view returns 404 when not configured for email")
    func passwordResetRequestEmailNotConfigured() async throws {
        let viewsConfig = Passage.Configuration.Views()

        try await withApp(configure: { app in try await configure(app, viewsConfig: viewsConfig) }) { app in
            try await app.testing().test(.GET, "/auth/password/reset/email", afterResponse: { res in
                #expect(res.status == .notFound)
            })
        }
    }

    @Test("Password reset request view returns 404 when not configured for phone")
    func passwordResetRequestPhoneNotConfigured() async throws {
        let viewsConfig = Passage.Configuration.Views()

        try await withApp(configure: { app in try await configure(app, viewsConfig: viewsConfig) }) { app in
            try await app.testing().test(.GET, "/auth/password/reset/phone", afterResponse: { res in
                #expect(res.status == .notFound)
            })
        }
    }

    // MARK: - Password Reset Confirm View 404 Tests
    // Note: password-reset-confirm templates don't exist yet, so only testing 404 behavior

    @Test("Password reset confirm view returns 404 when not configured for email")
    func passwordResetConfirmEmailNotConfigured() async throws {
        let viewsConfig = Passage.Configuration.Views()

        try await withApp(configure: { app in try await configure(app, viewsConfig: viewsConfig) }) { app in
            try await app.testing().test(.GET, "/auth/password/reset/email/verify?code=123456", afterResponse: { res in
                #expect(res.status == .notFound)
            })
        }
    }

    @Test("Password reset confirm view returns 404 when not configured for phone")
    func passwordResetConfirmPhoneNotConfigured() async throws {
        let viewsConfig = Passage.Configuration.Views()

        try await withApp(configure: { app in try await configure(app, viewsConfig: viewsConfig) }) { app in
            try await app.testing().test(.GET, "/auth/password/reset/phone/verify?code=123456", afterResponse: { res in
                #expect(res.status == .notFound)
            })
        }
    }

    // MARK: - Configuration Integration Tests

    @Test("Views configuration is properly integrated with Passage configuration")
    func viewsConfigurationIntegration() async throws {
        let theme = Passage.Views.Theme(colors: .defaultLight)
        let loginView = Passage.Configuration.Views.LoginView(
            style: .minimalism,
            theme: theme,
            identifier: .email
        )
        let registerView = Passage.Configuration.Views.RegisterView(
            style: .minimalism,
            theme: theme,
            identifier: .email
        )
        let resetRequestView = Passage.Configuration.Views.PasswordResetRequestView(
            style: .minimalism,
            theme: theme
        )

        let viewsConfig = Passage.Configuration.Views(
            register: registerView,
            login: loginView,
            passwordResetRequest: resetRequestView
        )

        // Verify views are enabled when configured
        #expect(viewsConfig.enabled == true)

        try await withApp(configure: { app in try await configure(app, viewsConfig: viewsConfig) }) { app in
            // Verify app configured successfully with views
            #expect(app.passage.storage.configuration.views.enabled == true)
            #expect(app.passage.storage.configuration.views.login != nil)
            #expect(app.passage.storage.configuration.views.register != nil)
            #expect(app.passage.storage.configuration.views.passwordResetRequest != nil)
        }
    }

    @Test("Views configuration is properly disabled when no views configured")
    func viewsConfigurationDisabled() async throws {
        let viewsConfig = Passage.Configuration.Views()

        // Verify views are disabled when not configured
        #expect(viewsConfig.enabled == false)

        try await withApp(configure: { app in try await configure(app, viewsConfig: viewsConfig) }) { app in
            // Verify app configured successfully without views
            #expect(app.passage.storage.configuration.views.enabled == false)
            #expect(app.passage.storage.configuration.views.login == nil)
            #expect(app.passage.storage.configuration.views.register == nil)
            #expect(app.passage.storage.configuration.views.passwordResetRequest == nil)
            #expect(app.passage.storage.configuration.views.passwordResetConfirm == nil)
        }
    }

    @Test("Different view styles and themes can be configured")
    func differentStylesAndThemes() async throws {
        let loginView = Passage.Configuration.Views.LoginView(
            style: .minimalism,
            theme: Passage.Views.Theme(colors: .defaultLight),
            identifier: .email
        )
        let registerView = Passage.Configuration.Views.RegisterView(
            style: .neobrutalism,
            theme: Passage.Views.Theme(colors: .oceanLight),
            identifier: .phone
        )
        let resetRequestView = Passage.Configuration.Views.PasswordResetRequestView(
            style: .material,
            theme: Passage.Views.Theme(colors: .forestLight)
        )

        let viewsConfig = Passage.Configuration.Views(
            register: registerView,
            login: loginView,
            passwordResetRequest: resetRequestView
        )

        try await withApp(configure: { app in try await configure(app, viewsConfig: viewsConfig) }) { app in
            // Verify different styles are properly configured
            #expect(app.passage.storage.configuration.views.login?.style == .minimalism)
            #expect(app.passage.storage.configuration.views.register?.style == .neobrutalism)
            #expect(app.passage.storage.configuration.views.passwordResetRequest?.style == .material)

            // Verify different identifiers are configured
            #expect(app.passage.storage.configuration.views.login?.identifier == .email)
            #expect(app.passage.storage.configuration.views.register?.identifier == .phone)
        }
    }

    @Test("View redirect configuration is properly stored")
    func viewRedirectConfiguration() async throws {
        let redirect = Passage.Configuration.Views.Redirect(
            onSuccess: "/dashboard",
            onFailure: "/error"
        )
        let loginView = Passage.Configuration.Views.LoginView(
            style: .minimalism,
            theme: Passage.Views.Theme(colors: .defaultLight),
            redirect: redirect,
            identifier: .email
        )

        let viewsConfig = Passage.Configuration.Views(login: loginView)

        try await withApp(configure: { app in try await configure(app, viewsConfig: viewsConfig) }) { app in
            // Verify redirect configuration is stored
            #expect(app.passage.storage.configuration.views.login?.redirect.onSuccess == "/dashboard")
            #expect(app.passage.storage.configuration.views.login?.redirect.onFailure == "/error")
        }
    }
}
