import Testing
import Vapor
@testable import Passage

@Suite("Exchange Code Configuration Tests", .tags(.unit))
struct ExchangeCodeConfigurationTests {

    // MARK: - Default Configuration Tests

    @Test("ExchangeCode default path is token/exchange")
    func defaultExchangeCodePath() {
        let exchangeCode = Passage.Configuration.Routes.ExchangeCode.default

        #expect(exchangeCode.path.count == 2)
        #expect(exchangeCode.path[0] == PathComponent.constant("token"))
        #expect(exchangeCode.path[1] == PathComponent.constant("exchange"))
    }

    @Test("ExchangeCode can be initialized with custom path")
    func customExchangeCodePath() {
        let exchangeCode = Passage.Configuration.Routes.ExchangeCode(path: "oauth", "exchange")

        #expect(exchangeCode.path.count == 2)
        #expect(exchangeCode.path[0] == PathComponent.constant("oauth"))
        #expect(exchangeCode.path[1] == PathComponent.constant("exchange"))
    }

    @Test("ExchangeCode can be initialized with single path component")
    func singlePathComponent() {
        let exchangeCode = Passage.Configuration.Routes.ExchangeCode(path: "exchange")

        #expect(exchangeCode.path.count == 1)
        #expect(exchangeCode.path[0] == PathComponent.constant("exchange"))
    }

    @Test("ExchangeCode can be initialized with deep path")
    func deepPath() {
        let exchangeCode = Passage.Configuration.Routes.ExchangeCode(path: "api", "v1", "auth", "exchange")

        #expect(exchangeCode.path.count == 4)
        #expect(exchangeCode.path[0] == PathComponent.constant("api"))
        #expect(exchangeCode.path[1] == PathComponent.constant("v1"))
        #expect(exchangeCode.path[2] == PathComponent.constant("auth"))
        #expect(exchangeCode.path[3] == PathComponent.constant("exchange"))
    }

    // MARK: - Routes Configuration Integration Tests

    @Test("Routes includes exchangeCode property")
    func routesIncludesExchangeCode() {
        let routes = Passage.Configuration.Routes()

        #expect(routes.exchangeCode.path.count == 2)
    }

    @Test("Routes uses default exchangeCode when not specified")
    func routesUsesDefaultExchangeCode() {
        let routes = Passage.Configuration.Routes()

        #expect(routes.exchangeCode.path == Passage.Configuration.Routes.ExchangeCode.default.path)
    }

    @Test("Routes accepts custom exchangeCode")
    func routesAcceptsCustomExchangeCode() {
        let customExchangeCode = Passage.Configuration.Routes.ExchangeCode(path: "custom", "path")
        let routes = Passage.Configuration.Routes(exchangeCode: customExchangeCode)

        #expect(routes.exchangeCode.path == customExchangeCode.path)
    }

    @Test("Routes preserves exchangeCode with other custom routes")
    func routesPreservesExchangeCodeWithOtherRoutes() {
        let customExchangeCode = Passage.Configuration.Routes.ExchangeCode(path: "code", "swap")
        let customLogin = Passage.Configuration.Routes.Login(path: "signin")

        let routes = Passage.Configuration.Routes(
            login: customLogin,
            exchangeCode: customExchangeCode
        )

        #expect(routes.exchangeCode.path == customExchangeCode.path)
        #expect(routes.login.path == customLogin.path)
    }

    @Test("Routes with group and custom exchangeCode")
    func routesWithGroupAndCustomExchangeCode() {
        let customExchangeCode = Passage.Configuration.Routes.ExchangeCode(path: "exchange")

        let routes = Passage.Configuration.Routes(
            group: "api", "v2",
            exchangeCode: customExchangeCode
        )

        #expect(routes.group.count == 2)
        #expect(routes.group[0] == PathComponent.constant("api"))
        #expect(routes.group[1] == PathComponent.constant("v2"))
        #expect(routes.exchangeCode.path == customExchangeCode.path)
    }

    // MARK: - Sendable Conformance

    @Test("ExchangeCode conforms to Sendable")
    func exchangeCodeConformsToSendable() {
        let exchangeCode: any Sendable = Passage.Configuration.Routes.ExchangeCode.default
        #expect(exchangeCode is Passage.Configuration.Routes.ExchangeCode)
    }
}
