import Foundation
import Vapor

extension Passage {

    struct Tokens {
        let request: Request
    }

}

// MARK: - Request Extension

extension Request {
    var tokens: Passage.Tokens {
        Passage.Tokens(request: self)
    }
}

// MARK: - Service Accessors

extension Passage.Tokens {

    var store: any Passage.Store {
        request.store
    }

    var configuration: Passage.Configuration.Tokens {
        request.configuration.tokens
    }

    var random: any Passage.RandomGenerator {
        request.random
    }

}

// MARK: - Issue Token

extension Passage.Tokens {

    func issue(
        for user: any User,
        revokeExisting: Bool = true
    ) async throws -> AuthUser {
        if revokeExisting {
            try await revoke(for: user)
        }

        let accessToken = AccessToken(
            userId: try user.requiredIdAsString,
            expiresAt: .now.addingTimeInterval(configuration.accessToken.timeToLive),
            issuer: configuration.issuer,
            audience: nil,
            scope: nil
        )

        let opaqueToken = random.generateOpaqueToken()
        try await store.tokens.createRefreshToken(
            for: user,
            tokenHash: random.hashOpaqueToken(token: opaqueToken),
            expiresAt: .now.addingTimeInterval(configuration.refreshToken.timeToLive)
        )

        return AuthUser(
            accessToken: try await request.jwt.sign(accessToken),
            refreshToken: opaqueToken,
            tokenType: "Bearer",
            expiresIn: configuration.accessToken.timeToLive,
            user: .init(
                id: try user.requiredIdAsString,
                email: user.email,
                phone: user.phone
            )
        )
    }

}

// MARK: - Refresh Token

extension Passage.Tokens {

    func refresh(using opaqueRefreshToken: String) async throws -> AuthUser {
        let hash = random.hashOpaqueToken(token: opaqueRefreshToken)

        guard let refreshToken = try await store.tokens.find(refreshTokenHash: hash) else {
            throw AuthenticationError.refreshTokenNotFound
        }

        guard refreshToken.isValid else {
            try await store.tokens.revoke(refreshTokenFamilyStartingFrom: refreshToken)
            throw AuthenticationError.invalidRefreshToken
        }

        let user = refreshToken.user

        let opaqueToken = random.generateOpaqueToken()
        try await store.tokens.createRefreshToken(
            for: user,
            tokenHash: random.hashOpaqueToken(token: opaqueToken),
            expiresAt: .now.addingTimeInterval(configuration.refreshToken.timeToLive),
            replacing: refreshToken
        )

        let accessToken = AccessToken(
            userId: try user.requiredIdAsString,
            expiresAt: .now.addingTimeInterval(configuration.accessToken.timeToLive),
            issuer: configuration.issuer,
            audience: nil,
            scope: nil
        )

        return AuthUser(
            accessToken: try await request.jwt.sign(accessToken),
            refreshToken: opaqueToken,
            tokenType: "Bearer",
            expiresIn: configuration.accessToken.timeToLive,
            user: .init(
                id: try user.requiredIdAsString,
                email: user.email,
                phone: user.phone
            )
        )
    }

}

// MARK: - Revoke Token

extension Passage.Tokens {

    func revoke(for user: any User) async throws {
        try await store.tokens.revokeRefreshToken(for: user)
    }

}
