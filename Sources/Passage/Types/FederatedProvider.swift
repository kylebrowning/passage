public struct FederatedProvider: Sendable {
    public let name: Name
    public let credentials: Credentials
    public let scope: [String]

    init(
        name: Name,
        credentials: Credentials = .conventional,
        scope: [String] = [],
    ) {
        self.name = name
        self.credentials = credentials
        self.scope = scope
    }
}

// MARK: - Provider Name

public extension FederatedProvider {
    struct Name: LosslessStringConvertible, Codable, Hashable, Equatable, Sendable {
        public let description: String
        public init(_ description: String) {
            self.description = description
        }
    }
}

// MARK: - Provider Credentials

public extension FederatedProvider {

    enum Credentials: Sendable {
        case conventional
        case client(id: String, secret: String)
    }
}

// MARK: - Provider Convenience Initializers

public extension FederatedProvider {

    static func google(
        credentials: Credentials = .conventional,
        scope: [String] = [],
    ) -> Self {
        .init(
            name: .google,
            credentials: credentials,
            scope: scope,
        )
    }

    static func github(
        credentials: Credentials = .conventional,
        scope: [String] = [],
    ) -> Self {
        .init(
            name: .github,
            credentials: credentials,
            scope: scope,
        )
    }

    static func custom(
        name: String,
        credentials: Credentials = .conventional,
        scope: [String] = [],
    ) -> Self {
        .init(
            name: .init(name),
            credentials: credentials,
            scope: scope,
        )
    }
}

// MARK: - Provider Name Convenience Initializers

public extension FederatedProvider.Name {
    static let google = named("google")
    static let github = named("github")

    static func named(_ name: String) -> Self {
        return Self(name)
    }
}
