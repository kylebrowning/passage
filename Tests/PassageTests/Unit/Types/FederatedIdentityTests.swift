import Testing
import Foundation
@testable import Passage

@Suite("FederatedIdentity Tests", .tags(.unit))
struct FederatedIdentityTests {

    // MARK: - Initialization Tests

    @Test("FederatedIdentity can be initialized with all properties")
    func initializationWithAllProperties() {
        let identity = FederatedIdentity(
            identifier: .federated("google", userId: "123456"),
            provider: "google",
            verifiedEmails: ["user@gmail.com"],
            verifiedPhoneNumbers: ["+1234567890"],
            displayName: "John Doe",
            profilePictureURL: "https://example.com/photo.jpg"
        )

        #expect(identity.provider == "google")
        #expect(identity.verifiedEmails == ["user@gmail.com"])
        #expect(identity.verifiedPhoneNumbers == ["+1234567890"])
        #expect(identity.displayName == "John Doe")
        #expect(identity.profilePictureURL == "https://example.com/photo.jpg")
    }

    @Test("FederatedIdentity can be initialized with minimal properties")
    func initializationWithMinimalProperties() {
        let identity = FederatedIdentity(
            identifier: .federated("github", userId: "abc123"),
            provider: "github",
            verifiedEmails: [],
            verifiedPhoneNumbers: [],
            displayName: nil,
            profilePictureURL: nil
        )

        #expect(identity.provider == "github")
        #expect(identity.verifiedEmails.isEmpty)
        #expect(identity.verifiedPhoneNumbers.isEmpty)
        #expect(identity.displayName == nil)
        #expect(identity.profilePictureURL == nil)
    }

    @Test("FederatedIdentity can have multiple verified emails")
    func multipleVerifiedEmails() {
        let emails = ["primary@example.com", "secondary@example.com", "work@company.com"]
        let identity = FederatedIdentity(
            identifier: .federated("google", userId: "user123"),
            provider: "google",
            verifiedEmails: emails,
            verifiedPhoneNumbers: [],
            displayName: nil,
            profilePictureURL: nil
        )

        #expect(identity.verifiedEmails.count == 3)
        #expect(identity.verifiedEmails == emails)
    }

    @Test("FederatedIdentity can have multiple verified phone numbers")
    func multipleVerifiedPhones() {
        let phones = ["+1234567890", "+0987654321"]
        let identity = FederatedIdentity(
            identifier: .federated("auth0", userId: "user456"),
            provider: "auth0",
            verifiedEmails: [],
            verifiedPhoneNumbers: phones,
            displayName: nil,
            profilePictureURL: nil
        )

        #expect(identity.verifiedPhoneNumbers.count == 2)
        #expect(identity.verifiedPhoneNumbers == phones)
    }

    // MARK: - Identifier Tests

    @Test("FederatedIdentity stores federated identifier correctly")
    func federatedIdentifierStorage() {
        let identifier = Identifier.federated("google", userId: "unique-subject-id")
        let identity = FederatedIdentity(
            identifier: identifier,
            provider: "google",
            verifiedEmails: [],
            verifiedPhoneNumbers: [],
            displayName: nil,
            profilePictureURL: nil
        )

        #expect(identity.identifier.kind == .federated)
        #expect(identity.identifier.value == "unique-subject-id")
        #expect(identity.identifier.provider == "google")
    }

    // MARK: - UserInfo Conformance Tests

    @Test("FederatedIdentity email returns first verified email")
    func emailReturnsFirstVerifiedEmail() {
        let identity = FederatedIdentity(
            identifier: .federated("google", userId: "123"),
            provider: "google",
            verifiedEmails: ["first@example.com", "second@example.com"],
            verifiedPhoneNumbers: [],
            displayName: nil,
            profilePictureURL: nil
        )

        #expect(identity.email == "first@example.com")
    }

    @Test("FederatedIdentity email returns nil when no verified emails")
    func emailReturnsNilWhenEmpty() {
        let identity = FederatedIdentity(
            identifier: .federated("google", userId: "123"),
            provider: "google",
            verifiedEmails: [],
            verifiedPhoneNumbers: [],
            displayName: nil,
            profilePictureURL: nil
        )

        #expect(identity.email == nil)
    }

    @Test("FederatedIdentity phone returns first verified phone")
    func phoneReturnsFirstVerifiedPhone() {
        let identity = FederatedIdentity(
            identifier: .federated("google", userId: "123"),
            provider: "google",
            verifiedEmails: [],
            verifiedPhoneNumbers: ["+1111111111", "+2222222222"],
            displayName: nil,
            profilePictureURL: nil
        )

        #expect(identity.phone == "+1111111111")
    }

    @Test("FederatedIdentity phone returns nil when no verified phones")
    func phoneReturnsNilWhenEmpty() {
        let identity = FederatedIdentity(
            identifier: .federated("google", userId: "123"),
            provider: "google",
            verifiedEmails: [],
            verifiedPhoneNumbers: [],
            displayName: nil,
            profilePictureURL: nil
        )

        #expect(identity.phone == nil)
    }

    @Test("FederatedIdentity conforms to UserInfo protocol")
    func conformsToUserInfoProtocol() {
        let identity = FederatedIdentity(
            identifier: .federated("google", userId: "123"),
            provider: "google",
            verifiedEmails: ["test@example.com"],
            verifiedPhoneNumbers: ["+1234567890"],
            displayName: "Test User",
            profilePictureURL: nil
        )

        let userInfo: any UserInfo = identity
        #expect(userInfo.email == "test@example.com")
        #expect(userInfo.phone == "+1234567890")
    }

    @Test("FederatedIdentity userInfo accessor returns self")
    func userInfoAccessorReturnsSelf() {
        let identity = FederatedIdentity(
            identifier: .federated("google", userId: "123"),
            provider: "google",
            verifiedEmails: ["test@example.com"],
            verifiedPhoneNumbers: [],
            displayName: nil,
            profilePictureURL: nil
        )

        let userInfo = identity.userInfo
        #expect(userInfo.email == identity.email)
        #expect(userInfo.phone == identity.phone)
    }

    // MARK: - Sendable Conformance Tests

    @Test("FederatedIdentity conforms to Sendable")
    func conformsToSendable() {
        let identity: any Sendable = FederatedIdentity(
            identifier: .federated("google", userId: "123"),
            provider: "google",
            verifiedEmails: [],
            verifiedPhoneNumbers: [],
            displayName: nil,
            profilePictureURL: nil
        )

        #expect(identity is FederatedIdentity)
    }

    // MARK: - Provider Specific Tests

    @Test("FederatedIdentity works with Google provider")
    func googleProvider() {
        let identity = FederatedIdentity(
            identifier: .federated("google", userId: "google-user-id"),
            provider: "google",
            verifiedEmails: ["user@gmail.com"],
            verifiedPhoneNumbers: [],
            displayName: "Google User",
            profilePictureURL: "https://lh3.googleusercontent.com/photo.jpg"
        )

        #expect(identity.provider == "google")
        #expect(identity.identifier.value == "google-user-id")
    }

    @Test("FederatedIdentity works with GitHub provider")
    func githubProvider() {
        let identity = FederatedIdentity(
            identifier: .federated("github", userId: "12345678"),
            provider: "github",
            verifiedEmails: ["user@users.noreply.github.com"],
            verifiedPhoneNumbers: [],
            displayName: "github-user",
            profilePictureURL: "https://avatars.githubusercontent.com/u/12345678"
        )

        #expect(identity.provider == "github")
        #expect(identity.identifier.value == "12345678")
    }

    @Test("FederatedIdentity works with Apple provider")
    func appleProvider() {
        let identity = FederatedIdentity(
            identifier: .federated("apple", userId: "000123.abc456.789"),
            provider: "apple",
            verifiedEmails: ["user@privaterelay.appleid.com"],
            verifiedPhoneNumbers: [],
            displayName: nil, // Apple often doesn't provide name on subsequent logins
            profilePictureURL: nil
        )

        #expect(identity.provider == "apple")
        #expect(identity.identifier.value == "000123.abc456.789")
    }

    // MARK: - Edge Cases

    @Test("FederatedIdentity handles empty display name")
    func emptyDisplayName() {
        let identity = FederatedIdentity(
            identifier: .federated("google", userId: "123"),
            provider: "google",
            verifiedEmails: [],
            verifiedPhoneNumbers: [],
            displayName: nil,
            profilePictureURL: nil
        )

        #expect(identity.displayName == nil)
    }

    @Test("FederatedIdentity handles empty profile picture URL")
    func emptyProfilePictureURL() {
        let identity = FederatedIdentity(
            identifier: .federated("google", userId: "123"),
            provider: "google",
            verifiedEmails: [],
            verifiedPhoneNumbers: [],
            displayName: "User",
            profilePictureURL: nil
        )

        #expect(identity.profilePictureURL == nil)
    }

    @Test("FederatedIdentity preserves order of verified emails")
    func emailOrderPreserved() {
        let emails = ["z@example.com", "a@example.com", "m@example.com"]
        let identity = FederatedIdentity(
            identifier: .federated("google", userId: "123"),
            provider: "google",
            verifiedEmails: emails,
            verifiedPhoneNumbers: [],
            displayName: nil,
            profilePictureURL: nil
        )

        // First email should be z@example.com as that's the order we provided
        #expect(identity.email == "z@example.com")
        #expect(identity.verifiedEmails[0] == "z@example.com")
        #expect(identity.verifiedEmails[1] == "a@example.com")
        #expect(identity.verifiedEmails[2] == "m@example.com")
    }

    @Test("FederatedIdentity preserves order of verified phones")
    func phoneOrderPreserved() {
        let phones = ["+3333333333", "+1111111111", "+2222222222"]
        let identity = FederatedIdentity(
            identifier: .federated("google", userId: "123"),
            provider: "google",
            verifiedEmails: [],
            verifiedPhoneNumbers: phones,
            displayName: nil,
            profilePictureURL: nil
        )

        // First phone should be +3333333333 as that's the order we provided
        #expect(identity.phone == "+3333333333")
        #expect(identity.verifiedPhoneNumbers[0] == "+3333333333")
    }
}
