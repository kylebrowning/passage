import Vapor

// MARK: - Federated Login Configuration

public extension Passage.Configuration {

    struct FederatedLogin: Sendable {
        public struct Routes: Sendable {
            let group: [PathComponent]

            public init(group: PathComponent...) {
                self.group = group
            }

            public init() {
                self.group = ["oauth"]
            }
        }

        public let routes: Routes
        public let providers: [Passage.FederatedLogin.Provider]
        public let redirectLocation: String

        public init(
            routes: Routes = .init(),
            providers: [Passage.FederatedLogin.Provider],
            redirectLocation: String = "/"
        ) {
            self.routes = routes
            self.providers = providers
            self.redirectLocation = redirectLocation
        }
    }

}

// MARK: - Federated Login Path Helpers

public extension Passage.Configuration.FederatedLogin {
    func loginPath(for provider: Passage.FederatedLogin.Provider) -> [PathComponent] {
        return routes.group + provider.routes.login.path
    }
    func callbackPath(for provider: Passage.FederatedLogin.Provider) -> [PathComponent] {
        return routes.group + provider.routes.callback.path
    }
}
