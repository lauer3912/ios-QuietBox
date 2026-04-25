import Foundation
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings {
        didSet {
            settings.save()
        }
    }

    init() {
        self.settings = AppSettings.load()
    }

    var colorScheme: ColorScheme? {
        ThemeManager.colorScheme(for: settings.themeMode)
    }

    func toggleSound() {
        settings.soundEnabled.toggle()
    }

    func toggleVibrate() {
        settings.vibrateEnabled.toggle()
    }

    func setThreshold(_ value: Double) {
        settings.thresholdDb = value
    }

    func setThemeMode(_ mode: AppSettings.ThemeMode) {
        settings.themeMode = mode
    }
}