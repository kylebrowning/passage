import Vapor

extension Passage.Tokens {

    struct RouteCollection: Vapor.RouteCollection {

        init(routes: Passage.Configuration.Routes) {
            self.routes = routes
        }

        let routes: Passage.Configuration.Routes

        func boot(routes builder: any RoutesBuilder) throws {
            let grouped = routes.group.isEmpty ? builder : builder.grouped(routes.group)
            grouped.post(routes.refreshToken.path, use: self.refreshToken)
        }

    }

}

// MARK: - Refresh Token

extension Passage.Tokens.RouteCollection {

    fileprivate func refreshToken(_ req: Request) async throws -> AuthUser {
        let form = try req.decodeContentAsFormOfType(req.contracts.refreshTokenForm)

        return try await req.tokens.refresh(using: form.refreshToken)
    }

}
