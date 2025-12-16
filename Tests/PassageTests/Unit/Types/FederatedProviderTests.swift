import Testing
import Vapor
@testable import Passage

@Suite("Federated Provider Tests")
struct FederatedProviderTests {

    // MARK: - Provider Name Tests

    @Test("Provider Name initialization with rawValue")
    func providerNameInitialization() {
        let name = FederatedProvider.Name("custom")
        #expect(name.description == "custom")
    }

    @Test("Provider Name google static member")
    func providerNameGoogle() {
        let google = FederatedProvider.Name.google
        #expect(google.description == "google")
    }

    @Test("Provider Name github static member")
    func providerNameGithub() {
        let github = FederatedProvider.Name.github
        #expect(github.description == "github")
    }

    @Test("Provider Name named factory method")
    func providerNameNamed() {
        let name = FederatedProvider.Name.named("custom-provider")
        #expect(name.description == "custom-provider")
    }

    @Test("Provider Name conforms to Codable")
    func providerNameCodable() throws {
        let name = FederatedProvider.Name("test")

        let encoder = JSONEncoder()
        let data = try encoder.encode(name)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(FederatedProvider.Name.self, from: data)

        #expect(decoded.description == name.description)
    }

    @Test("Provider Name conforms to Hashable")
    func providerNameHashable() {
        let name1 = FederatedProvider.Name("test")
        let name2 = FederatedProvider.Name("test")
        let name3 = FederatedProvider.Name("different")

        #expect(name1 == name2)
        #expect(name1 != name3)

        var set = Set<FederatedProvider.Name>()
        set.insert(name1)
        set.insert(name2)

        #expect(set.count == 1)
    }

    @Test("Provider Name conforms to Sendable")
    func providerNameSendable() {
        let _: any Sendable.Type = FederatedProvider.Name.self
        #expect(FederatedProvider.Name.self is Sendable.Type)
    }

    // MARK: - Provider Credentials Tests

    @Test("Provider Credentials conventional case")
    func credentialsConventional() {
        let credentials = FederatedProvider.Credentials.conventional

        if case .conventional = credentials {
            // Success
        } else {
            Issue.record("Expected conventional credentials")
        }
    }

    @Test("Provider Credentials client case")
    func credentialsClient() {
        let credentials = FederatedProvider.Credentials.client(
            id: "client-id",
            secret: "client-secret"
        )

        if case .client(let id, let secret) = credentials {
            #expect(id == "client-id")
            #expect(secret == "client-secret")
        } else {
            Issue.record("Expected client credentials")
        }
    }

    @Test("Provider Credentials conforms to Sendable")
    func credentialsSendable() {
        let _: any Sendable.Type = FederatedProvider.Credentials.self
        #expect(FederatedProvider.Credentials.self is Sendable.Type)
    }

    // MARK: - Provider Initialization Tests

    @Test("Provider initialization with all parameters")
    func providerInitialization() {
        let name = FederatedProvider.Name("google")
        let credentials = FederatedProvider.Credentials.client(id: "id", secret: "secret")
        let scope = ["email", "profile"]

        let provider = FederatedProvider(
            name: name,
            credentials: credentials,
            scope: scope,
        )

        #expect(provider.name.description == "google")
        #expect(provider.scope == ["email", "profile"])
    }

    @Test("Provider initialization with conventional credentials")
    func providerConventionalCredentials() {
        let name = FederatedProvider.Name.google
        let provider = FederatedProvider(name: name)

        if case .conventional = provider.credentials {
            // Success
        } else {
            Issue.record("Expected conventional credentials by default")
        }
    }

    @Test("Provider initialization with empty scope")
    func providerEmptyScope() {
        let name = FederatedProvider.Name.google
        let provider = FederatedProvider(name: name)

        #expect(provider.scope.isEmpty)
    }

    // MARK: - Provider Convenience Initializers Tests

    @Test("Provider google() convenience initializer")
    func googleConvenienceInitializer() {
        let provider = FederatedProvider.google()

        #expect(provider.name.description == "google")
        #expect(provider.scope.isEmpty)
    }

    @Test("Provider google() with credentials")
    func googleWithCredentials() {
        let credentials = FederatedProvider.Credentials.client(id: "google-id", secret: "google-secret")
        let provider = FederatedProvider.google(credentials: credentials)

        if case .client(let id, let secret) = provider.credentials {
            #expect(id == "google-id")
            #expect(secret == "google-secret")
        } else {
            Issue.record("Expected client credentials")
        }
    }

    @Test("Provider google() with scope")
    func googleWithScope() {
        let provider = FederatedProvider.google(scope: ["email", "profile"])

        #expect(provider.scope == ["email", "profile"])
    }

    @Test("Provider github() convenience initializer")
    func githubConvenienceInitializer() {
        let provider = FederatedProvider.github()

        #expect(provider.name.description == "github")
        #expect(provider.scope.isEmpty)
    }

    @Test("Provider github() with credentials")
    func githubWithCredentials() {
        let credentials = FederatedProvider.Credentials.client(id: "github-id", secret: "github-secret")
        let provider = FederatedProvider.github(credentials: credentials)

        if case .client(let id, let secret) = provider.credentials {
            #expect(id == "github-id")
            #expect(secret == "github-secret")
        } else {
            Issue.record("Expected client credentials")
        }
    }

    @Test("Provider github() with scope")
    func githubWithScope() {
        let provider = FederatedProvider.github(scope: ["user:email", "read:user"])

        #expect(provider.scope == ["user:email", "read:user"])
    }

    @Test("Provider custom() convenience initializer")
    func customConvenienceInitializer() {
        let provider = FederatedProvider.custom(name: "custom-oauth")

        #expect(provider.name.description == "custom-oauth")
    }

    @Test("Provider custom() with all parameters")
    func customWithAllParameters() {
        let credentials = FederatedProvider.Credentials.client(id: "custom-id", secret: "custom-secret")

        let provider = FederatedProvider.custom(
            name: "custom-provider",
            credentials: credentials,
            scope: ["openid", "profile"],
        )

        #expect(provider.name.description == "custom-provider")
        #expect(provider.scope == ["openid", "profile"])
    }

    // MARK: - Multiple Providers Tests

    @Test("Multiple providers can coexist")
    func multipleProviders() {
        let google = FederatedProvider.google(scope: ["email"])
        let github = FederatedProvider.github(scope: ["user"])

        #expect(google.name.description == "google")
        #expect(github.name.description == "github")
        #expect(google.scope != github.scope)
    }

    @Test("Provider instances are independent")
    func providerInstancesIndependent() {
        let provider1 = FederatedProvider.google(scope: ["email"])
        let provider2 = FederatedProvider.google(scope: ["profile"])

        #expect(provider1.scope != provider2.scope)
    }

    // MARK: - Path Component Conversion Tests

    @Test("Provider with multi-segment name")
    func providerMultiSegmentName() {
        let name = FederatedProvider.Name("oauth/provider")
        let provider = FederatedProvider(name: name)

        // The rawValue is stored as-is
        #expect(provider.name.description == "oauth/provider")
    }

    // MARK: - Provider Sendable Conformance Tests

    @Test("Provider conforms to Sendable")
    func providerSendable() {
        let _: any Sendable.Type = FederatedProvider.self
        #expect(FederatedProvider.self is Sendable.Type)
    }
}
