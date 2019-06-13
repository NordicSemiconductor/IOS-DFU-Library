import UIKit
import XCTest
@testable import iOSDFULibrary

class Hex2BinConverterTests: XCTestCase {
    
    func testSoftDevice() {
        perform(for: "s110_nrf51822_6.2.1_softdevice")
    }
    
    func testBlinky() {
        perform(for: "blinky_s110_v7_0_0_sdk_v7_1")
    }
    
    func testHRM() {
        perform(for: "ble_app_hrm_dfu_s110_v8_0_0_sdk_v8_0")
    }
    
    func testBootloader() {
        perform(for: "sdk_15_2_bootloader")
    }
    
    func testOnlySoftDevice() {
        // This HEX file contains SD+BL, but they are separated by a blank region.
        // The second jump (0x04) is from 0001 to 0003 which is not supported.
        // Only the SD will then be converted to BIN.
        perform(for: "nrf51422_sdk_5.2_sd_bl")
    }
    
    private func perform(for name: String) {
        let url = Bundle.main.url(forResource: name, withExtension: "hex", subdirectory: "TestFirmwares")
        XCTAssertNotNil(url)
        
        let testUrl = Bundle.main.url(forResource: name, withExtension: "bin", subdirectory: "TestFirmwares")
        XCTAssertNotNil(testUrl)
        
        var data: Data!
        XCTAssertNoThrow(data = try Data(contentsOf: url!))
        XCTAssertNotNil(data)
        var testData: Data!
        XCTAssertNoThrow(testData = try Data(contentsOf: testUrl!))
        XCTAssertNotNil(testData)
        
        let bin = IntelHex2BinConverter.convert(data)
        XCTAssertNotNil(bin)
        
        XCTAssertEqual(bin, testData)
    }
    
}
