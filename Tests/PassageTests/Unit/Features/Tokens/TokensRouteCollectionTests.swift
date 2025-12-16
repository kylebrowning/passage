import Testing
import Vapor
@testable import Passage

@Suite("Tokens Route Collection Tests", .tags(.unit))
struct TokensRouteCollectionTests {

    // MARK: - Initialization Tests

    @Test("Passage.Tokens.RouteCollection initialization with default routes")
    func routeCollectionInitialization() {
        let routes = Passage.Configuration.Routes()
        let collection = Passage.Tokens.RouteCollection(routes: routes)

        #expect(collection.routes.refreshToken.path.count == 1)
    }

    @Test("Passage.Tokens.RouteCollection initialization with custom routes")
    func routeCollectionWithCustomRoutes() {
        let routes = Passage.Configuration.Routes(
            refreshToken: .init(path: "token", "refresh")
        )
        let collection = Passage.Tokens.RouteCollection(routes: routes)

        #expect(collection.routes.refreshToken.path.count == 2)
        #expect(collection.routes.refreshToken.path[0] == PathComponent.constant("token"))
        #expect(collection.routes.refreshToken.path[1] == PathComponent.constant("refresh"))
    }

    @Test("Passage.Tokens.RouteCollection stores routes configuration")
    func routeCollectionStoresConfiguration() {
        let routes = Passage.Configuration.Routes(
            group: "api", "v1"
        )
        let collection = Passage.Tokens.RouteCollection(routes: routes)

        #expect(collection.routes.group.count == 2)
        #expect(collection.routes.group[0] == PathComponent.constant("api"))
        #expect(collection.routes.group[1] == PathComponent.constant("v1"))
    }

    // MARK: - Protocol Conformance Tests

    @Test("Passage.Tokens.RouteCollection conforms to RouteCollection")
    func routeCollectionConformsToProtocol() {
        let routes = Passage.Configuration.Routes()
        let collection = Passage.Tokens.RouteCollection(routes: routes)

        let _: any RouteCollection = collection
    }

    // MARK: - Route Path Configuration Tests

    @Test("Passage.Tokens.RouteCollection with no group")
    func routeCollectionWithNoGroup() {
        let routes = Passage.Configuration.Routes()
        let collection = Passage.Tokens.RouteCollection(routes: routes)

        #expect(collection.routes.group.count == 1)
        #expect(collection.routes.group[0] == PathComponent.constant("auth"))
    }

    @Test("Passage.Tokens.RouteCollection with auth group")
    func routeCollectionWithAuthGroup() {
        let routes = Passage.Configuration.Routes(group: "auth")
        let collection = Passage.Tokens.RouteCollection(routes: routes)

        #expect(collection.routes.group.count == 1)
        #expect(collection.routes.group[0] == PathComponent.constant("auth"))
    }

    @Test("Passage.Tokens.RouteCollection with nested group")
    func routeCollectionWithNestedGroup() {
        let routes = Passage.Configuration.Routes(group: "api", "auth")
        let collection = Passage.Tokens.RouteCollection(routes: routes)

        #expect(collection.routes.group.count == 2)
        #expect(collection.routes.group[0] == PathComponent.constant("api"))
        #expect(collection.routes.group[1] == PathComponent.constant("auth"))
    }

    @Test("Passage.Tokens.RouteCollection default route paths")
    func routeCollectionDefaultPaths() {
        let routes = Passage.Configuration.Routes()
        let collection = Passage.Tokens.RouteCollection(routes: routes)

        // Verify default paths match configuration defaults
        #expect(collection.routes.refreshToken.path == [PathComponent.constant("refresh-token")])
    }

    @Test("Passage.Tokens.RouteCollection with custom path components")
    func routeCollectionWithCustomPaths() {
        let routes = Passage.Configuration.Routes(
            refreshToken: .init(path: "auth", "refresh")
        )
        let collection = Passage.Tokens.RouteCollection(routes: routes)

        #expect(collection.routes.refreshToken.path.count == 2)
    }

    @Test("Passage.Tokens.RouteCollection preserves route configuration")
    func routeCollectionPreservesConfiguration() {
        let customRefreshToken = Passage.Configuration.Routes.RefreshToken(path: "custom", "refresh")

        let routes = Passage.Configuration.Routes(
            refreshToken: customRefreshToken
        )
        let collection = Passage.Tokens.RouteCollection(routes: routes)

        // Verify the collection preserves the exact route configuration
        #expect(collection.routes.refreshToken.path == customRefreshToken.path)
    }

    // MARK: - Multiple Instance Tests

    @Test("Passage.Tokens.RouteCollection can be instantiated multiple times")
    func multipleRouteCollectionInstances() {
        let routes1 = Passage.Configuration.Routes(group: "api")
        let routes2 = Passage.Configuration.Routes(group: "admin")

        let collection1 = Passage.Tokens.RouteCollection(routes: routes1)
        let collection2 = Passage.Tokens.RouteCollection(routes: routes2)

        #expect(collection1.routes.group[0] == PathComponent.constant("api"))
        #expect(collection2.routes.group[0] == PathComponent.constant("admin"))
    }

    @Test("Passage.Tokens.RouteCollection instances are independent")
    func routeCollectionIndependence() {
        let routes1 = Passage.Configuration.Routes(
            refreshToken: .init(path: "refresh1")
        )
        let routes2 = Passage.Configuration.Routes(
            refreshToken: .init(path: "refresh2")
        )

        let collection1 = Passage.Tokens.RouteCollection(routes: routes1)
        let collection2 = Passage.Tokens.RouteCollection(routes: routes2)

        #expect(collection1.routes.refreshToken.path[0] == PathComponent.constant("refresh1"))
        #expect(collection2.routes.refreshToken.path[0] == PathComponent.constant("refresh2"))
    }

    // MARK: - Exchange Code Route Tests

    @Test("Passage.Tokens.RouteCollection default exchange code path")
    func routeCollectionDefaultExchangeCodePath() {
        let routes = Passage.Configuration.Routes()
        let collection = Passage.Tokens.RouteCollection(routes: routes)

        #expect(collection.routes.exchangeCode.path.count == 2)
        #expect(collection.routes.exchangeCode.path[0] == PathComponent.constant("token"))
        #expect(collection.routes.exchangeCode.path[1] == PathComponent.constant("exchange"))
    }

    @Test("Passage.Tokens.RouteCollection with custom exchange code path")
    func routeCollectionWithCustomExchangeCodePath() {
        let routes = Passage.Configuration.Routes(
            exchangeCode: .init(path: "oauth", "callback", "exchange")
        )
        let collection = Passage.Tokens.RouteCollection(routes: routes)

        #expect(collection.routes.exchangeCode.path.count == 3)
        #expect(collection.routes.exchangeCode.path[0] == PathComponent.constant("oauth"))
        #expect(collection.routes.exchangeCode.path[1] == PathComponent.constant("callback"))
        #expect(collection.routes.exchangeCode.path[2] == PathComponent.constant("exchange"))
    }

    @Test("Passage.Tokens.RouteCollection preserves exchange code with other routes")
    func routeCollectionPreservesExchangeCodeWithOtherRoutes() {
        let customRefreshToken = Passage.Configuration.Routes.RefreshToken(path: "custom", "refresh")
        let customExchangeCode = Passage.Configuration.Routes.ExchangeCode(path: "custom", "exchange")

        let routes = Passage.Configuration.Routes(
            refreshToken: customRefreshToken,
            exchangeCode: customExchangeCode
        )
        let collection = Passage.Tokens.RouteCollection(routes: routes)

        #expect(collection.routes.refreshToken.path == customRefreshToken.path)
        #expect(collection.routes.exchangeCode.path == customExchangeCode.path)
    }

    @Test("Passage.Tokens.RouteCollection exchange code with group")
    func routeCollectionExchangeCodeWithGroup() {
        let routes = Passage.Configuration.Routes(
            group: "api", "auth"
        )
        let collection = Passage.Tokens.RouteCollection(routes: routes)

        #expect(collection.routes.group.count == 2)
        #expect(collection.routes.exchangeCode.path.count == 2)
    }

    // MARK: - Sendable Conformance Tests

    /// Helper function that requires Sendable conformance.
    private func assertSendable<T: Sendable>(_ value: T) {}

    @Test("Tokens.RouteCollection conforms to Sendable")
    func conformsToSendable() {
        let routes = Passage.Configuration.Routes()
        assertSendable(Passage.Tokens.RouteCollection(routes: routes))
    }
}
