import Vapor
import JWT

public struct PassageAuthenticator: JWTAuthenticator {
    public typealias Payload = AccessToken

    public init() {}

    public func authenticate(
        jwt: AccessToken,
        for request: Vapor.Request,
    ) async throws {
        let user = try await request.identity.user(for: jwt)
        request.auth.login(user)
    }

}
