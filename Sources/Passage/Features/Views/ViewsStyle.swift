
// MARK: - Style

extension Passage.Views {

    public enum Style: Sendable {
        case neobrutalism
        case neomorphism
        case minimalism
        case material
    }

}

extension Passage.Views.Style {

    var templateSuffix: String {
        switch self {
        case .neobrutalism:
            return "neobrutalism"
        case .neomorphism:
            return "neomorphism"
        case .minimalism:
            return "minimalism"
        case .material:
            return "material"
        }
    }
}
