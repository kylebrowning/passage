import Testing
import Foundation
import Vapor
@testable import Passage

@Suite("Federated Login Configuration Tests")
struct FederatedLoginConfigurationTests {

    // MARK: - FederatedLogin Routes Tests

    @Test("FederatedLogin routes default group")
    func routesDefaultGroup() {
        let routes = Passage.Configuration.FederatedLogin.Routes()

        #expect(routes.group.count == 1)
        #expect(routes.group[0].description == "connect")
    }

    @Test("FederatedLogin routes custom group")
    func routesCustomGroup() {
        let routes = Passage.Configuration.FederatedLogin.Routes(group: "api", "auth", "social")

        #expect(routes.group.count == 3)
        #expect(routes.group[0].description == "api")
        #expect(routes.group[1].description == "auth")
        #expect(routes.group[2].description == "social")
    }

    // MARK: - FederatedLogin Configuration Tests

    @Test("FederatedLogin default configuration")
    func federatedLoginDefault() {
        let config = Passage.Configuration.FederatedLogin(routes: .init(), providers: [])

        #expect(config.routes.group[0].description == "connect")
        #expect(config.providers.isEmpty)
        #expect(config.redirectLocation == "/")
    }

    @Test("FederatedLogin with custom redirect")
    func federatedLoginCustomRedirect() {
        let config = Passage.Configuration.FederatedLogin(
            routes: .init(),
            providers: [],
            redirectLocation: "/dashboard"
        )

        #expect(config.redirectLocation == "/dashboard")
    }

    @Test("FederatedLogin with providers")
    func federatedLoginWithProviders() {
        let config = Passage.Configuration.FederatedLogin(
            routes: .init(),
            providers: [
                .init(provider: .google()),
                .init(provider: .github())
            ]
        )

        #expect(config.providers.count == 2)
        #expect(config.providers[0].provider.name == .google)
        #expect(config.providers[1].provider.name == .github)
    }

    // MARK: - Path Helper Tests

    @Test("Login path for provider")
    func loginPathForProvider() {
        let provider = Passage.Configuration.FederatedLogin.Provider(
            provider: .google(),
        )
        let config = Passage.Configuration.FederatedLogin(
            routes: .init(group: "api", "oauth"),
            providers: [
                provider
            ]
        )

        let path = config.loginPath(for: provider)

        #expect(path.count == 3)
        #expect(path[0].description == "api")
        #expect(path[1].description == "oauth")
        #expect(path[2].description == "google")
    }

    @Test("Callback path for provider")
    func callbackPathForProvider() {
        let provider = Passage.Configuration.FederatedLogin.Provider(
            provider: .github(),
        )
        let config = Passage.Configuration.FederatedLogin(
            routes: .init(group: "auth"),
            providers: [provider]
        )

        let path = config.callbackPath(for: provider)

        #expect(path.count == 3)
        #expect(path[0].description == "auth")
        #expect(path[1].description == "github")
        #expect(path[2].description == "callback")
    }

    @Test("Custom provider paths")
    func customProviderPaths() {
        let customRoutes = Passage.Configuration.FederatedLogin.Provider.Routes(
            login: .init(path: "custom", "login"),
            callback: .init(path: "custom", "cb")
        )

        let provider = Passage.Configuration.FederatedLogin.Provider(
            provider: .custom(name: "custom"),
            routes: customRoutes
        )

        let config = Passage.Configuration.FederatedLogin(
            routes: .init(),
            providers: [provider]
        )

        let loginPath = config.loginPath(for: provider)
        let callbackPath = config.callbackPath(for: provider)

        #expect(loginPath[1].description == "custom")
        #expect(loginPath[2].description == "login")
        #expect(callbackPath[1].description == "custom")
        #expect(callbackPath[2].description == "cb")
    }

    @Test("FederatedLogin Sendable conformance")
    func federatedLoginSendableConformance() {
        let federatedLogin: Passage.Configuration.FederatedLogin = .init(
            routes: .init(),
            providers: []
        )

        let _: any Sendable = federatedLogin
        let _: any Sendable = federatedLogin.routes
    }

    // MARK: - Provider Routes Tests

    @Test("Provider Routes Login initialization with variadic path")
    func routesLoginVariadic() {
        let login = Passage.Configuration.FederatedLogin.Provider.Routes.Login(path: "oauth", "google")
        #expect(login.path.count == 2)
    }

    @Test("Provider Routes Login initialization with array path")
    func routesLoginArray() {
        let path: [PathComponent] = ["oauth", "google"]
        let login = Passage.Configuration.FederatedLogin.Provider.Routes.Login(path: path)
        #expect(login.path.count == 2)
    }

    @Test("Provider Routes Callback initialization with variadic path")
    func routesCallbackVariadic() {
        let callback = Passage.Configuration.FederatedLogin.Provider.Routes.Callback(path: "oauth", "callback")
        #expect(callback.path.count == 2)
    }

    @Test("Provider Routes Callback initialization with array path")
    func routesCallbackArray() {
        let path: [PathComponent] = ["oauth", "callback"]
        let callback = Passage.Configuration.FederatedLogin.Provider.Routes.Callback(path: path)
        #expect(callback.path.count == 2)
    }

    @Test("Provider Routes default initialization")
    func routesDefaultInitialization() {
        let routes = Passage.Configuration.FederatedLogin.Provider.Routes()

        #expect(routes.login.path.isEmpty)
        #expect(routes.callback.path == ["callback"])
    }

    @Test("Provider Routes custom initialization")
    func routesCustomInitialization() {
        let login = Passage.Configuration.FederatedLogin.Provider.Routes.Login(path: "auth", "login")
        let callback = Passage.Configuration.FederatedLogin.Provider.Routes.Callback(path: "auth", "callback")
        let routes = Passage.Configuration.FederatedLogin.Provider.Routes(login: login, callback: callback)

        #expect(routes.login.path == ["auth", "login"])
        #expect(routes.callback.path == ["auth", "callback"])
    }

    @Test("Provider Routes conforms to Sendable")
    func routesSendable() {
        let _: any Sendable.Type = Passage.Configuration.FederatedLogin.Provider.Routes.self
        #expect(Passage.Configuration.FederatedLogin.Provider.Routes.self is Sendable.Type)
    }

    // MARK: - Provider Nested Type Tests

    @Test("Provider Routes is nested within Provider")
    func providerRoutesNesting() {
        let typeName = String(reflecting: Passage.Configuration.FederatedLogin.Provider.Routes.self)
        #expect(typeName.contains("Passage.Configuration.FederatedLogin.Provider.Routes"))
    }

    // MARK: - Routes Nested Types Tests

    @Test("Routes Login is nested within Routes")
    func routesLoginNesting() {
        let typeName = String(reflecting: Passage.Configuration.FederatedLogin.Provider.Routes.Login.self)
        #expect(typeName.contains("Passage.Configuration.FederatedLogin.Provider.Routes.Login"))
    }

    @Test("Routes Callback is nested within Routes")
    func routesCallbackNesting() {
        let typeName = String(reflecting: Passage.Configuration.FederatedLogin.Provider.Routes.Callback.self)
        #expect(typeName.contains("Passage.Configuration.FederatedLogin.Provider.Routes.Callback"))
    }

    // MARK: - All Sendable Conformance Tests

    @Test("All FederatedLogin types conform to Sendable")
    func allTypesSendable() {
        #expect(Passage.Configuration.FederatedLogin.Provider.Routes.self is Sendable.Type)
        #expect(Passage.Configuration.FederatedLogin.Provider.Routes.Login.self is Sendable.Type)
        #expect(Passage.Configuration.FederatedLogin.Provider.Routes.Callback.self is Sendable.Type)
    }

    // MARK: - Integration Tests


    @Test("Provider with different route configurations")
    func differentRouteConfigurations() {
        let defaultRoutes = Passage.Configuration.FederatedLogin.Provider(
            provider: .google()
        )

        let customLogin = Passage.Configuration.FederatedLogin.Provider.Routes.Login(path: "custom", "login")
        let customCallback = Passage.Configuration.FederatedLogin.Provider.Routes.Callback(path: "custom", "callback")
        let customRoutes = Passage.Configuration.FederatedLogin.Provider.Routes(login: customLogin, callback: customCallback)

        let withCustomRoutes = Passage.Configuration.FederatedLogin.Provider(
            provider: .google(),
            routes: customRoutes
        )


        #expect(defaultRoutes.routes.login.path == ["google"])
        #expect(withCustomRoutes.routes.login.path == ["custom", "login"])
    }

    // MARK: - Routes Path Component Tests

    @Test("Routes Login stores path components")
    func routesLoginPathComponents() {
        let login = Passage.Configuration.FederatedLogin.Provider.Routes.Login(path: "a", "b", "c")
        #expect(login.path.count == 3)
    }

    @Test("Routes Callback stores path components")
    func routesCallbackPathComponents() {
        let callback = Passage.Configuration.FederatedLogin.Provider.Routes.Callback(path: "x", "y", "z")
        #expect(callback.path.count == 3)
    }

    @Test("Routes with empty path components")
    func routesEmptyPath() {
        let login = Passage.Configuration.FederatedLogin.Provider.Routes.Login(path: [])
        let callback = Passage.Configuration.FederatedLogin.Provider.Routes.Callback(path: [])

        #expect(login.path.isEmpty)
        #expect(callback.path.isEmpty)
    }

    @Test("Provider google() with custom routes")
    func googleWithCustomRoutes() {
        let login = Passage.Configuration.FederatedLogin.Provider.Routes.Login(path: "auth", "google")
        let callback = Passage.Configuration.FederatedLogin.Provider.Routes.Callback(path: "auth", "google", "callback")
        let routes = Passage.Configuration.FederatedLogin.Provider.Routes(login: login, callback: callback)

        let provider = Passage.Configuration.FederatedLogin.Provider(
            provider: .google(),
            routes: routes
        )

        #expect(provider.routes.login.path == ["auth", "google"])
        #expect(provider.routes.callback.path == ["auth", "google", "callback"])
    }

}
