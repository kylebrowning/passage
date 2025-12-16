import Testing
@testable import Passage

@Suite("FederatedProvider Struct Tests")
struct FederatedProviderStructTests {

    // MARK: - Provider Nested Type Tests

    @Test("Provider is nested within FederatedLogin")
    func providerNesting() {
        let typeName = String(reflecting: FederatedProvider.self)
        #expect(typeName.contains("FederatedProvider"))
    }

    @Test("Provider Name is nested within Provider")
    func providerNameNesting() {
        let typeName = String(reflecting: FederatedProvider.Name.self)
        #expect(typeName.contains("FederatedProvider.Name"))
    }

    @Test("Provider Credentials is nested within Provider")
    func providerCredentialsNesting() {
        let typeName = String(reflecting: FederatedProvider.Credentials.self)
        #expect(typeName.contains("FederatedProvider.Credentials"))
    }

    // MARK: - All Sendable Conformance Tests

    @Test("All FederatedLogin types conform to Sendable")
    func allTypesSendable() {
        #expect(FederatedProvider.self is Sendable.Type)
        #expect(FederatedProvider.Name.self is Sendable.Type)
        #expect(FederatedProvider.Credentials.self is Sendable.Type)

    }

    // MARK: - Type Hierarchy Tests

    @Test("FederatedLogin namespace contains Provider")
    func namespaceContainsProvider() {
        // Create a provider to verify it's accessible through FederatedLogin
        let provider = FederatedProvider.google()
        #expect(provider.name.description == "google")
    }

    // MARK: - Integration Tests

    @Test("Can create multiple providers with different configurations")
    func multipleProviderConfigurations() {
        let providers: [FederatedProvider] = [
            .google(scope: ["email"]),
            .github(scope: ["user"]),
            .custom(name: "custom", scope: ["openid"])
        ]

        #expect(providers.count == 3)
        #expect(providers[0].name.description == "google")
        #expect(providers[1].name.description == "github")
        #expect(providers[2].name.description == "custom")
    }

    @Test("Provider with different credential types")
    func differentCredentialTypes() {
        let conventional = FederatedProvider.google()
        let withClient = FederatedProvider.google(
            credentials: .client(id: "id", secret: "secret")
        )

        if case .conventional = conventional.credentials {
            // Success
        } else {
            Issue.record("Expected conventional credentials")
        }

        if case .client = withClient.credentials {
            // Success
        } else {
            Issue.record("Expected client credentials")
        }
    }

    // MARK: - Name Equality Tests

    @Test("Provider names with same rawValue are equal")
    func nameEquality() {
        let name1 = FederatedProvider.Name("test")
        let name2 = FederatedProvider.Name("test")

        #expect(name1 == name2)
    }

    @Test("Provider names with different rawValue are not equal")
    func nameInequality() {
        let name1 = FederatedProvider.Name("test1")
        let name2 = FederatedProvider.Name("test2")

        #expect(name1 != name2)
    }

    @Test("Static provider names are equal to constructed ones")
    func staticNameEquality() {
        let staticGoogle = FederatedProvider.Name.google
        let constructedGoogle = FederatedProvider.Name("google")

        #expect(staticGoogle == constructedGoogle)
    }

    // MARK: - Scope Tests

    @Test("Provider with empty scope")
    func emptyScope() {
        let provider = FederatedProvider.google()
        #expect(provider.scope.isEmpty)
    }

    @Test("Provider with single scope")
    func singleScope() {
        let provider = FederatedProvider.google(scope: ["email"])
        #expect(provider.scope == ["email"])
    }

    @Test("Provider with multiple scopes")
    func multipleScopes() {
        let provider = FederatedProvider.google(scope: ["email", "profile", "openid"])
        #expect(provider.scope.count == 3)
        #expect(provider.scope.contains("email"))
        #expect(provider.scope.contains("profile"))
        #expect(provider.scope.contains("openid"))
    }

    // MARK: - Credentials Pattern Matching Tests

    @Test("Can pattern match conventional credentials")
    func conventionalPatternMatching() {
        let provider = FederatedProvider.google()

        switch provider.credentials {
        case .conventional:
            // Success
            break
        case .client:
            Issue.record("Expected conventional credentials")
        }
    }

    @Test("Can pattern match client credentials")
    func clientPatternMatching() {
        let provider = FederatedProvider.google(
            credentials: .client(id: "test-id", secret: "test-secret")
        )

        switch provider.credentials {
        case .conventional:
            Issue.record("Expected client credentials")
        case .client(let id, let secret):
            #expect(id == "test-id")
            #expect(secret == "test-secret")
        }
    }

}
