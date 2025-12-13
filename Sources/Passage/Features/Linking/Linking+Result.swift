extension Passage.Linking {

    enum Result: Sendable {
        case complete(user: any User)
        case conflict(candidates: [String])
        case initiated
        case skipped
    }

}
