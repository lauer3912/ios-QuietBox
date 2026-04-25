import AVFoundation
import Foundation

class AudioMeteringService: ObservableObject {
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?

    @Published var currentDb: Double = 0.0
    @Published var isMonitoring = false

    // Audio processing
    private let bufferSize: AVAudioFrameCount = 1024
    private let sampleRate: Double = 44100.0

    // Alert debounce
    private var lastAlertTime: Date?
    private let alertDebounceSeconds: TimeInterval = 1.0

    // Callback for threshold exceeded
    var onThresholdExceeded: (() -> Void)?

    init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    func startMonitoring() {
        guard !isMonitoring else { return }

        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }

        inputNode = audioEngine.inputNode
        guard let inputNode = inputNode else { return }

        let format = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: format) { [weak self] buffer, _ in
            self?.processAudioBuffer(buffer)
        }

        do {
            try audioEngine.start()
            DispatchQueue.main.async {
                self.isMonitoring = true
            }
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }

    func stopMonitoring() {
        guard isMonitoring else { return }

        inputNode?.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        inputNode = nil

        DispatchQueue.main.async {
            self.isMonitoring = false
            self.currentDb = 0.0
        }
    }

    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }

        let channelDataValue = channelData.pointee
        let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map { channelDataValue[$0] }

        // Calculate RMS
        let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))

        // Convert to dB
        let db = 20 * log10(rms)
        let normalizedDb = max(0, min(120, db + 100)) // Normalize to 0-120 range

        DispatchQueue.main.async {
            self.currentDb = normalizedDb
        }
    }

    func checkThreshold(_ threshold: Double) -> Bool {
        let now = Date()

        if currentDb > threshold {
            if let lastAlert = lastAlertTime, now.timeIntervalSince(lastAlert) < alertDebounceSeconds {
                return false
            }
            lastAlertTime = now
            return true
        }
        return false
    }

    deinit {
        stopMonitoring()
    }
}