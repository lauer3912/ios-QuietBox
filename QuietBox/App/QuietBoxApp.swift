import SwiftUI

@main
struct QuietBoxApp: App {
    @StateObject private var settingsVM = SettingsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settingsVM)
                .preferredColorScheme(settingsVM.colorScheme)
        }
    }
}