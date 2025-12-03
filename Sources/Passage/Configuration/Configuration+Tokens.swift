import Foundation

// MARK: - Tokens

extension Passage.Configuration {

    public struct Tokens: Sendable {

        public struct IdToken: Sendable {
            let timeToLive: TimeInterval
            public init(timeToLive: TimeInterval) {
                self.timeToLive = timeToLive
            }
        }

        public struct AccessToken: Sendable {
            let timeToLive: TimeInterval
            public init(timeToLive: TimeInterval) {
                self.timeToLive = timeToLive
            }
        }

        public struct RefreshToken: Sendable {
            let timeToLive: TimeInterval
            public init(timeToLive: TimeInterval) {
                self.timeToLive = timeToLive
            }
        }

        let issuer: String?

        let idToken: IdToken
        let accessToken: AccessToken
        let refreshToken: RefreshToken

        public init(
            issuer: String? = nil,
            idToken: IdToken = .init(timeToLive: 1 * 3600),
            accessToken: AccessToken = .init(timeToLive: 15 * 60),
            refreshToken: RefreshToken = .init(timeToLive: 7 * 24 * 3600),
        ) {
            self.issuer = issuer
            self.idToken = idToken
            self.accessToken = accessToken
            self.refreshToken = refreshToken
        }
    }

}
