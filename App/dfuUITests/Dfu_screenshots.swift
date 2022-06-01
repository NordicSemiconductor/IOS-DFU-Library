//
//  Dfu_screenshots.swift
//  Dfu_screenshots
//
//  Ref: Dinesh Harjani on 25/10/21.
//

import XCTest

final class Dfu_screenshots: XCTestCase {

    // MARK: - Setup
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        XCUIDevice.shared.orientation = .portrait
        
        // UI tests must launch the application that they test.
        app = XCUIApplication()
        app.launch()
        setupSnapshot(app)
    }

    // MARK: - tearDown
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Tests
    
    func testDevices() throws {
        Snapshot.snapshot("01Devices")
    }
    
    func testSettings() throws {
        let settingsButton = app.buttons[DfuIds.settingsButton.id]
        settingsButton.tap()
        Snapshot.snapshot("02Settings")
    }
    
    func testWelcome() throws {
        let settingsButton = app.buttons[DfuIds.settingsButton.id]
        settingsButton.tap()
        let welcomeButton = app.buttons[DfuIds.welcomeButton.id]
        welcomeButton.tap()
        Snapshot.snapshot("03Welcome")
    }
}
