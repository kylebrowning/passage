import Vapor

// MARK: - Views Configuration

public extension Passage.Configuration {

    struct Views: Sendable {

        protocol View: Sendable {
            var name: String { get }
            var style: Passage.Views.Style { get }
            var theme: Passage.Views.Theme { get }
        }

        let passwordResetRequest: PasswordResetRequestView?
        let passwordResetConfirm: PasswordResetConfirmView?

        public init(
            passwordResetRequest: PasswordResetRequestView? = nil,
            passwordResetConfirm: PasswordResetConfirmView? = nil,
        ) {
            self.passwordResetRequest = passwordResetRequest
            self.passwordResetConfirm = passwordResetConfirm
        }
    }

}

// MARK: Views Extension

extension Passage.Configuration.Views {

    var enabled: Bool {
        return passwordResetRequest != nil || passwordResetConfirm != nil
    }
}

// MARK: View Template Extension

extension Passage.Configuration.Views.View {

    var template: String {
        return "\(name)-\(style.templateSuffix)"
    }
}

// MARK: - Password Reset Views

public extension Passage.Configuration.Views {

    struct PasswordResetRequestView: Sendable, View {
        public struct Route: Sendable {
            let path: [PathComponent]
            public init(path: PathComponent...) {
                self.path = path
            }
        }

        let name: String = "password-reset-request"
        let route: Route
        let style: Passage.Views.Style
        let theme: Passage.Views.Theme

        public init(
            route: Route = Route(path: "password", "reset", "request"),
            style: Passage.Views.Style,
            theme: Passage.Views.Theme,
        ) {
            self.route = route
            self.style = style
            self.theme = theme
        }
    }

    struct PasswordResetConfirmView: Sendable, View {

        public struct Route: Sendable {
            let path: [PathComponent]
            public init(path: PathComponent...) {
                self.path = path
            }
        }

        let name: String = "password-reset-confirm"
        let route: Route
        let style: Passage.Views.Style
        let theme: Passage.Views.Theme

        public init(
            route: Route = Route(path: "password", "reset", "confirm"),
            style: Passage.Views.Style,
            theme: Passage.Views.Theme,
        ) {
            self.route = route
            self.style = style
            self.theme = theme
        }
    }

}
