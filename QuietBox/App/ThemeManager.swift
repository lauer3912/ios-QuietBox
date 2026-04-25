import SwiftUI

struct ThemeManager {
    // MARK: - Colors
    struct Colors {
        static let primary = Color(hex: "10B981")
        static let warning = Color(hex: "F59E0B")
        static let danger = Color(hex: "EF4444")
        static let backgroundLight = Color(hex: "F0FDF4")
        static let backgroundDark = Color(hex: "052E16")
        static let textPrimary = Color(hex: "1E293B")
        static let textSecondary = Color(hex: "64748B")

        static let cardLight = Color.white
        static let cardDark = Color(hex: "064E3B")

        // Level colors
        static let levelQuiet = Color(hex: "10B981")
        static let levelModerate = Color(hex: "84CC16")
        static let levelLoud = Color(hex: "F59E0B")
        static let levelVeryLoud = Color(hex: "EF4444")
    }

    // MARK: - Color Scheme
    static func colorScheme(for theme: AppSettings.ThemeMode) -> ColorScheme? {
        switch theme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }

    // MARK: - Level Color
    static func color(for db: Double, threshold: Double) -> Color {
        if db < threshold * 0.7 {
            return levelQuiet
        } else if db < threshold {
            return levelModerate
        } else if db < threshold * 1.2 {
            return levelLoud
        } else {
            return levelVeryLoud
        }
    }

    // MARK: - Level Description
    static func description(for db: Double) -> String {
        if db < 40 {
            return "Whisper"
        } else if db < 60 {
            return "Normal"
        } else if db < 80 {
            return "Loud"
        } else if db < 100 {
            return "Very Loud"
        } else {
            return "Dangerous"
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Adaptive Colors
struct AdaptiveColors {
    @Environment(\.colorScheme) var colorScheme

    var background: Color {
        colorScheme == .dark ? ThemeManager.Colors.backgroundDark : ThemeManager.Colors.backgroundLight
    }

    var card: Color {
        colorScheme == .dark ? ThemeManager.Colors.cardDark : ThemeManager.Colors.cardLight
    }

    var text: Color {
        colorScheme == .dark ? Color.white : ThemeManager.Colors.textPrimary
    }

    var textSecondary: Color {
        colorScheme == .dark ? Color.white.opacity(0.7) : ThemeManager.Colors.textSecondary
    }
}