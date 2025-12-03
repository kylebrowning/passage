import Vapor

public protocol RefreshTokenForm: Content, Validatable {
    var refreshToken: String { get }

    func validate() throws
}
