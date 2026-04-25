import Foundation
import SwiftUI

struct AppSettings: Codable {
    enum ThemeMode: String, Codable, CaseIterable {
        case light = "light"
        case dark = "dark"
        case system = "system"

        var displayName: String {
            switch self {
            case .light: return "Light"
            case .dark: return "Dark"
            case .system: return "System"
            }
        }

        var icon: String {
            switch self {
            case .light: return "sun.max.fill"
            case .dark: return "moon.fill"
            case .system: return "circle.lefthalf.filled"
            }
        }
    }

    var thresholdDb: Double = 60.0
    var soundEnabled: Bool = true
    var vibrateEnabled: Bool = true
    var themeMode: ThemeMode = .system

    // MARK: - UserDefaults Keys
    private static let settingsKey = "QuietBox_settings"

    // MARK: - Load/Save
    static func load() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings()
        }
        return settings
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: AppSettings.settingsKey)
        }
    }
}