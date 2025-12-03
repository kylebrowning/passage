// MARK: - Theme

extension Passage.Views {

    public struct Theme: Sendable {

        public enum Brightness: Sendable {
            case light
            case dark
        }

        public struct Override : Sendable{
            let colors: Colors?
        }

        public struct Colors: Sendable, Encodable {
            let primary: String
            let onPrimary: String
            let secondary: String
            let onSecondary: String
            let surface: String
            let onSurface: String
            let onSurfaceVariant: String
            let background: String
            let onBackground: String
            let error: String
            let onError: String
            let warning: String
            let onWarning: String
            let success: String
            let onSuccess: String
            let outline: String
        }

        let colors: Colors

        let orverrides: [Brightness: Override]

        public init(
            colors: Colors,
            overrides: [Brightness: Override] = [:]
        ) {
            self.colors = colors
            self.orverrides = overrides
        }

    }
}

// MARK: Theme Colors Extension

extension Passage.Views.Theme {

    func colors(for brightness: Brightness) -> Colors {
        return orverrides[brightness]?.colors ?? self.colors
    }

    func resolve(for brightness: Brightness) -> Resolved {
        return Resolved(colors: colors(for: brightness))
    }
}

// MARK: - Resolved Theme

extension Passage.Views.Theme {

    struct Resolved: Sendable, Encodable {
        let colors: Colors
    }
}

// MARK: - Default Theme Colors

public extension Passage.Views.Theme.Colors {

    static let defaultLight = Self.init(
        primary: "#6200EE",
        onPrimary: "#FFFFFF",
        secondary: "#03DAC6",
        onSecondary: "#000000",
        surface: "#FFFFFF",
        onSurface: "#000000",
        onSurfaceVariant: "#616161",
        background: "#F5F5F5",
        onBackground: "#000000",
        error: "#B00020",
        onError: "#FFFFFF",
        warning: "#FF9800",
        onWarning: "#000000",
        success: "#4CAF50",
        onSuccess: "#FFFFFF",
        outline: "#BDBDBD"
    )

    static let defaultDark = Self.init(
        primary: "#BB86FC",
        onPrimary: "#000000",
        secondary: "#03DAC6",
        onSecondary: "#000000",
        surface: "#121212",
        onSurface: "#FFFFFF",
        onSurfaceVariant: "#E0E0E0",
        background: "#121212",
        onBackground: "#FFFFFF",
        error: "#CF6679",
        onError: "#000000",
        warning: "#FFB74D",
        onWarning: "#000000",
        success: "#81C784",
        onSuccess: "#000000",
        outline: "#424242"
    )

}
