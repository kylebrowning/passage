import Vapor
import WebAuthn

extension Passage.Passkey {

    struct RouteCollection: Vapor.RouteCollection, Sendable {

        let routes: Passage.Configuration.Passkey.Routes
        let group: [PathComponent]

        func boot(routes builder: any RoutesBuilder) throws {
            let grouped = group.isEmpty ? builder : builder.grouped(group)

            // Registration routes (authenticated)
            let protected = grouped.grouped(
                PassageBearerAuthenticator(),
                PassageGuard()
            )
            protected.get(routes.registrationOptions.path, use: beginRegistration)
            protected.post(routes.registrationVerification.path, use: finishRegistration)

            // Authentication routes (public)
            grouped.get(routes.authenticationOptions.path, use: beginAuthentication)
            grouped.post(routes.authenticationVerification.path, use: finishAuthentication)

            // Signup routes (public)
            grouped.post(routes.signupOptions.path.dropLast() + ["options"], use: beginSignup)
            grouped.post(routes.signupVerification.path, use: finishSignup)
        }

    }

}

// MARK: - Registration Handlers

extension Passage.Passkey.RouteCollection {

    @Sendable
    func beginRegistration(_ req: Request) async throws -> Response {
        let user = try req.passage.user
        let passkey = try req.passkey
        let options = try await passkey.beginRegistration(for: user)
        let body = try JSONEncoder().encode(options)
        return Response(
            status: .ok,
            headers: ["Content-Type": "application/json"],
            body: .init(data: body)
        )
    }

    @Sendable
    func finishRegistration(_ req: Request) async throws -> HTTPStatus {
        let user = try req.passage.user
        let credential = try req.content.decode(RegistrationCredential.self)
        let passkey = try req.passkey
        try await passkey.finishRegistration(credential: credential, for: user)
        return .ok
    }

}

// MARK: - Authentication Handlers

extension Passage.Passkey.RouteCollection {

    @Sendable
    func beginAuthentication(_ req: Request) async throws -> Response {
        let passkey = try req.passkey
        let sessionId = UUID().uuidString
        let options = passkey.webAuthn.beginAuthentication(
            timeout: passkey.config.challengeTimeout,
            userVerification: passkey.config.userVerification
        )

        try await passkey.passkeyChallenges.storeChallenge(
            options.challenge,
            for: sessionId,
            type: .authentication
        )

        let response = PasskeyBeginAuthenticationResponse(
            options: options,
            challengeKey: sessionId
        )
        return try await response.encodeResponse(for: req)
    }

    @Sendable
    func finishAuthentication(_ req: Request) async throws -> AuthUser {
        let form = try req.decodeContentAsFormOfType(req.contracts.passkeyAuthenticationFinishForm)
        let passkey = try req.passkey
        return try await passkey.finishAuthentication(
            credential: form.credential,
            challengeKey: form.challengeKey
        )
    }

}

// MARK: - Signup Handlers

extension Passage.Passkey.RouteCollection {

    @Sendable
    func beginSignup(_ req: Request) async throws -> Response {
        let form = try req.decodeContentAsFormOfType(req.contracts.passkeySignupBeginForm)
        let passkey = try req.passkey
        let challengeKey = form.username ?? UUID().uuidString

        let options = try await passkey.beginSignup(username: form.username)

        let response = PasskeyBeginSignupResponse(
            options: options,
            challengeKey: challengeKey
        )
        return try await response.encodeResponse(for: req)
    }

    @Sendable
    func finishSignup(_ req: Request) async throws -> AuthUser {
        let form = try req.decodeContentAsFormOfType(req.contracts.passkeySignupFinishForm)
        let passkey = try req.passkey
        return try await passkey.finishSignup(
            credential: form.credential,
            challengeKey: form.challengeKey
        )
    }

}
