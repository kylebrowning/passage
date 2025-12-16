import Vapor

extension Passage.Tokens {

    struct RouteCollection: Vapor.RouteCollection, Sendable {

        init(routes: Passage.Configuration.Routes) {
            self.routes = routes
        }

        let routes: Passage.Configuration.Routes

        func boot(routes builder: any RoutesBuilder) throws {
            let grouped = routes.group.isEmpty ? builder : builder.grouped(routes.group)
            grouped.post(routes.refreshToken.path, use: self.refreshToken)
            grouped.post(routes.exchangeCode.path, use: self.exchangeCode)
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

// MARK: - Exchange Code

extension Passage.Tokens.RouteCollection {

    fileprivate func exchangeCode(_ req: Request) async throws -> AuthUser {
        let form = try req.decodeContentAsFormOfType(req.contracts.exchangeCodeForm)

        return try await req.tokens.exchange(code: form.code)
    }

}
