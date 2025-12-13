import Testing
import Foundation
@testable import Passage

@Suite("ExchangeToken Protocol Tests", .tags(.unit))
struct ExchangeTokenProtocolTests {

    // MARK: - Mock Implementations

    struct MockUser: User {
        typealias Id = UUID
        var id: UUID?
        var email: String?
        var phone: String?
        var username: String?
        var passwordHash: String?
        var isAnonymous: Bool
        var isEmailVerified: Bool
        var isPhoneVerified: Bool

        var sessionID: String {
            guard let id = id else {
                fatalError("MockUser must have an ID for session authentication")
            }
            return id.uuidString
        }
    }

    struct MockExchangeToken: ExchangeToken {
        typealias Id = UUID
        typealias AssociatedUser = MockUser

        var id: UUID?
        var user: MockUser
        var tokenHash: String
        var expiresAt: Date
        var consumedAt: Date?
        var createdAt: Date?
    }

    // MARK: - Helper to create mock user

    private func createMockUser() -> MockUser {
        MockUser(
            id: UUID(),
            email: nil,
            phone: nil,
            username: nil,
            passwordHash: nil,
            isAnonymous: false,
            isEmailVerified: false,
            isPhoneVerified: false
        )
    }

    // MARK: - isExpired Tests

    @Test("ExchangeToken isExpired returns true when expired")
    func isExpiredWhenExpired() {
        let token = MockExchangeToken(
            id: UUID(),
            user: createMockUser(),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(-60), // expired 1 minute ago
            consumedAt: nil,
            createdAt: Date()
        )

        #expect(token.isExpired == true)
    }

    @Test("ExchangeToken isExpired returns false when not expired")
    func isExpiredWhenNotExpired() {
        let token = MockExchangeToken(
            id: UUID(),
            user: createMockUser(),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(60), // expires in 1 minute
            consumedAt: nil,
            createdAt: Date()
        )

        #expect(token.isExpired == false)
    }

    @Test("ExchangeToken isExpired returns true when exactly at expiration time")
    func isExpiredAtExactExpirationTime() {
        // Token that expired a tiny amount of time ago
        let token = MockExchangeToken(
            id: UUID(),
            user: createMockUser(),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(-0.001),
            consumedAt: nil,
            createdAt: Date()
        )

        #expect(token.isExpired == true)
    }

    // MARK: - isConsumed Tests

    @Test("ExchangeToken isConsumed returns true when consumed")
    func isConsumedWhenConsumed() {
        let token = MockExchangeToken(
            id: UUID(),
            user: createMockUser(),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(60),
            consumedAt: Date(), // has been consumed
            createdAt: Date()
        )

        #expect(token.isConsumed == true)
    }

    @Test("ExchangeToken isConsumed returns false when not consumed")
    func isConsumedWhenNotConsumed() {
        let token = MockExchangeToken(
            id: UUID(),
            user: createMockUser(),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(60),
            consumedAt: nil, // not consumed
            createdAt: Date()
        )

        #expect(token.isConsumed == false)
    }

    @Test("ExchangeToken isConsumed with past consumption time")
    func isConsumedWithPastConsumptionTime() {
        let token = MockExchangeToken(
            id: UUID(),
            user: createMockUser(),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(60),
            consumedAt: Date().addingTimeInterval(-3600), // consumed 1 hour ago
            createdAt: Date().addingTimeInterval(-7200)
        )

        #expect(token.isConsumed == true)
    }

    // MARK: - isValid Tests

    @Test("ExchangeToken isValid returns true when not expired and not consumed")
    func isValidWhenValid() {
        let token = MockExchangeToken(
            id: UUID(),
            user: createMockUser(),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(60), // not expired
            consumedAt: nil, // not consumed
            createdAt: Date()
        )

        #expect(token.isValid == true)
    }

    @Test("ExchangeToken isValid returns false when expired")
    func isValidWhenExpired() {
        let token = MockExchangeToken(
            id: UUID(),
            user: createMockUser(),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(-60), // expired
            consumedAt: nil, // not consumed
            createdAt: Date()
        )

        #expect(token.isValid == false)
    }

    @Test("ExchangeToken isValid returns false when consumed")
    func isValidWhenConsumed() {
        let token = MockExchangeToken(
            id: UUID(),
            user: createMockUser(),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(60), // not expired
            consumedAt: Date(), // consumed
            createdAt: Date()
        )

        #expect(token.isValid == false)
    }

    @Test("ExchangeToken isValid returns false when both expired and consumed")
    func isValidWhenExpiredAndConsumed() {
        let token = MockExchangeToken(
            id: UUID(),
            user: createMockUser(),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(-60), // expired
            consumedAt: Date(), // consumed
            createdAt: Date()
        )

        #expect(token.isValid == false)
    }

    // MARK: - Protocol Conformance Tests

    @Test("MockExchangeToken conforms to ExchangeToken protocol")
    func mockExchangeTokenConformsToProtocol() {
        let token: any ExchangeToken = MockExchangeToken(
            id: UUID(),
            user: createMockUser(),
            tokenHash: "hash",
            expiresAt: Date(),
            consumedAt: nil,
            createdAt: Date()
        )
        #expect(token is MockExchangeToken)
    }

    @Test("ExchangeToken protocol conforms to Sendable")
    func exchangeTokenProtocolIsSendable() {
        let token: any Sendable = MockExchangeToken(
            id: UUID(),
            user: createMockUser(),
            tokenHash: "hash",
            expiresAt: Date(),
            consumedAt: nil,
            createdAt: Date()
        )
        #expect(token is MockExchangeToken)
    }

    // MARK: - Properties Tests

    @Test("ExchangeToken stores tokenHash correctly")
    func tokenHashStorage() {
        let hash = "abc123hash456"
        let token = MockExchangeToken(
            id: UUID(),
            user: createMockUser(),
            tokenHash: hash,
            expiresAt: Date(),
            consumedAt: nil,
            createdAt: Date()
        )

        #expect(token.tokenHash == hash)
    }

    @Test("ExchangeToken stores user reference")
    func userReference() {
        let userId = UUID()
        let user = MockUser(
            id: userId,
            email: "test@example.com",
            phone: nil,
            username: nil,
            passwordHash: nil,
            isAnonymous: false,
            isEmailVerified: false,
            isPhoneVerified: false
        )
        let token = MockExchangeToken(
            id: UUID(),
            user: user,
            tokenHash: "hash",
            expiresAt: Date(),
            consumedAt: nil,
            createdAt: Date()
        )

        #expect(token.user.id == userId)
        #expect(token.user.email == "test@example.com")
    }

    @Test("ExchangeToken stores id correctly")
    func idStorage() {
        let tokenId = UUID()
        let token = MockExchangeToken(
            id: tokenId,
            user: createMockUser(),
            tokenHash: "hash",
            expiresAt: Date(),
            consumedAt: nil,
            createdAt: Date()
        )

        #expect(token.id == tokenId)
    }

    @Test("ExchangeToken with nil id")
    func nilId() {
        let token = MockExchangeToken(
            id: nil,
            user: createMockUser(),
            tokenHash: "hash",
            expiresAt: Date(),
            consumedAt: nil,
            createdAt: Date()
        )

        #expect(token.id == nil)
    }

    @Test("ExchangeToken stores createdAt correctly")
    func createdAtStorage() {
        let createdAt = Date().addingTimeInterval(-30)
        let token = MockExchangeToken(
            id: UUID(),
            user: createMockUser(),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(30),
            consumedAt: nil,
            createdAt: createdAt
        )

        #expect(token.createdAt == createdAt)
    }

    @Test("ExchangeToken with nil createdAt")
    func nilCreatedAt() {
        let token = MockExchangeToken(
            id: UUID(),
            user: createMockUser(),
            tokenHash: "hash",
            expiresAt: Date(),
            consumedAt: nil,
            createdAt: nil
        )

        #expect(token.createdAt == nil)
    }

    // MARK: - Short TTL Behavior Tests

    @Test("ExchangeToken with typical 60-second TTL")
    func typicalShortTTL() {
        let createdAt = Date()
        let token = MockExchangeToken(
            id: UUID(),
            user: createMockUser(),
            tokenHash: "hash",
            expiresAt: createdAt.addingTimeInterval(60), // 60 seconds
            consumedAt: nil,
            createdAt: createdAt
        )

        #expect(token.isValid == true)
        #expect(token.isExpired == false)
        #expect(token.isConsumed == false)
    }

    @Test("ExchangeToken expired after short TTL")
    func expiredAfterShortTTL() {
        let createdAt = Date().addingTimeInterval(-120) // created 2 minutes ago
        let token = MockExchangeToken(
            id: UUID(),
            user: createMockUser(),
            tokenHash: "hash",
            expiresAt: createdAt.addingTimeInterval(60), // expired 1 minute ago
            consumedAt: nil,
            createdAt: createdAt
        )

        #expect(token.isValid == false)
        #expect(token.isExpired == true)
    }

    // MARK: - Single-Use Behavior Tests

    @Test("ExchangeToken becomes invalid after consumption")
    func becomesInvalidAfterConsumption() {
        // Simulate consumption by creating a token with consumedAt set
        var token = MockExchangeToken(
            id: UUID(),
            user: createMockUser(),
            tokenHash: "hash",
            expiresAt: Date().addingTimeInterval(60),
            consumedAt: nil,
            createdAt: Date()
        )

        // Before consumption
        #expect(token.isValid == true)
        #expect(token.isConsumed == false)

        // Simulate consumption
        token.consumedAt = Date()

        // After consumption
        #expect(token.isValid == false)
        #expect(token.isConsumed == true)
    }
}
