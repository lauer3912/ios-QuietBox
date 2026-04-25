import Foundation
import SwiftUI
import AVFoundation
import UIKit

@MainActor
class MonitorViewModel: ObservableObject {
    @Published var currentDb: Double = 0.0
    @Published var isMonitoring = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var hasPermission = false

    private let audioService = AudioMeteringService()
    private let historyKey = "QuietBox_alertHistory"

    var settings: AppSettings = AppSettings.load()

    init() {
        checkPermission()
    }

    func checkPermission() {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            hasPermission = true
        case .denied:
            hasPermission = false
        case .undetermined:
            requestPermission()
        @unknown default:
            hasPermission = false
        }
    }

    func requestPermission() {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.hasPermission = granted
            }
        }
    }

    func startMonitoring() {
        guard hasPermission else {
            requestPermission()
            return
        }

        audioService.startMonitoring()
        isMonitoring = true

        // Start polling dB level
        startPolling()
    }

    func stopMonitoring() {
        audioService.stopMonitoring()
        isMonitoring = false
        currentDb = 0.0
    }

    private func startPolling() {
        Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            Task { @MainActor in
                guard self.isMonitoring else {
                    timer.invalidate()
                    return
                }

                self.currentDb = self.audioService.currentDb

                // Check threshold
                if self.audioService.checkThreshold(self.settings.thresholdDb) {
                    self.triggerAlert()
                }
            }
        }
    }

    private func triggerAlert() {
        // Sound alert
        if settings.soundEnabled {
            AudioServicesPlaySystemSound(1007) // Default alert sound
        }

        // Haptic alert
        if settings.vibrateEnabled {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }

        // Show alert banner
        alertMessage = "Noise level exceeded!"
        showAlert = true

        // Save to history
        saveAlert()

        // Hide alert after 2 seconds
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            showAlert = false
        }
    }

    private func saveAlert() {
        var history = loadHistory()
        let item = AlertItem(peakDb: currentDb, durationSeconds: 1)
        history.insert(item, at: 0)

        // Keep only last 50
        if history.count > 50 {
            history = Array(history.prefix(50))
        }

        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }

    func loadHistory() -> [AlertItem] {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let history = try? JSONDecoder().decode([AlertItem].self, from: data) else {
            return []
        }
        return history
    }

    func clearHistory() {
        UserDefaults.standard.removeObject(forKey: historyKey)
    }
}