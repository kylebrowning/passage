import Vapor

public extension Passage {

    protocol FederatedLoginService: Sendable {

        func register(
            router: any RoutesBuilder,
            origin: URL,
            group: [PathComponent],
            config: Passage.Configuration.FederatedLogin,
            completion: @escaping @Sendable (
                _ provider: Passage.FederatedLogin.Provider,
                _ request: Request,
                _ payload: String
            ) async throws -> some AsyncResponseEncodable
        ) throws
    }

}
