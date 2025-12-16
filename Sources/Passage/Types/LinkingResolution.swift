public enum LinkingResolution: Sendable {
    case disabled
    case automatic(matchBy: [Identifier.Kind], onAmbiguity: AmbiguityResolution)
    case manual(matchBy: [Identifier.Kind])
}

// MARK: - Account Linking Ambiguity Resolution

public extension LinkingResolution {

    enum AmbiguityResolution: Sendable {
        case requestManualSelection
        case notifyAndCreateNew
        case ignoreAndCreateNew
    }
}
