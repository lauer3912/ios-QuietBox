import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @StateObject private var monitorVM = MonitorViewModel()
    @State private var showClearAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                AdaptiveColors().background
                    .ignoresSafeArea()

                List {
                    // Threshold Section
                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Threshold")
                                Spacer()
                                Text("\(Int(settingsVM.settings.thresholdDb)) dB")
                                    .foregroundColor(ThemeManager.Colors.primary)
                                    .font(.headline)
                            }

                            Slider(
                                value: Binding(
                                    get: { settingsVM.settings.thresholdDb },
                                    set: { settingsVM.setThreshold($0) }
                                ),
                                in: 40...100,
                                step: 5
                            )
                            .tint(ThemeManager.Colors.primary)

                            HStack {
                                Text("Quiet")
                                    .font(.caption)
                                    .foregroundColor(AdaptiveColors().textSecondary)
                                Spacer()
                                Text("Loud")
                                    .font(.caption)
                                    .foregroundColor(AdaptiveColors().textSecondary)
                            }
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("Noise Threshold")
                    }
                    .listRowBackground(AdaptiveColors().card)

                    // Alerts Section
                    Section {
                        Toggle(isOn: Binding(
                            get: { settingsVM.settings.soundEnabled },
                            set: { _ in settingsVM.toggleSound() }
                        )) {
                            HStack {
                                Image(systemName: settingsVM.settings.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                    .foregroundColor(ThemeManager.Colors.primary)
                                    .frame(width: 30)
                                Text("Sound Alert")
                            }
                        }
                        .tint(ThemeManager.Colors.primary)

                        Toggle(isOn: Binding(
                            get: { settingsVM.settings.vibrateEnabled },
                            set: { _ in settingsVM.toggleVibrate() }
                        )) {
                            HStack {
                                Image(systemName: "iphone.radiowaves.left.and.right")
                                    .foregroundColor(ThemeManager.Colors.primary)
                                    .frame(width: 30)
                                Text("Vibration Alert")
                            }
                        }
                        .tint(ThemeManager.Colors.primary)
                    } header: {
                        Text("Alert Options")
                    }
                    .listRowBackground(AdaptiveColors().card)

                    // Appearance Section
                    Section {
                        ForEach(AppSettings.ThemeMode.allCases, id: \.self) { mode in
                            Button(action: {
                                settingsVM.setThemeMode(mode)
                            }) {
                                HStack {
                                    Image(systemName: mode.icon)
                                        .foregroundColor(ThemeManager.Colors.primary)
                                        .frame(width: 30)

                                    Text(mode.displayName)
                                        .foregroundColor(AdaptiveColors().text)

                                    Spacer()

                                    if settingsVM.settings.themeMode == mode {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(ThemeManager.Colors.primary)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Appearance")
                    }
                    .listRowBackground(AdaptiveColors().card)

                    // Alert History Section
                    Section {
                        let history = monitorVM.loadHistory()

                        if history.isEmpty {
                            Text("No alerts yet")
                                .foregroundColor(AdaptiveColors().textSecondary)
                                .italic()
                        } else {
                            ForEach(history.prefix(10)) { item in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(Int(item.peakDb)) dB")
                                            .font(.headline)
                                            .foregroundColor(ThemeManager.Colors.danger)

                                        Text(item.formattedDate)
                                            .font(.caption)
                                            .foregroundColor(AdaptiveColors().textSecondary)
                                    }

                                    Spacer()

                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(ThemeManager.Colors.warning)
                                }
                            }

                            if history.count > 10 {
                                Text("+ \(history.count - 10) more")
                                    .font(.caption)
                                    .foregroundColor(AdaptiveColors().textSecondary)
                            }

                            Button(action: {
                                showClearAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.red)
                                    Text("Clear History")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    } header: {
                        Text("Alert History")
                    }
                    .listRowBackground(AdaptiveColors().card)

                    // About Section
                    Section {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(AdaptiveColors().textSecondary)
                        }

                        Link(destination: URL(string: "https://github.com/lauer3912/ios-QuietBox")!) {
                            HStack {
                                Text("Source Code")
                                    .foregroundColor(AdaptiveColors().text)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(ThemeManager.Colors.primary)
                            }
                        }
                    } header: {
                        Text("About")
                    }
                    .listRowBackground(AdaptiveColors().card)
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Settings")
            .alert("Clear History", isPresented: $showClearAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    monitorVM.clearHistory()
                }
            } message: {
                Text("Are you sure you want to clear all alert history?")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
}