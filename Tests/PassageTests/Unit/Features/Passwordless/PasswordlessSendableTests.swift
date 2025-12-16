import Testing
import Vapor
@testable import Passage

@Suite("Passwordless Sendable Conformance Tests")
struct PasswordlessSendableTests {

    /// Helper function that requires Sendable conformance.
    private func assertSendable<T: Sendable>(_ value: T) {}

    // MARK: - Route Collection Tests

    @Test("Passwordless.MagicLinkEmailRouteCollection conforms to Sendable")
    func magicLinkEmailRouteCollectionConformsToSendable() {
        let routes = Passage.Configuration.Passwordless.MagicLink.Routes.email
        assertSendable(Passage.Passwordless.MagicLinkEmailRouteCollection(routes: routes, group: []))
    }

    // MARK: - Job Payload Tests

    @Test("Passwordless.EmailMagicLinkPayload conforms to Sendable")
    func emailMagicLinkPayloadConformsToSendable() {
        assertSendable(Passage.Passwordless.EmailMagicLinkPayload(
            email: "test@example.com",
            userId: "user123",
            magicLinkURL: URL(string: "https://example.com/magic")!
        ))
    }

    @Test("Passwordless.SendEmailMagicLinkJob conforms to Sendable")
    func sendEmailMagicLinkJobConformsToSendable() {
        assertSendable(Passage.Passwordless.SendEmailMagicLinkJob())
    }
}
