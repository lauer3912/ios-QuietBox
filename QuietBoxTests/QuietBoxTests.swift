import XCTest
@testable import QuietBox

final class QuietBoxTests: XCTestCase {

    func testAlertItemCreation() {
        let item = AlertItem(peakDb: 85.5, durationSeconds: 3)
        XCTAssertEqual(item.peakDb, 85.5)
        XCTAssertEqual(item.durationSeconds, 3)
        XCTAssertNotNil(item.id)
    }

    func testAppSettingsDefaults() {
        let settings = AppSettings()
        XCTAssertEqual(settings.thresholdDb, 60.0)
        XCTAssertEqual(settings.themeMode, .system)
        XCTAssertTrue(settings.soundEnabled)
        XCTAssertTrue(settings.vibrateEnabled)
    }

    func testThresholdRange() {
        var settings = AppSettings()
        settings.thresholdDb = 80.0
        XCTAssertEqual(settings.thresholdDb, 80.0)
    }
}