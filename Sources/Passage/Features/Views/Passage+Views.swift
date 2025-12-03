import Vapor
import Leaf
import LeafKit

// MARK: - Views Namespace

public extension Passage {

    struct Views {
        let request: Request
        let config: Configuration.Views
    }

}

extension Passage.Views {

    static func registerLeafTempleates(
        on app: Application
    ) throws {
        guard let resourcePath = Bundle.module.resourcePath else {
            throw PassageError.unexpected(message: "Could not locate resource path for Passage module.")
        }
        let sources = try app.leaf.sources
        try sources.register(
            source: "passage",
            using: NIOLeafFiles(
                fileio: app.fileio,
                limits: .default,
                sandboxDirectory: "\(resourcePath)/Views",
                viewDirectory: "\(resourcePath)/Views"
            )
        )
        try app.leaf.sources = sources
    }

}

extension Request {

    var views: Passage.Views {
        .init(request: self, config: configuration.views)
    }

}

// MARK: - Views Implementation

extension Passage.Views {

    func renderResetPasswordRequestView() async throws -> View {
        guard let view = config.passwordResetRequest else {
            throw Abort(.notFound)
        }
        let params = try request.query.decode(ResetPasswordRequestViewContext.self)
        return try await request.view.render(
            view.template,
            Context(
                theme: view.theme.resolve(for: .light),
                params: params,
            ),
        )
    }

    func handleResetPasswordRequestForm() async throws {
        try PasswordResetRequestForm.validate(request)
        let form = try request.content.decode(PasswordResetRequestForm.self)
        try form.validate()

        let identifier = try form.asIdentifier()

        try await request.restoration.requestReset(for: identifier)
    }

}
