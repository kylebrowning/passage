import Vapor

extension Request {

    func buildAuthRedirectLocation(
        for path: [PathComponent],
        params: [String: String?] = [:],
        success: String? = nil,
        error: String? = nil
    ) -> String {
        var components = URLComponents()
        components.path = "/\(path.string)"
        components.queryItems = params.map { key, value in
            URLQueryItem(name: key, value: value)
        }
        if let success {
            components.queryItems?.append(URLQueryItem(name: "success", value: success))
        }
        if let error {
            components.queryItems?.append(URLQueryItem(name: "error", value: error))
        }
        return components.string ?? "/\(path.string)"
    }

}
