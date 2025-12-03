import JWTKit

// TODO: For future usage
public struct IdToken: UserInfo, Sendable {

    // Standard claims
    let subject: SubjectClaim
    let expiration: ExpirationClaim
    let issuedAt: IssuedAtClaim
    let issuer: IssuerClaim?
    let audience: AudienceClaim?

    // Passage claims
    let email: String?
    let phone: String?
}

extension IdToken: JWTPayload {

    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case issuedAt = "iat"
        case issuer = "iss"
        case audience = "aud"
        case email
        case phone
    }

    public func verify(using algorithm: some JWTAlgorithm) async throws {
        try expiration.verifyNotExpired()
    }
}
