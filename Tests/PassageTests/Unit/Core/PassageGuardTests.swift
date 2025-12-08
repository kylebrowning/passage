import Testing
import Vapor
@testable import Passage

@Suite("PassageGuard Tests")
struct PassageGuardTests {

    // MARK: - Structure Tests

    @Test("PassageGuard can be initialized with default error")
    func canBeInitializedWithDefaultError() {
        let guard_ = PassageGuard()
        #expect(guard_ != nil)
    }

    @Test("PassageGuard can be initialized with custom error")
    func canBeInitializedWithCustomError() {
        let customError = Abort(.forbidden, reason: "Custom forbidden error")
        let guard_ = PassageGuard(throwing: customError)
        #expect(guard_ != nil)
    }

    @Test("PassageGuard type name is correct")
    func typeNameIsCorrect() {
        let typeName = String(describing: PassageGuard.self)
        #expect(typeName == "PassageGuard")
    }

    // MARK: - Protocol Conformance Tests

    @Test("PassageGuard conforms to AsyncMiddleware")
    func conformsToAsyncMiddleware() {
        let guard_ = PassageGuard()
        #expect(guard_ is any AsyncMiddleware)
    }
}
