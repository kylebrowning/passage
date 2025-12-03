import Vapor

struct PhoneRestorationRouteCollection: RouteCollection {

    let config: Passage.Configuration.Restoration.Phone
    let groupPath: [PathComponent]

    func boot(routes builder: any RoutesBuilder) throws {
        let grouped = groupPath.isEmpty ? builder : builder.grouped(groupPath)

        grouped.post(config.routes.request.path, use: request)
        grouped.post(config.routes.verify.path, use: verify)
        grouped.post(config.routes.resend.path, use: resend)
    }

}

// MARK: - Request Reset

extension PhoneRestorationRouteCollection {

    func request(_ req: Request) async throws -> HTTPStatus {
        let form = try req.decodeContentAsFormOfType(req.contracts.phonePasswordResetRequestForm)
        let identifier = Identifier(kind: .phone, value: form.phone)
        try await req.restoration.requestReset(for: identifier)
        return .ok
    }

}

// MARK: - Verify and Reset Password

extension PhoneRestorationRouteCollection {

    func verify(_ req: Request) async throws -> HTTPStatus {
        let form = try req.decodeContentAsFormOfType(req.contracts.phonePasswordResetVerifyForm)
        let identifier = Identifier(kind: .phone, value: form.phone)

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

extension PhoneRestorationRouteCollection {

    struct ResendForm: Content {
        let phone: String
    }

    func resend(_ req: Request) async throws -> HTTPStatus {
        let form = try req.decodeContentAsFormOfType(req.contracts.phonePasswordResetResendForm)
        try await req.restoration.resendPasswordResetCode(toPhone: form.phone)
        return .ok
    }

}
