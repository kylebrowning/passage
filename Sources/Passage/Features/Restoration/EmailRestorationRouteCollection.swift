import Vapor

struct EmailRestorationRouteCollection: RouteCollection {

    let config: Passage.Configuration.Restoration.Email
    let groupPath: [PathComponent]

    func boot(routes builder: any RoutesBuilder) throws {
        let grouped = groupPath.isEmpty ? builder : builder.grouped(groupPath)

        grouped.post(config.routes.request.path, use: request)
        grouped.post(config.routes.verify.path, use: verify)
        grouped.post(config.routes.resend.path, use: resend)
    }

}

// MARK: - Request Reset

extension EmailRestorationRouteCollection {

    func request(_ req: Request) async throws -> HTTPStatus {
        let form = try req.decodeContentAsFormOfType(req.contracts.emailPasswordResetRequestForm)
        let identifier = Identifier(kind: .email, value: form.email)
        try await req.restoration.requestReset(for: identifier)
        return .ok
    }

}

// MARK: - Verify and Reset Password

extension EmailRestorationRouteCollection {

    func verify(_ req: Request) async throws -> HTTPStatus {
        let form = try req.decodeContentAsFormOfType(req.contracts.emailPasswordResetVerifyForm)
        let identifier = Identifier(kind: .email, value: form.email)

        // Hash the new password
        let passwordHash = try Bcrypt.hash(form.newPassword)

        try await req.restoration.verifyAndResetPassword(
            identifier: identifier,
            code: form.code,
            newPasswordHash: passwordHash
        )

        return .ok
    }

}

// MARK: - Resend

extension EmailRestorationRouteCollection {

    func resend(_ req: Request) async throws -> HTTPStatus {
        let form = try req.decodeContentAsFormOfType(req.contracts.emailPasswordResetResendForm)
        try await req.restoration.resendPasswordResetCode(toEmail: form.email)
        return .ok
    }

}
