import Testing
import Vapor
import JWT
@testable import Passage

@Suite("PassageAuthenticator Tests")
struct PassageAuthenticatorTests {

    // MARK: - Structure Tests

    @Test("PassageAuthenticator can be initialized")
    func canBeInitialized() {
        let authenticator = PassageAuthenticator()
        #expect(authenticator != nil)
    }

    @Test("PassageAuthenticator type name is correct")
    func typeNameIsCorrect() {
        let typeName = String(describing: PassageAuthenticator.self)
        #expect(typeName == "PassageAuthenticator")
    }

    // MARK: - Protocol Conformance Tests

    @Test("PassageAuthenticator conforms to JWTAuthenticator")
    func conformsToJWTAuthenticator() {
        let authenticator = PassageAuthenticator()
        #expect(authenticator is any JWTAuthenticator)
    }

    @Test("PassageAuthenticator Payload typealias is AccessToken")
    func payloadTypealiasIsAccessToken() {
        // Verify the Payload typealias by checking the type
        let payloadType = PassageAuthenticator.Payload.self
        #expect(payloadType == AccessToken.self)
    }
}
