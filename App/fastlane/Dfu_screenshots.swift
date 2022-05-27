//
//  nRF_Edge_Impulse_Screenshots.swift
//  nRF Edge Impulse Screenshots
//
//  Created by Dinesh Harjani on 25/10/21.
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
        
        try login(app)
        _ = app.cells["E6Chemistry"].waitForExistence(timeout: 15)
    }

    // MARK: - tearDown
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Tests
    
    func testDevices() throws {
        Snapshot.snapshot("01Devices")
    }
    
    func testDeviceDetails() throws {
        let deviceCell = app.cells.containing(NSPredicate(format: "label CONTAINS %@", "thingy53")).element
        deviceCell.tap()
        Snapshot.snapshot("02DeviceDetails")
    }
    
    func testDataAcquisition() throws {
        let dataAcquisitionTab = app.buttons["Data Acquisition"]
        dataAcquisitionTab.tap()
        Snapshot.snapshot("03DataAcquisition")
    }
}

// MARK: - Private

fileprivate extension nRF_Edge_Impulse_Screenshots {
    
    func login(_ app: XCUIApplication) throws {
        let loginButton = app.buttons["Login"]
        guard loginButton.exists else { return }
        
        let usernameTextField = try XCTUnwrap(app.textFields["Username or E-Mail"])
        usernameTextField.typeText("dinesh.harjani")
        
        let passwordTextField = try XCTUnwrap(app.secureTextFields.firstMatch)
        passwordTextField.tap()
        passwordTextField.typeText("_bzpnes_w-uAzT7eo4Mcg-o-")
        
        loginButton.tap()
    }
}
