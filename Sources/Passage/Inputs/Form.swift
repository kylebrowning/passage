import Vapor

public protocol Form: Content, Validatable {

    func validate() throws
}

// MARK: - Form Extension

extension Form {

    func validate() throws {
        // noop by default
    }
}

// MARK: - Request Extension

extension Request {

    func decodeContentAsFormOfType<F: Form>(_: F.Type) throws -> F {
        let formType = F.self
        try formType.validate(content: self)
        let form = try self.content.decode(formType)
        try form.validate()
        return form
    }

}
