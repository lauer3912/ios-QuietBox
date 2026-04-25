import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel

    var body: some View {
        TabView {
            MonitorView()
                .tabItem {
                    Label("Monitor", systemImage: "waveform")
                }
                .tag(0)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(1)
        }
        .tint(ThemeManager.Colors.primary)
    }
}

#Preview {
    ContentView()
        .environmentObject(SettingsViewModel())
}