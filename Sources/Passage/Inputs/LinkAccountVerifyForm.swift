import Vapor

public protocol LinkAccountVerifyForm: Form {
    var password: String? { get }
    var verificationCode: String? { get }
}
