import Vapor

extension Passage.Passwordless {

    struct MagicLinkEmailRouteCollection: Vapor.RouteCollection {

        let routes: Passage.Configuration.Passwordless.MagicLink.Routes
        let group: [PathComponent]

        func boot(routes builder: any RoutesBuilder) throws {
            let grouped = group.isEmpty ? builder : builder.grouped(group)

            grouped.post(routes.request.path, use: request)
            grouped.get(routes.verify.path, use: verify)
            grouped.post(routes.resend.path, use: resend)
        }

    }

}

// MARK: - Request Magic Link

extension Passage.Passwordless.MagicLinkEmailRouteCollection {

    func request(_ req: Request) async throws -> HTTPStatus {
        let form = try req.decodeContentAsFormOfType(req.contracts.emailMagicLinkRequestForm)
        try await req.passwordless.requestEmailMagicLink(email: form.email)
        return .ok
    }

}

// MARK: - Verify Magic Link

extension Passage.Passwordless.MagicLinkEmailRouteCollection {

    func verify(_ req: Request) async throws -> AuthUser {
        let form = try req.query.decode(Passage.DefaultEmailMagicLinkVerifyForm.self)
        return try await req.passwordless.verifyEmailMagicLink(token: form.token)
    }

}

// MARK: - Resend Magic Link

extension Passage.Passwordless.MagicLinkEmailRouteCollection {

    func resend(_ req: Request) async throws -> HTTPStatus {
        let form = try req.decodeContentAsFormOfType(req.contracts.emailMagicLinkResendForm)
        try await req.passwordless.resendEmailMagicLink(email: form.email)
        return .ok
    }

}
