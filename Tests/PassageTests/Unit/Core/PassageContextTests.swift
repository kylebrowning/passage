import Testing
import Vapor
@testable import Passage

@Suite("PassageContext Tests")
struct PassageContextTests {

    // MARK: - Structure Tests

    @Test("PassageContext type name is correct")
    func typeNameIsCorrect() {
        let typeName = String(describing: PassageContext.self)
        #expect(typeName == "PassageContext")
    }

    // MARK: - Protocol Conformance Tests

    @Test("PassageContext conforms to Sendable")
    func conformsToSendable() {
        // This test verifies at compile time that PassageContext is Sendable
        // If PassageContext didn't conform to Sendable, this would fail to compile
        func acceptsSendable<T: Sendable>(_ type: T.Type) {}
        acceptsSendable(PassageContext.self)
    }
}
