import Vapor

public protocol ExchangeCodeForm: Form {
    var code: String { get }

    func validate() throws
}
