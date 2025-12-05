import Vapor

// MARK: - Request Extension

extension Request {

    func decodeContentAsFormOfType<F: Form>(_: F.Type) throws -> F {
        let formType = F.self
        try formType.validate(content: self)
        let form = try self.content.decode(formType)
        try form.validate()
        return form
    }

    func decodeQueryAsFormOfType<F: Form>(_: F.Type) throws -> F {
        let formType = F.self
        try formType.validate(query: self)
        let form = try self.query.decode(formType)
        try form.validate()
        return form
    }

}
