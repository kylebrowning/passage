//
//  Identity.swift
//  passten
//
//  Created by Max Rozdobudko on 11/6/25.
//

import Vapor
import JWT
import Queues
import struct NIOConcurrencyHelpers.NIOLock
import NIOCore
import NIOPosix

final class Identity: @unchecked Sendable {

    init(app: Application) {
        self.app = app
        self.lock = .init()
    }

    private let app: Application

    private let lock: NIOLock

    // MARK: - Injectable Dependencies

    private var _store: (any Store)?
    private var _deliveryEmail: (any Verification.EmailDelivery)?
    private var _deliveryPhone: (any Verification.PhoneDelivery)?

    // MARK: - Configuration State

    private var _tokens: Configuration.Tokens = .init()
    private var _verification: Configuration.Verification = .init()
    private var _random: (any RandomGenerator) = DefaultRandomGenerator()

    // MARK: - Accessors

    var store: any Store {
        get throws {
            guard let store = lock.withLock({ _store }) else {
                throw IdentityError.storeNotConfigured
            }
            return store
        }
    }

    var deliveryEmail: (any Verification.EmailDelivery)? {
        lock.withLock { _deliveryEmail }
    }

    var deliveryPhone: (any Verification.PhoneDelivery)? {
        lock.withLock { _deliveryPhone }
    }

    var tokens: Configuration.Tokens {
        lock.withLock { _tokens }
    }

    var verification: Configuration.Verification {
        lock.withLock { _verification }
    }

    var random: any RandomGenerator {
        lock.withLock { _random }
    }

    // MARK: - Configuration

    func configure(
        jwks: Configuration.JWKS,
        store: any Store,
        deliveryEmail: (any Verification.EmailDelivery)? = nil,
        deliveryPhone: (any Verification.PhoneDelivery)? = nil,
        routes: Routes = .init(),
        tokens: Configuration.Tokens = .init(),
        verification: Configuration.Verification = .init(),
        random: any RandomGenerator = DefaultRandomGenerator()
    ) async throws {
        lock.withLockVoid {
            self._store = store
            self._deliveryEmail = deliveryEmail
            self._deliveryPhone = deliveryPhone
            self._tokens = tokens
            self._verification = verification
            self._random = random
        }

        try await app.jwt.keys.add(jwksJSON: jwks.json)

        try app.register(collection: IdentityRouteCollection(routes: routes))

        // Register email verification routes if delivery is provided
        if let _ = deliveryEmail, let emailConfig = verification.email {
            try app.register(collection: EmailVerificationRouteCollection(
                config: emailConfig,
                groupPath: routes.group
            ))
        }

        // Register phone verification routes if delivery is provided
        if let _ = deliveryPhone, let phoneConfig = verification.phone {
            try app.register(collection: PhoneVerificationRouteCollection(
                config: phoneConfig,
                groupPath: routes.group
            ))
        }

        // Register verification jobs if queues are enabled
        if verification.useQueues {
            app.queues.add(Verification.SendEmailCodeJob())
            app.queues.add(Verification.SendPhoneCodeJob())
        }
    }

}

// MARK: - Store

extension Identity {

    protocol Store: Sendable {
        var users: any UserStore { get }
        var tokens: any TokenStore { get }
        var codes: any CodeStore { get }
    }

    protocol UserStore: Sendable {
        func create(with credential: Credential) async throws
        func find(byId id: String) async throws -> (any User)?
        func find(byCredential credential: Credential) async throws -> (any User)?
        func find(byIdentifier identifier: Identifier) async throws -> (any User)?
        func markEmailVerified(for user: any User) async throws
        func markPhoneVerified(for user: any User) async throws
    }

    protocol TokenStore: Sendable {
        @discardableResult
        func createRefreshToken(
            for user: any User,
            tokenHash hash: String,
            expiresAt: Date,
        ) async throws -> any RefreshToken

        @discardableResult
        func createRefreshToken(
            for user: any User,
            tokenHash hash: String,
            expiresAt: Date,
            replacing tokenToReplace: (any RefreshToken)?
        ) async throws -> any RefreshToken

        func find(refreshTokenHash hash: String) async throws -> (any RefreshToken)?
        func revokeRefreshToken(for user: any User) async throws
        func revokeRefreshToken(withHash hash: String) async throws
        func revoke(refreshTokenFamilyStartingFrom token: any RefreshToken) async throws
    }

    protocol CodeStore: Sendable {
        // MARK: - Email Codes

        /// Create a new email verification code
        @discardableResult
        func createEmailCode(
            for user: any User,
            email: String,
            codeHash: String,
            expiresAt: Date
        ) async throws -> any Verification.EmailCode

        /// Find email verification code by email and code hash
        func findEmailCode(
            forEmail email: String,
            codeHash: String
        ) async throws -> (any Verification.EmailCode)?

        /// Invalidate all pending codes for email
        func invalidateEmailCodes(forEmail email: String) async throws

        /// Increment failed attempt count for email code
        func incrementFailedAttempts(for code: any Verification.EmailCode) async throws

        // MARK: - Phone Codes

        /// Create a new phone verification code
        @discardableResult
        func createPhoneCode(
            for user: any User,
            phone: String,
            codeHash: String,
            expiresAt: Date
        ) async throws -> any Verification.PhoneCode

        /// Find phone verification code by phone and code hash
        func findPhoneCode(
            forPhone phone: String,
            codeHash: String
        ) async throws -> (any Verification.PhoneCode)?

        /// Invalidate all pending codes for phone
        func invalidatePhoneCodes(forPhone phone: String) async throws

        /// Increment failed attempt count for phone code
        func incrementFailedAttempts(for code: any Verification.PhoneCode) async throws
    }

}


// MARK: - Route

extension Identity {

    struct Routes: Sendable {
        struct Register {
            static let `default` = Register(path: "register")
            let path: [PathComponent]
            init(path: PathComponent...) {
                self.path = path
            }
        }

        struct Login {
            static let `default` = Login(path: "login")
            let path: [PathComponent]
            init(path: PathComponent...) {
                self.path = path
            }
        }

        struct Logout {
            static let `default` = Logout(path: "logout")
            let path: [PathComponent]
            init(path: PathComponent...) {
                self.path = path
            }
        }

        struct RefreshToken {
            static let `default` = RefreshToken(path: "refresh-token")
            let path: [PathComponent]
            init(path: PathComponent...) {
                self.path = path
            }
        }

        struct CurrentUser {
            static let `default` = CurrentUser(path: "me")
            let path: [PathComponent]
            init(path: PathComponent...) {
                self.path = path
            }
        }

        private init(
            group: [PathComponent],
            register: Register,
            login: Login,
            logout: Logout,
            refreshToken: RefreshToken,
            currentUser: CurrentUser,
        ) {
            self.group = group
            self.register = register
            self.login = login
            self.logout = logout
            self.refreshToken = refreshToken
            self.currentUser = currentUser
        }

        init(
            group: PathComponent...,
            register: Register         = .default,
            login: Login               = .default,
            logout: Logout             = .default,
            refreshToken: RefreshToken = .default,
            currentUser: CurrentUser   = .default,
        ) {
            self.init(
                group: group,
                register: register,
                login: login,
                logout: logout,
                refreshToken: refreshToken,
                currentUser: currentUser
            )
        }

        init(
            register: Register         = .default,
            login: Login               = .default,
            logout: Logout             = .default,
            refreshToken: RefreshToken = .default,
            currentUser: CurrentUser   = .default,
        ) {
            self.init(
                group: ["auth"],
                register: register,
                login: login,
                logout: logout,
                refreshToken: refreshToken,
                currentUser: currentUser
            )
        }

        let group: [PathComponent]
        let register: Register
        let login: Login
        let logout: Logout
        let refreshToken: RefreshToken
        let currentUser: CurrentUser
    }
}

// MARK: - Random

extension Identity {
    protocol RandomGenerator: Sendable {
        func generateRandomString(count: Int) -> String
        func generateOpaqueToken() -> String
        func hashOpaqueToken(token: String) -> String
        func generateVerificationCode(length: Int) -> String
    }
}

struct DefaultRandomGenerator: Identity.RandomGenerator {
    func generateRandomString(count: Int) -> String {
        Data([UInt8].random(count: count)).base64EncodedString()
    }
    func generateOpaqueToken() -> String {
        generateRandomString(count: 32)
    }
    func hashOpaqueToken(token: String) -> String {
        SHA256.hash(data: Data(token.utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
    func generateVerificationCode(length: Int) -> String {
        // Alphanumeric characters excluding confusing ones (0/O, 1/I/L)
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<length).map { _ in characters.randomElement()! })
    }
}



// MARK: - Application Storage

extension Identity {
    struct Key: StorageKey {
        typealias Value = Identity
    }
}

extension Application {

    var identity: Identity {
        if let identity = storage[Identity.Key.self] {
            return identity
        }
        let identity = Identity(app: self)
        storage[Identity.Key.self] = identity
        return identity
    }

}

extension Request {

    var store: any Identity.Store {
        get throws {
            try application.identity.store
        }
    }

    var deliveryEmail: (any Identity.Verification.EmailDelivery)? {
        application.identity.deliveryEmail
    }

    var deliveryPhone: (any Identity.Verification.PhoneDelivery)? {
        application.identity.deliveryPhone
    }

    var tokens: Identity.Configuration.Tokens {
        application.identity.tokens
    }

    var verificationConfig: Identity.Configuration.Verification {
        application.identity.verification
    }

    var random: any Identity.RandomGenerator {
        application.identity.random
    }

    var verificationService: Identity.Verification.Service {
        get throws {
            try Identity.Verification.Service(
                request: self,
                store: store,
                random: random,
                deliveryEmail: deliveryEmail,
                deliveryPhone: deliveryPhone,
                config: application.identity.verification
            )
        }
    }
}
