import Vapor

struct IdentityRouteCollection: RouteCollection {

    init(routes: Passage.Configuration.Routes) {
        self.routes = routes
    }

    let routes: Passage.Configuration.Routes

    func boot(routes builder: any RoutesBuilder) throws {
        let grouped = routes.group.isEmpty ? builder : builder.grouped(routes.group)
        grouped.post(routes.register.path, use: self.register)
        grouped.post(routes.login.path, use: self.login)
        grouped.post(routes.refreshToken.path, use: self.refreshToken)
        grouped.post(routes.logout.path, use: self.logout)
        grouped.get(routes.currentUser.path, use: self.currentUser)
    }

}

// MARK: - Registration

extension IdentityRouteCollection {

    fileprivate func register(_ req: Request) async throws -> HTTPStatus {
        let register = try req.decodeContentAsFormOfType(req.contracts.registerForm)

        try await req.identity.register(form: register)

        return .ok
    }

}

// MARK: - Login

extension IdentityRouteCollection {

    fileprivate func login(_ req: Request) async throws -> AuthUser {
        let login = try req.decodeContentAsFormOfType(req.contracts.loginForm)

        return try await req.identity.login(form: login)
    }

}

// MARK: - Token Refresh

extension IdentityRouteCollection {

    fileprivate func refreshToken(_ req: Request) async throws -> AuthUser {
        let form = try req.decodeContentAsFormOfType(req.contracts.refreshTokenForm)

        return try await req.identity.refreshToken(form: form)
    }

}

// MARK: - Logout

extension IdentityRouteCollection {

    fileprivate func logout(_ req: Request) async throws -> HTTPStatus {
        let _ = try await req.decodeContentAsFormOfType(req.contracts.logoutForm)

        guard let user = req.auth.get(req.store.users.userType) else {
            return .ok
        }

        defer {
            req.auth.logout(req.store.users.userType)
        }

        try await req.identity.logout(user: user)

        return .ok
    }

}

// MARK: - Current User

extension IdentityRouteCollection {

    fileprivate func currentUser(_ req: Request) async throws -> AuthUser.User {
        let accessToken = try await req.jwt.verify(as: AccessToken.self)

        return try await req.identity.currentUser(accessToken: accessToken)
    }

}
