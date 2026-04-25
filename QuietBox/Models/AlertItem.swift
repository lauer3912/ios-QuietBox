import Foundation

struct AlertItem: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let peakDb: Double
    let durationSeconds: Int

    init(peakDb: Double, durationSeconds: Int) {
        self.id = UUID()
        self.timestamp = Date()
        self.peakDb = peakDb
        self.durationSeconds = durationSeconds
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}