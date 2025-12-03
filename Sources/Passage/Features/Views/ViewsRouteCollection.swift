import Vapor

struct ViewsRouteCollection: RouteCollection {

    let config: Passage.Configuration.Views
    let group: [PathComponent]

    func boot(routes builder: any RoutesBuilder) throws {
        let grouped = group.isEmpty ? builder : builder.grouped(group)

        if let view = config.passwordResetRequest {
            let path = view.route.path
            grouped.get(path) { req in
                try await req.views.renderResetPasswordRequestView()
            }
            grouped.post(path) { req in
                var components = URLComponents()
                components.path = path.string
                components.queryItems = [
                    URLQueryItem(name: "success", value: "Request received. If an account with that email exists, you will receive a password reset link shortly.")
                ]
                return req.redirect(to: components.string ?? path.string)
            }
        }
    }

}

extension ViewsRouteCollection {

//    @Sendable
//    func renderPasswordResetRequestView(_ req: Request) async throws -> View {
//        return try await req.views.renderResetPasswordRequestView()
//    }

//    @Sendable
//    func handlePasswordResetRequestSubmit(_ req: Request) async throws -> Response {
//        guard let view = config.passwordResetRequest else {
//            throw Abort(.notFound)
//        }
//        return req.redirect(
//            to: buildFormURL(
//                email: form.email,
//                success: "Password reset successfully. You can now log in with your new password.",
//            )
//        )
//    }
}
