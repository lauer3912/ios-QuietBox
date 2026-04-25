import XCTest

final class QuietBoxUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testNavigateToSettings() throws {
        // Tap Settings tab
        app.tabBars.buttons["Settings"].tap()

        // Verify we're on settings screen
        XCTAssertTrue(app.navigationBars["Settings"].exists)
    }

    func testStartMonitoring() throws {
        // Tap Start Monitoring button if available
        let startButton = app.buttons["Start Monitoring"]
        if startButton.exists {
            startButton.tap()
        }

        // Check if monitoring started
        XCTAssertTrue(app.buttons["Stop Monitoring"].exists || app.staticTexts["Monitoring"].exists)
    }
}