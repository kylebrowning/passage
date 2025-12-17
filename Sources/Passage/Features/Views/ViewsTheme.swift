// MARK: - Theme

extension Passage.Views {

    public struct Theme: Sendable {

        public enum Brightness: Sendable {
            case light
            case dark
        }

        public struct Override : Sendable{
            let colors: Colors?

            public init(colors: Colors?) {
                self.colors = colors
            }
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

            public init(
                primary: String,
                onPrimary: String,
                secondary: String,
                onSecondary: String,
                surface: String,
                onSurface: String,
                onSurfaceVariant: String,
                background: String,
                onBackground: String,
                error: String,
                onError: String,
                warning: String,
                onWarning: String,
                success: String,
                onSuccess: String,
                outline: String
            ) {
                self.primary = primary
                self.onPrimary = onPrimary
                self.secondary = secondary
                self.onSecondary = onSecondary
                self.surface = surface
                self.onSurface = onSurface
                self.onSurfaceVariant = onSurfaceVariant
                self.background = background
                self.onBackground = onBackground
                self.error = error
                self.onError = onError
                self.warning = warning
                self.onWarning = onWarning
                self.success = success
                self.onSuccess = onSuccess
                self.outline = outline
            }
        }

        let colors: Colors

        let overrides: [Brightness: Override]

        public init(
            colors: Colors,
            overrides: [Brightness: Override] = [:]
        ) {
            self.colors = colors
            self.overrides = overrides
        }

    }
}

// MARK: Theme Colors Extension

extension Passage.Views.Theme {

    func colors(for brightness: Brightness) -> Colors {
        return overrides[brightness]?.colors ?? self.colors
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

    // MARK: - Ocean Themes

    static let oceanLight = Self.init(
        primary: "#0077BE",
        onPrimary: "#FFFFFF",
        secondary: "#00BCD4",
        onSecondary: "#000000",
        surface: "#FFFFFF",
        onSurface: "#1A1A1A",
        onSurfaceVariant: "#5F6368",
        background: "#F0F8FF",
        onBackground: "#1A1A1A",
        error: "#D32F2F",
        onError: "#FFFFFF",
        warning: "#FFA000",
        onWarning: "#000000",
        success: "#388E3C",
        onSuccess: "#FFFFFF",
        outline: "#B0BEC5"
    )

    static let oceanDark = Self.init(
        primary: "#4FC3F7",
        onPrimary: "#003D5C",
        secondary: "#26C6DA",
        onSecondary: "#003D40",
        surface: "#1E2A32",
        onSurface: "#E1F5FE",
        onSurfaceVariant: "#B0BEC5",
        background: "#0A1A24",
        onBackground: "#E1F5FE",
        error: "#EF5350",
        onError: "#3E0000",
        warning: "#FFB74D",
        onWarning: "#3E2700",
        success: "#66BB6A",
        onSuccess: "#003D00",
        outline: "#546E7A"
    )

    // MARK: - Forest Themes

    static let forestLight = Self.init(
        primary: "#2E7D32",
        onPrimary: "#FFFFFF",
        secondary: "#8D6E63",
        onSecondary: "#FFFFFF",
        surface: "#FFFFFF",
        onSurface: "#1B1B1B",
        onSurfaceVariant: "#616161",
        background: "#F1F8E9",
        onBackground: "#1B1B1B",
        error: "#C62828",
        onError: "#FFFFFF",
        warning: "#F57C00",
        onWarning: "#000000",
        success: "#43A047",
        onSuccess: "#FFFFFF",
        outline: "#A5D6A7"
    )

    static let forestDark = Self.init(
        primary: "#81C784",
        onPrimary: "#003D00",
        secondary: "#BCAAA4",
        onSecondary: "#3E2723",
        surface: "#1A2618",
        onSurface: "#E8F5E9",
        onSurfaceVariant: "#C5E1A5",
        background: "#0D1A0C",
        onBackground: "#E8F5E9",
        error: "#EF5350",
        onError: "#3E0000",
        warning: "#FFB74D",
        onWarning: "#3E2700",
        success: "#66BB6A",
        onSuccess: "#003D00",
        outline: "#558B2F"
    )

    // MARK: - Sunset Themes

    static let sunsetLight = Self.init(
        primary: "#FF6F00",
        onPrimary: "#FFFFFF",
        secondary: "#EC407A",
        onSecondary: "#FFFFFF",
        surface: "#FFFFFF",
        onSurface: "#1C1C1C",
        onSurfaceVariant: "#757575",
        background: "#FFF3E0",
        onBackground: "#1C1C1C",
        error: "#D32F2F",
        onError: "#FFFFFF",
        warning: "#F9A825",
        onWarning: "#000000",
        success: "#43A047",
        onSuccess: "#FFFFFF",
        outline: "#FFAB91"
    )

    static let sunsetDark = Self.init(
        primary: "#FFB74D",
        onPrimary: "#3E2700",
        secondary: "#F48FB1",
        onSecondary: "#3E0016",
        surface: "#2B1A0F",
        onSurface: "#FFF3E0",
        onSurfaceVariant: "#FFCC80",
        background: "#1A0F08",
        onBackground: "#FFF3E0",
        error: "#EF5350",
        onError: "#3E0000",
        warning: "#FFD54F",
        onWarning: "#3E2F00",
        success: "#66BB6A",
        onSuccess: "#003D00",
        outline: "#BF360C"
    )

    // MARK: - Midnight Themes

    static let midnightLight = Self.init(
        primary: "#1A237E",
        onPrimary: "#FFFFFF",
        secondary: "#5E35B1",
        onSecondary: "#FFFFFF",
        surface: "#FFFFFF",
        onSurface: "#1A1A1A",
        onSurfaceVariant: "#616161",
        background: "#E8EAF6",
        onBackground: "#1A1A1A",
        error: "#C62828",
        onError: "#FFFFFF",
        warning: "#F57C00",
        onWarning: "#000000",
        success: "#388E3C",
        onSuccess: "#FFFFFF",
        outline: "#9FA8DA"
    )

    static let midnightDark = Self.init(
        primary: "#7986CB",
        onPrimary: "#0A0E3E",
        secondary: "#9575CD",
        onSecondary: "#2E1A3E",
        surface: "#151A2E",
        onSurface: "#E8EAF6",
        onSurfaceVariant: "#B39DDB",
        background: "#0A0D1F",
        onBackground: "#E8EAF6",
        error: "#EF5350",
        onError: "#3E0000",
        warning: "#FFB74D",
        onWarning: "#3E2700",
        success: "#66BB6A",
        onSuccess: "#003D00",
        outline: "#3F51B5"
    )

    // MARK: - Cherry Themes

    static let cherryLight = Self.init(
        primary: "#C2185B",
        onPrimary: "#FFFFFF",
        secondary: "#E91E63",
        onSecondary: "#FFFFFF",
        surface: "#FFFFFF",
        onSurface: "#1A1A1A",
        onSurfaceVariant: "#757575",
        background: "#FCE4EC",
        onBackground: "#1A1A1A",
        error: "#B71C1C",
        onError: "#FFFFFF",
        warning: "#F57C00",
        onWarning: "#000000",
        success: "#388E3C",
        onSuccess: "#FFFFFF",
        outline: "#F48FB1"
    )

    static let cherryDark = Self.init(
        primary: "#F06292",
        onPrimary: "#3E0016",
        secondary: "#F48FB1",
        onSecondary: "#3E0016",
        surface: "#2B1620",
        onSurface: "#FCE4EC",
        onSurfaceVariant: "#F8BBD0",
        background: "#1A0A12",
        onBackground: "#FCE4EC",
        error: "#EF5350",
        onError: "#3E0000",
        warning: "#FFB74D",
        onWarning: "#3E2700",
        success: "#66BB6A",
        onSuccess: "#003D00",
        outline: "#AD1457"
    )

    // MARK: - Lavender Themes

    static let lavenderLight = Self.init(
        primary: "#7B1FA2",
        onPrimary: "#FFFFFF",
        secondary: "#9C27B0",
        onSecondary: "#FFFFFF",
        surface: "#FFFFFF",
        onSurface: "#1A1A1A",
        onSurfaceVariant: "#757575",
        background: "#F3E5F5",
        onBackground: "#1A1A1A",
        error: "#C62828",
        onError: "#FFFFFF",
        warning: "#F57C00",
        onWarning: "#000000",
        success: "#388E3C",
        onSuccess: "#FFFFFF",
        outline: "#CE93D8"
    )

    static let lavenderDark = Self.init(
        primary: "#BA68C8",
        onPrimary: "#3E0A3E",
        secondary: "#CE93D8",
        onSecondary: "#3E0A3E",
        surface: "#1F1426",
        onSurface: "#F3E5F5",
        onSurfaceVariant: "#E1BEE7",
        background: "#120A18",
        onBackground: "#F3E5F5",
        error: "#EF5350",
        onError: "#3E0000",
        warning: "#FFB74D",
        onWarning: "#3E2700",
        success: "#66BB6A",
        onSuccess: "#003D00",
        outline: "#8E24AA"
    )

    // MARK: - Mocha Themes

    static let mochaLight = Self.init(
        primary: "#5D4037",
        onPrimary: "#FFFFFF",
        secondary: "#8D6E63",
        onSecondary: "#FFFFFF",
        surface: "#FFFFFF",
        onSurface: "#1A1A1A",
        onSurfaceVariant: "#757575",
        background: "#EFEBE9",
        onBackground: "#1A1A1A",
        error: "#C62828",
        onError: "#FFFFFF",
        warning: "#F57C00",
        onWarning: "#000000",
        success: "#388E3C",
        onSuccess: "#FFFFFF",
        outline: "#BCAAA4"
    )

    static let mochaDark = Self.init(
        primary: "#A1887F",
        onPrimary: "#2E1A14",
        secondary: "#BCAAA4",
        onSecondary: "#2E1A14",
        surface: "#231814",
        onSurface: "#EFEBE9",
        onSurfaceVariant: "#D7CCC8",
        background: "#14100D",
        onBackground: "#EFEBE9",
        error: "#EF5350",
        onError: "#3E0000",
        warning: "#FFB74D",
        onWarning: "#3E2700",
        success: "#66BB6A",
        onSuccess: "#003D00",
        outline: "#6D4C41"
    )

    // MARK: - Slate Themes

    static let slateLight = Self.init(
        primary: "#455A64",
        onPrimary: "#FFFFFF",
        secondary: "#607D8B",
        onSecondary: "#FFFFFF",
        surface: "#FFFFFF",
        onSurface: "#1A1A1A",
        onSurfaceVariant: "#616161",
        background: "#ECEFF1",
        onBackground: "#1A1A1A",
        error: "#C62828",
        onError: "#FFFFFF",
        warning: "#F57C00",
        onWarning: "#000000",
        success: "#388E3C",
        onSuccess: "#FFFFFF",
        outline: "#B0BEC5"
    )

    static let slateDark = Self.init(
        primary: "#90A4AE",
        onPrimary: "#1C2428",
        secondary: "#B0BEC5",
        onSecondary: "#1C2428",
        surface: "#1A2125",
        onSurface: "#ECEFF1",
        onSurfaceVariant: "#CFD8DC",
        background: "#0F1417",
        onBackground: "#ECEFF1",
        error: "#EF5350",
        onError: "#3E0000",
        warning: "#FFB74D",
        onWarning: "#3E2700",
        success: "#66BB6A",
        onSuccess: "#003D00",
        outline: "#546E7A"
    )

    // MARK: - Ember Themes

    static let emberLight = Self.init(
        primary: "#D84315",
        onPrimary: "#FFFFFF",
        secondary: "#FF5722",
        onSecondary: "#FFFFFF",
        surface: "#FFFFFF",
        onSurface: "#1A1A1A",
        onSurfaceVariant: "#757575",
        background: "#FBE9E7",
        onBackground: "#1A1A1A",
        error: "#B71C1C",
        onError: "#FFFFFF",
        warning: "#F57C00",
        onWarning: "#000000",
        success: "#388E3C",
        onSuccess: "#FFFFFF",
        outline: "#FFAB91"
    )

    static let emberDark = Self.init(
        primary: "#FF8A65",
        onPrimary: "#3E1808",
        secondary: "#FFAB91",
        onSecondary: "#3E1808",
        surface: "#2B1410",
        onSurface: "#FBE9E7",
        onSurfaceVariant: "#FFCCBC",
        background: "#1A0C08",
        onBackground: "#FBE9E7",
        error: "#EF5350",
        onError: "#3E0000",
        warning: "#FFB74D",
        onWarning: "#3E2700",
        success: "#66BB6A",
        onSuccess: "#003D00",
        outline: "#BF360C"
    )

    // MARK: - Mint Themes

    static let mintLight = Self.init(
        primary: "#00796B",
        onPrimary: "#FFFFFF",
        secondary: "#26A69A",
        onSecondary: "#000000",
        surface: "#FFFFFF",
        onSurface: "#1A1A1A",
        onSurfaceVariant: "#616161",
        background: "#E0F2F1",
        onBackground: "#1A1A1A",
        error: "#C62828",
        onError: "#FFFFFF",
        warning: "#F57C00",
        onWarning: "#000000",
        success: "#388E3C",
        onSuccess: "#FFFFFF",
        outline: "#80CBC4"
    )

    static let mintDark = Self.init(
        primary: "#4DB6AC",
        onPrimary: "#003D36",
        secondary: "#80CBC4",
        onSecondary: "#003D36",
        surface: "#14262A",
        onSurface: "#E0F2F1",
        onSurfaceVariant: "#B2DFDB",
        background: "#0A1A1C",
        onBackground: "#E0F2F1",
        error: "#EF5350",
        onError: "#3E0000",
        warning: "#FFB74D",
        onWarning: "#3E2700",
        success: "#66BB6A",
        onSuccess: "#003D00",
        outline: "#00695C"
    )

    // MARK: - Plum Themes

    static let plumLight = Self.init(
        primary: "#6A1B9A",
        onPrimary: "#FFFFFF",
        secondary: "#8E24AA",
        onSecondary: "#FFFFFF",
        surface: "#FFFFFF",
        onSurface: "#1A1A1A",
        onSurfaceVariant: "#757575",
        background: "#F3E5F5",
        onBackground: "#1A1A1A",
        error: "#C62828",
        onError: "#FFFFFF",
        warning: "#F57C00",
        onWarning: "#000000",
        success: "#388E3C",
        onSuccess: "#FFFFFF",
        outline: "#BA68C8"
    )

    static let plumDark = Self.init(
        primary: "#AB47BC",
        onPrimary: "#3E0A4E",
        secondary: "#BA68C8",
        onSecondary: "#3E0A4E",
        surface: "#1A0D24",
        onSurface: "#F3E5F5",
        onSurfaceVariant: "#CE93D8",
        background: "#0F0816",
        onBackground: "#F3E5F5",
        error: "#EF5350",
        onError: "#3E0000",
        warning: "#FFB74D",
        onWarning: "#3E2700",
        success: "#66BB6A",
        onSuccess: "#003D00",
        outline: "#7B1FA2"
    )

    // MARK: - Amber Themes

    static let amberLight = Self.init(
        primary: "#FF8F00",
        onPrimary: "#000000",
        secondary: "#FFC107",
        onSecondary: "#000000",
        surface: "#FFFFFF",
        onSurface: "#1A1A1A",
        onSurfaceVariant: "#757575",
        background: "#FFF8E1",
        onBackground: "#1A1A1A",
        error: "#C62828",
        onError: "#FFFFFF",
        warning: "#E65100",
        onWarning: "#FFFFFF",
        success: "#388E3C",
        onSuccess: "#FFFFFF",
        outline: "#FFD54F"
    )

    static let amberDark = Self.init(
        primary: "#FFB300",
        onPrimary: "#3E2F00",
        secondary: "#FFD54F",
        onSecondary: "#3E2F00",
        surface: "#2B2410",
        onSurface: "#FFF8E1",
        onSurfaceVariant: "#FFE082",
        background: "#1A1708",
        onBackground: "#FFF8E1",
        error: "#EF5350",
        onError: "#3E0000",
        warning: "#FF6F00",
        onWarning: "#FFFFFF",
        success: "#66BB6A",
        onSuccess: "#003D00",
        outline: "#F57C00"
    )

    // MARK: - Sage Themes

    static let sageLight = Self.init(
        primary: "#689F38",
        onPrimary: "#FFFFFF",
        secondary: "#9E9D24",
        onSecondary: "#000000",
        surface: "#FFFFFF",
        onSurface: "#1A1A1A",
        onSurfaceVariant: "#616161",
        background: "#F1F8E9",
        onBackground: "#1A1A1A",
        error: "#C62828",
        onError: "#FFFFFF",
        warning: "#F57C00",
        onWarning: "#000000",
        success: "#43A047",
        onSuccess: "#FFFFFF",
        outline: "#C5E1A5"
    )

    static let sageDark = Self.init(
        primary: "#9CCC65",
        onPrimary: "#2C3E14",
        secondary: "#DCE775",
        onSecondary: "#3E3C0A",
        surface: "#1A2414",
        onSurface: "#F1F8E9",
        onSurfaceVariant: "#DCEDC8",
        background: "#0F1708",
        onBackground: "#F1F8E9",
        error: "#EF5350",
        onError: "#3E0000",
        warning: "#FFB74D",
        onWarning: "#3E2700",
        success: "#66BB6A",
        onSuccess: "#003D00",
        outline: "#7CB342"
    )

    // MARK: - Rose Themes

    static let roseLight = Self.init(
        primary: "#C2185B",
        onPrimary: "#FFFFFF",
        secondary: "#F06292",
        onSecondary: "#000000",
        surface: "#FFFFFF",
        onSurface: "#1A1A1A",
        onSurfaceVariant: "#757575",
        background: "#FCE4EC",
        onBackground: "#1A1A1A",
        error: "#B71C1C",
        onError: "#FFFFFF",
        warning: "#F57C00",
        onWarning: "#000000",
        success: "#388E3C",
        onSuccess: "#FFFFFF",
        outline: "#F8BBD0"
    )

    static let roseDark = Self.init(
        primary: "#F06292",
        onPrimary: "#3E0016",
        secondary: "#F48FB1",
        onSecondary: "#3E0016",
        surface: "#2B1620",
        onSurface: "#FCE4EC",
        onSurfaceVariant: "#F8BBD0",
        background: "#1A0A12",
        onBackground: "#FCE4EC",
        error: "#EF5350",
        onError: "#3E0000",
        warning: "#FFB74D",
        onWarning: "#3E2700",
        success: "#66BB6A",
        onSuccess: "#003D00",
        outline: "#AD1457"
    )

    // MARK: - Indigo Themes

    static let indigoLight = Self.init(
        primary: "#283593",
        onPrimary: "#FFFFFF",
        secondary: "#3F51B5",
        onSecondary: "#FFFFFF",
        surface: "#FFFFFF",
        onSurface: "#1A1A1A",
        onSurfaceVariant: "#616161",
        background: "#E8EAF6",
        onBackground: "#1A1A1A",
        error: "#C62828",
        onError: "#FFFFFF",
        warning: "#F57C00",
        onWarning: "#000000",
        success: "#388E3C",
        onSuccess: "#FFFFFF",
        outline: "#9FA8DA"
    )

    static let indigoDark = Self.init(
        primary: "#5C6BC0",
        onPrimary: "#14193E",
        secondary: "#7986CB",
        onSecondary: "#14193E",
        surface: "#151A2E",
        onSurface: "#E8EAF6",
        onSurfaceVariant: "#C5CAE9",
        background: "#0A0D1F",
        onBackground: "#E8EAF6",
        error: "#EF5350",
        onError: "#3E0000",
        warning: "#FFB74D",
        onWarning: "#3E2700",
        success: "#66BB6A",
        onSuccess: "#003D00",
        outline: "#3949AB"
    )

    // MARK: - Coral Themes

    static let coralLight = Self.init(
        primary: "#FF6E40",
        onPrimary: "#FFFFFF",
        secondary: "#FF8A80",
        onSecondary: "#000000",
        surface: "#FFFFFF",
        onSurface: "#1A1A1A",
        onSurfaceVariant: "#757575",
        background: "#FBE9E7",
        onBackground: "#1A1A1A",
        error: "#B71C1C",
        onError: "#FFFFFF",
        warning: "#F57C00",
        onWarning: "#000000",
        success: "#388E3C",
        onSuccess: "#FFFFFF",
        outline: "#FFCCBC"
    )

    static let coralDark = Self.init(
        primary: "#FF9E80",
        onPrimary: "#3E1C08",
        secondary: "#FFAB91",
        onSecondary: "#3E1C08",
        surface: "#2B1814",
        onSurface: "#FBE9E7",
        onSurfaceVariant: "#FFCCBC",
        background: "#1A0F0A",
        onBackground: "#FBE9E7",
        error: "#EF5350",
        onError: "#3E0000",
        warning: "#FFB74D",
        onWarning: "#3E2700",
        success: "#66BB6A",
        onSuccess: "#003D00",
        outline: "#D84315"
    )

}
