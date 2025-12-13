public struct FederatedIdentity: Sendable {
    public let identifier: Identifier
    public let provider: String
    public let verifiedEmails: [String]
    public let verifiedPhoneNumbers: [String]

    public let displayName: String?
    public let profilePictureURL: String?

    public init(
        identifier: Identifier,
        provider: String,
        verifiedEmails: [String],
        verifiedPhoneNumbers: [String],
        displayName: String?,
        profilePictureURL: String?
    ) {
        self.identifier = identifier
        self.provider = provider
        self.verifiedEmails = verifiedEmails
        self.verifiedPhoneNumbers = verifiedPhoneNumbers
        self.displayName = displayName
        self.profilePictureURL = profilePictureURL
    }
}

// MARK: - UserInfo Conformance

extension FederatedIdentity: UserInfo {

    public var email: String? {
        verifiedEmails.first
    }

    public var phone: String? {
        verifiedPhoneNumbers.first
    }

}

// MARK: - UserInfo Accessor

extension FederatedIdentity {

    public var userInfo: any UserInfo {
        self
    }

}
