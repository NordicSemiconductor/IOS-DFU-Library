// `XCTest` is not supported for watchOS Simulator.
#if !os(watchOS)
import Foundation
import XCTest

#if canImport(iOSDFULibrary)
@testable import iOSDFULibrary
#elseif canImport(NordicDFU)
@testable import NordicDFU
#endif

class Hex2BinConverterTests: XCTestCase {
    
    // MARK: - Real HEX files
    
    func testSoftDevice() {
        performTest(for: "s110_nrf51822_6.2.1_softdevice", withMbrSize: 0x1000)
    }
    
    func testBlinky() {
        performTest(for: "blinky_s110_v7_0_0_sdk_v7_1")
    }
    
    func testHRM() {
        performTest(for: "ble_app_hrm_dfu_s110_v8_0_0_sdk_v8_0")
    }
    
    func testBootloader() {
        performTest(for: "sdk_15_2_bootloader")
    }
    
    func testOnlySoftDevice() {
        // This HEX file contains SD+BL, but they are separated by a blank region.
        // The second jump (0x04) is from 0001 to 0003 which is not supported.
        // Only the SD will then be converted to BIN.
        performTest(for: "nrf51422_sdk_5.2_sd_bl", withMbrSize: 0x1000)
    }
    
    // MARK: - Special cases
    
    func testSimpleHex() {
        let hex = """
        :02000000010206
        :02000200030480
        :00000001FF
        """.data(using: .ascii)!
        
        let bin = IntelHex2BinConverter.convert(hex)
        XCTAssertNotNil(bin)
        XCTAssertEqual(bin, Data([0x01, 0x02, 0x03, 0x04]))
    }
    
    func testPrematureEndOfFile() {
        let hex = """
        :02000000010206
        :00000001FF
        :02000200030480
        """.data(using: .ascii)!
        
        let bin = IntelHex2BinConverter.convert(hex)
        XCTAssertNotNil(bin)
        XCTAssertEqual(bin, Data([0x01, 0x02]))
    }
    
    func testMbr() {
        let hex = """
        :02000000010206
        :02000200030480
        :00000001FF
        """.data(using: .ascii)!
        
        let bin = IntelHex2BinConverter.convert(hex, mbrSize: 2)
        XCTAssertNotNil(bin)
        XCTAssertEqual(bin, Data([0x03, 0x04]))
    }
    
    func testMbrInsideRecord() {
        let hex = """
        :02000000010206
        :02000200030480
        :00000001FF
        """.data(using: .ascii)!
        
        let bin = IntelHex2BinConverter.convert(hex, mbrSize: 1)
        XCTAssertNotNil(bin)
        XCTAssertEqual(bin, Data([0x02, 0x03, 0x04]))
    }
    
    func testShortRecordLength() {
        let hex = """
        :020000040001F9
        :02600000010206
        :02600200030480
        :0400000500016000D5
        :00000001FF
        """.data(using: .ascii)!
        
        let bin = IntelHex2BinConverter.convert(hex)
        XCTAssertNotNil(bin)
        XCTAssertEqual(bin, Data([0x01, 0x02, 0x03, 0x04]))
    }
    
    func testInvalidRecordLength() {
        let hex = """
        :020000040001F9
        :0460000008280020F56001000F6101001161010006
        :106020000000000000000000000000000000000080
        :0400000500016000D5
        :00000001FF
        """.data(using: .ascii)!
        
        let bin = IntelHex2BinConverter.convert(hex)
        XCTAssertNil(bin)
    }
    
    func testGapInHex() {
        let hex = """
        :020000040001F9
        :1060000008280020F56001000F6101001161010006
        :106020000000000000000000000000000000000080
        :0400000500016000D5
        :00000001FF
        """.data(using: .ascii)!
        
        let bin = IntelHex2BinConverter.convert(hex)
        XCTAssertNotNil(bin)
        XCTAssertEqual(bin, Data([0x08, 0x28, 0x00, 0x20, 0xF5, 0x60, 0x01, 0x00, 0x0F, 0x61, 0x01, 0x00, 0x11, 0x61, 0x01, 0x00]))
    }
    
    func testBigJumpInHex() {
        let hex = """
        :020000040001F9
        :1060000008280020F56001000F6101001161010006
        :020000040003F9
        :100000000000000000000000000000000000000080
        :0400000500016000D5
        :00000001FF
        """.data(using: .ascii)!
        
        let bin = IntelHex2BinConverter.convert(hex)
        XCTAssertNotNil(bin)
        XCTAssertEqual(bin, Data([0x08, 0x28, 0x00, 0x20, 0xF5, 0x60, 0x01, 0x00, 0x0F, 0x61, 0x01, 0x00, 0x11, 0x61, 0x01, 0x00]))
    }
    
    func testExtendedLinearAddressRecord() {
        let hex = """
        :020000040000F9
        :10FFF00008280020F56001000F6101001161010006
        :020000040001F9
        :100000000000000000000000000000000000000080
        :0400000500016000D5
        :00000001FF
        """.data(using: .ascii)!
        
        let bin = IntelHex2BinConverter.convert(hex)
        XCTAssertNotNil(bin)
        XCTAssertEqual(bin, Data([0x08, 0x28, 0x00, 0x20, 0xF5, 0x60, 0x01, 0x00, 0x0F, 0x61, 0x01, 0x00, 0x11, 0x61, 0x01, 0x00,
                                  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
    }
    
    func testExtendedSegmentAddressRecord() {
        let hex = """
        :020000021000F9
        :10FFF00008280020F56001000F6101001161010006
        :020000022000F9
        :100000000000000000000000000000000000000080
        :020000031000D5
        :00000001FF
        """.data(using: .ascii)!
        
        let bin = IntelHex2BinConverter.convert(hex)
        XCTAssertNotNil(bin)
        XCTAssertEqual(bin, Data([0x08, 0x28, 0x00, 0x20, 0xF5, 0x60, 0x01, 0x00, 0x0F, 0x61, 0x01, 0x00, 0x11, 0x61, 0x01, 0x00,
                                  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
    }
    
    // MARK: - Helper methods
    
    private func performTest(for name: String, withMbrSize mbrSize: UInt32 = 0) {
        var baseURL = URL(fileURLWithPath: #file)
        baseURL.deleteLastPathComponent()
        baseURL.appendPathComponent("TestFirmwares")
      
        let url = baseURL.appendingPathComponent(name + ".hex")
        XCTAssertNotNil(url)
        
        let testUrl = baseURL.appendingPathComponent(name + ".bin")
        XCTAssertNotNil(testUrl)
        
        var data: Data!
        XCTAssertNoThrow(data = try Data(contentsOf: url))
        XCTAssertNotNil(data)
        var testData: Data!
        XCTAssertNoThrow(testData = try Data(contentsOf: testUrl))
        XCTAssertNotNil(testData)
        
        let bin = IntelHex2BinConverter.convert(data, mbrSize: mbrSize)
        XCTAssertNotNil(bin)
        
        XCTAssertEqual(bin, testData)
    }
}
#endif
