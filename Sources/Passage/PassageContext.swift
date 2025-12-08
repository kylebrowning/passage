import Vapor

public struct PassageContext: Sendable {
    let request: Request

    public var user: any User {
        get throws {
            try request.auth.require(request.store.users.userType)
        }
    }

    public var hasUser: Bool {
        request.auth.has(request.store.users.userType)
    }
}
