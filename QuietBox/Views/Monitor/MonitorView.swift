import SwiftUI

struct MonitorView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @StateObject private var viewModel = MonitorViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AdaptiveColors().background
                    .ignoresSafeArea()

                // Alert Banner
                if viewModel.showAlert {
                    AlertBanner(message: viewModel.alertMessage)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                VStack(spacing: 32) {
                    Spacer()

                    // Status Badge
                    HStack {
                        Circle()
                            .fill(viewModel.isMonitoring ? ThemeManager.Colors.primary : Color.gray)
                            .frame(width: 10, height: 10)

                        Text(viewModel.isMonitoring ? "Monitoring" : "Paused")
                            .font(.subheadline)
                            .foregroundColor(AdaptiveColors().textSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AdaptiveColors().card)
                    .cornerRadius(20)

                    // Noise Level Meter
                    NoiseLevelMeter(
                        db: viewModel.currentDb,
                        threshold: settingsVM.settings.thresholdDb,
                        isMonitoring: viewModel.isMonitoring
                    )

                    // dB Display
                    VStack(spacing: 4) {
                        Text("\(Int(viewModel.currentDb))")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(ThemeManager.color(for: viewModel.currentDb, threshold: settingsVM.settings.thresholdDb))

                        Text("dB")
                            .font(.title2)
                            .foregroundColor(AdaptiveColors().textSecondary)

                        Text(ThemeManager.description(for: viewModel.currentDb))
                            .font(.headline)
                            .foregroundColor(ThemeManager.color(for: viewModel.currentDb, threshold: settingsVM.settings.thresholdDb))
                    }

                    // Threshold Info
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(ThemeManager.Colors.warning)

                        Text("Threshold: \(Int(settingsVM.settings.thresholdDb)) dB")
                            .font(.subheadline)
                            .foregroundColor(AdaptiveColors().textSecondary)
                    }

                    Spacer()

                    // Start/Stop Button
                    Button(action: {
                        if viewModel.isMonitoring {
                            viewModel.stopMonitoring()
                        } else {
                            viewModel.startMonitoring()
                        }
                    }) {
                        HStack {
                            Image(systemName: viewModel.isMonitoring ? "stop.fill" : "play.fill")
                                .font(.title2)

                            Text(viewModel.isMonitoring ? "Stop Monitoring" : "Start Monitoring")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: viewModel.isMonitoring ? [Color.gray] : [ThemeManager.Colors.primary, ThemeManager.Colors.levelModerate],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                    .disabled(!viewModel.hasPermission && !viewModel.isMonitoring)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("QuietBox")
            .animation(.easeInOut(duration: 0.3), value: viewModel.showAlert)
            .onAppear {
                viewModel.checkPermission()
            }
        }
    }
}

#Preview {
    MonitorView()
        .environmentObject(SettingsViewModel())
}