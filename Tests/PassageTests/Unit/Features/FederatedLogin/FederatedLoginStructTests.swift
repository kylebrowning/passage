import Testing
import Vapor
@testable import Passage

@Suite("FederatedLogin Struct Tests")
struct FederatedLoginStructTests {

    // MARK: - FederatedLogin Struct Tests

    @Test("FederatedLogin struct is properly namespaced in Passage")
    func federatedLoginNamespace() {
        let typeName = String(reflecting: Passage.FederatedLogin.self)
        #expect(typeName.contains("Passage.FederatedLogin"))
    }

    @Test("FederatedLogin struct conforms to Sendable")
    func federatedLoginSendable() {
        let _: any Sendable.Type = Passage.FederatedLogin.self
        #expect(Passage.FederatedLogin.self is Sendable.Type)
    }

    @Test("FederatedLogin feature is properly namespaced")
    func federatedLoginFeatureNamespace() {
        // Verify the entire FederatedLogin namespace is in Passage
        let structName = String(reflecting: Passage.FederatedLogin.self)
        #expect(structName.contains("Passage.FederatedLogin"))
    }

    // MARK: - All Sendable Conformance Tests

    @Test("All FederatedLogin types conform to Sendable")
    func allTypesSendable() {
        #expect(Passage.FederatedLogin.self is Sendable.Type)
    }

}
