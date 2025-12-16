import Vapor

// MARK: - Automatic Linking

extension Passage.Linking {

    struct AutomaticLinking: Sendable {
        let linking: Passage.Linking
    }

}

extension Passage.Linking.AutomaticLinking {

    var store: any Passage.Store {
        linking.store
    }
}

// MARK: - Perform Automatic Linking

extension Passage.Linking.AutomaticLinking {

    func perform(
        for identity: FederatedIdentity,
        withAllowedIdentifiers kinds: [Identifier.Kind],
        onAmbiguousMatch resolution: LinkingResolution.AmbiguityResolution,
    ) async throws -> Passage.Linking.Result {
        var users: [any User] = []
        for kind in kinds {
            switch kind {
            case .email:
                for email in identity.verifiedEmails {
                    guard let user = try await store.users.find(byIdentifier: .email(email)) else {
                        continue
                    }
                    guard user.isEmailVerified else {
                        // Only link to verified emails
                        continue
                    }
                    users.append(user)
                }
                break
            case .phone:
                for phone in identity.verifiedPhoneNumbers {
                    guard let user = try await store.users.find(byIdentifier: .phone(phone)) else {
                        continue
                    }
                    guard user.isPhoneVerified else {
                        // Only link to verified phones
                        continue
                    }
                    users.append(user)
                }
                break
            case .username, .federated:
                break
            }
        }

        if users.count > 1 {
            switch resolution {
            case .requestManualSelection:
                return try await linking.manual.initiate(for: identity, withAllowedIdentifiers: kinds)
            case .notifyAndCreateNew:
                return try .conflict(candidates: users.map { try $0.requiredIdAsString })
            case .ignoreAndCreateNew:
                return .skipped
            }
        } else if let user = users.first {
            try await linking.link(federatedIdentifier: identity.identifier, to: user)
            return .complete(user: user)
        } else {
            return .skipped
        }
    }

}
