import Vapor

public protocol LinkAccountSelectForm: Form {
    var selectedUserId: String { get }
}
