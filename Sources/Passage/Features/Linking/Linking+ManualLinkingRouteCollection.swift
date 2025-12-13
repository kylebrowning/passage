import Vapor

extension Passage.Linking {

    struct RouteCollection: Vapor.RouteCollection, Sendable {

        let configuration: Passage.Configuration

        private var group: [PathComponent] {
            return configuration.routes.group
        }

        func boot(routes builder: any Vapor.RoutesBuilder) throws {
            let grouped = group.isEmpty ? builder : builder.grouped(configuration.routes.group)

            // Handle a form sent from the Link Account Select view
            grouped.post(configuration.oauth.linkSelectPath) { req in
                do {
                    let form = try req.decodeContentAsFormOfType(req.contracts.linkAccountSelectForm)

                    try await req.linking.manual.advance(withSelectedUserId: form.selectedUserId)

                    guard req.isFormSubmission, req.isWaitingForHTML, let view = req.configuration.views.oauthLinkSelect else {
                        return try await HTTPStatus.ok.encodeResponse(for: req)
                    }

                    return req.views.handleLinkAccountSelectFormSubmit(
                        of: view,
                        at: group + configuration.oauth.linkVerifyPath,
                    )
                } catch {
                    guard req.isFormSubmission, req.isWaitingForHTML, let view = req.configuration.views.oauthLinkSelect else {
                        throw error
                    }

                    return req.views.handleLinkAccountSelectFormFailure(
                        of: view,
                        at: group + configuration.oauth.linkSelectPath,
                        with: error
                    )
                }
            }

            // Handle a form sent from the Link Account Verify view
            grouped.post(configuration.oauth.linkVerifyPath) { req in
                do {
                    let form = try req.decodeContentAsFormOfType(req.contracts.linkAccountVerifyForm)

                    let user = try await req.linking.manual.complete(
                        password: form.password,
                        verificationCode: form.verificationCode,
                    )

                    guard req.isFormSubmission, req.isWaitingForHTML, let view = req.configuration.views.oauthLinkVerify else {
                        let redirectURL = buildRedirectURL(
                            base: configuration.oauth.redirectLocation,
                            code: try await req.tokens.createExchangeCode(for: user)
                        )
                        return req.redirect(to: redirectURL)
                    }

                    return req.views.handleLinkAccountVerifyFormSubmit(
                        of: view,
                        at: group + configuration.oauth.linkVerifyPath,
                    )
                } catch {
                    guard req.isFormSubmission, req.isWaitingForHTML, let view = req.configuration.views.oauthLinkVerify else {
                        return try await HTTPStatus.ok.encodeResponse(for: req)
                    }

                    return req.views.handleLinkAccountVerifyFormFailure(
                        of: view,
                        at: group + configuration.oauth.linkVerifyPath,
                        with: error
                    )
                }
            }
        }

    }

}

extension Passage.Linking.RouteCollection {

    private func buildRedirectURL(base: String, code: String) -> String {
        if base.contains("?") {
            return "\(base)&code=\(code)"
        } else {
            return "\(base)?code=\(code)"
        }
    }

}
