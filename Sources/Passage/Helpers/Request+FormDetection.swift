import Vapor

extension Request {

    /// Detects if request is from HTML form submission
    var isFormSubmission: Bool {
        guard let contentType = headers.contentType else { return false }
        let contentTypeString = contentType.description
        return contentTypeString.contains("application/x-www-form-urlencoded")
            || contentTypeString.contains("multipart/form-data")
    }

    /// Detects if request is expecting HTML response
    var isWaitingForHTML: Bool {
        guard let accept = headers[.accept].first else {
            return false
        }
        return accept.contains("text/html")
    }
}
