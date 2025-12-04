import Vapor

public protocol RefreshTokenForm: Form {
    var refreshToken: String { get }

    func validate() throws
}
