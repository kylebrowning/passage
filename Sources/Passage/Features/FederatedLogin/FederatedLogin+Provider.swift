import Vapor

// MARK: - Federated Login Provider

public extension Passage.FederatedLogin {

    struct Provider: Sendable {
        public struct Name: Sendable, Codable, Hashable, RawRepresentable {
            public let rawValue: String
            public init(rawValue: String) {
                self.rawValue = rawValue
            }
        }

        public enum Credentials: Sendable {
            case conventional
            case client(id: String, secret: String)
        }

        public struct Routes: Sendable {
            struct Login: Sendable {
                let path: [PathComponent]
                init(path: PathComponent...) {
                    self.path = path
                }
                init(path: [PathComponent]) {
                    self.path = path
                }
            }

            struct Callback: Sendable {
                let path: [PathComponent]
                init(path: PathComponent...) {
                    self.path = path
                }
                init(path: [PathComponent]) {
                    self.path = path
                }
            }

            let login: Login
            let callback: Callback

            init(
                login: Login = .init(),
                callback: Callback = .init(path: "callback")
            ) {
                self.login = login
                self.callback = callback
            }
        }

        public let name: Name
        public let credentials: Credentials
        public let scope: [String]
        public let routes: Routes

        init(
            name: Name,
            credentials: Credentials = .conventional,
            scope: [String] = [],
            routes: Routes? = nil,
        ) {
            self.name = name
            self.credentials = credentials
            self.scope = scope
            self.routes = routes ?? .init(
                login: .init(path: name.rawValue.pathComponents),
                callback: .init(path: name.rawValue.pathComponents + ["callback"])
            )

        }
    }

}

// MARK: - Provider Convenience Initializers

public extension Passage.FederatedLogin.Provider {

    static func google(
        credentials: Credentials = .conventional,
        scope: [String] = [],
        routes: Routes? = nil,
    ) -> Self {
        .init(
            name: .google,
            credentials: credentials,
            scope: scope,
            routes: routes,
        )
    }

    static func github(
        credentials: Credentials = .conventional,
        scope: [String] = [],
        routes: Routes? = nil,
    ) -> Self {
        .init(
            name: .github,
            credentials: credentials,
            scope: scope,
            routes: routes,
        )
    }

    static func custom(
        name: String,
        credentials: Credentials = .conventional,
        scope: [String] = [],
        routes: Routes? = nil,
    ) -> Self {
        .init(
            name: .init(rawValue: name),
            credentials: credentials,
            scope: scope,
            routes: routes,
        )
    }
}

// MARK: - Provider Name Convenience Initializers

public extension Passage.FederatedLogin.Provider.Name {
    static let google = named("google")
    static let github = named("github")

    static func named(_ name: String) -> Self {
        return Self(rawValue: name)
    }
}
