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
                do {
                    try await req.views.handleResetPasswordRequestForm()
                    return req.redirect(
                        to: buildRedirectLocation(
                            for: group + path,
                            success: "If an account with that identifier exists, a password reset link has been sent."
                        )
                    )
                } catch let error as AuthenticationError {
                    return req.redirect(
                        to: buildRedirectLocation(
                            for: group + path,
                            error: error.reason
                        )
                    )
                } catch {
                    return req.redirect(
                        to: buildRedirectLocation(
                            for: group + path,
                            error: "An unexpected error occurred. Please try again."
                        )
                    )
                }
            }
        }
    }

}

extension ViewsRouteCollection {

    func buildRedirectLocation(
        for path: [PathComponent],
        params: [String: String?] = [:],
        success: String? = nil,
        error: String? = nil,
    ) -> String {
        var components = URLComponents()
        components.path = "/\(path.string)"
        components.queryItems = params.map { key, value in
            URLQueryItem(name: key, value: value)
        }
        if let success {
            components.queryItems?.append(URLQueryItem(name: "success", value: success))
        }
        if let error {
            components.queryItems?.append(URLQueryItem(name: "error", value: error))
        }
        return components.string ?? "/\(path.string)"
    }

}
