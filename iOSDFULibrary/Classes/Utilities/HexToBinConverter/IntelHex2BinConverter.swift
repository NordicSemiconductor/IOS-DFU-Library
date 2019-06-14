//
//  IntelHex2BinConverter2.swift
//  iOSDFULibrary-iOS
//
//  Created by Aleksander Nowakowski on 13/06/2019.
//

import Foundation

/// This converter converts Intel HEX file to BIN.
/// It is based on this specification:
/// http://www.interlog.com/~speff/usefulinfo/Hexfrmt.pdf
///
/// Not all Intel HEX features are supported!
/// The converter does not support gaps in the firmware. The returned
/// BIN contains data until the first found gap.
///
/// Supported Record Types:
/// * 0x04 - Extended Linear Address Record
/// * 0x02 - Extended Segment Address Record
/// * 0x01 - End of File
/// * 0x00 - Data Record
///
/// If MBR size is provided, the values from addresses 0..<MBR Size will
/// be ignored.
public class IntelHex2BinConverter: NSObject {
    
    /// Converts the Intel HEX data to a bin format by subtracting
    /// only the data part from it.
    ///
    /// Gaps in the addresses are not supported.
    /// The returned data contains binary content until the first gap
    /// or end of the file.
    ///
    /// - parameter hex: Intel HEX fine as `Data`.
    /// - parameter mbrSize: The MBR size. MBR starts at address 0.
    ///                      MBR is ignored during convertion.
    /// - returns: The binary part cut from the given file.
    public static func convert(_ hex: Data, mbrSize: UInt32 = 0) -> Data? {
        guard hex.count > 0 else {
            return nil
        }
        
        var bin = Data()
        var offset = 0
        var currentAddress = 0
        
        while offset < hex.count {
            // Each line must start with ':'.
            guard hex[offset] == 0x3A else {
                // Not a valid Intel HEX file.
                return nil
            }
            offset += 1
            
            // Each line must contain length (2 characters), offset (4 characters) and type (2 characters).
            guard hex.count > offset + 8 else {
                return nil
            }
            
            let recordLength = Int(readByte(from: hex, at: &offset))
            let recordOffset = readAddress(form: hex, at: &offset)
            let recordType   = readByte(from: hex, at: &offset)
            
            // Each line must contain given number bytes (encoded as 2 ASCII characters) and a checksum (2 characters).
            guard hex.count >= offset + recordLength * 2 + 2 else {
                return nil
            }
            
            switch recordType {
                
            case 0x04: // Extended Linear Address Record.
                let ulba = readAddress(form: hex, at: &offset) << 16 // bits 16-31
                guard bin.count == 0 || ulba == currentAddress else {
                    // Gaps in addresses are not supported.
                    return bin
                }
                currentAddress = ulba
                // Skip checksum.
                offset += 2
                
            case 0x02: // Extended Segment Address Record.
                let sba = readAddress(form: hex, at: &offset) << 4 // bits 4-19
                guard bin.count == 0 || sba == currentAddress else {
                    // Gaps in addresses are not supported.
                    return bin
                }
                currentAddress = sba
                // Skip checksum.
                offset += 2
                
            case 0x01: // End of file.
                return bin
                
            case 0x00: // Data Record.
                guard bin.count == 0 || currentAddress == (currentAddress & 0xFFFF0000) + recordOffset else {
                    // A gap detacted.
                    return bin
                }
                // Add record length if the address is higher than MBR size.
                for i in 0..<recordLength {
                    if (currentAddress & 0xFFFF0000) + recordOffset + i >= mbrSize {
                        bin.append(readByte(from: hex, at: &offset))
                    } else {
                        // Skip MBR byte.
                        offset += 2
                    }
                }
                currentAddress = (currentAddress & 0xFFFF0000) + recordOffset + recordLength
                // Skip checksum.
                offset += 2
                
            default:
                // Skip data and checksum.
                offset += recordLength * 2 + 2
            }
            if hex.count > offset && hex[offset] == 0x0D { offset += 1 } // Skip CR.
            if hex.count > offset && hex[offset] == 0x0A { offset += 1 } // Skip LF.
            
        }
        return bin
    }
    
}

private extension IntelHex2BinConverter {
    
    /// Converts the byte written in ASCII to hexadecimal value.
    ///
    /// - parameter byte: The hex character in ASCII.
    ///                   This must be in range "0-9A-F".
    /// - returns: The hexadecimal value of the character.
    static func ascii2hex(_ byte: UInt8) -> UInt8 {
        if byte >= 0x41 { // 'A'
            return byte - 0x37
        }
        return byte - 0x30
    }
    
    /// Reads the full byte from ASCII characters at given offset.
    ///
    /// - parameter data: The source data.
    /// - parameter offset: The offset from which to read the byte.
    static func readByte(from data: Data, at offset: inout Int) -> UInt8 {
        let first  = ascii2hex(data[offset])
        let second = ascii2hex(data[offset + 1])
        offset += 2
        return (first << 4) | second
    }
    
    /// Reads the 16-bit address from given address and returns as UInt32.
    ///
    /// - parameter data: The source data.
    /// - parameter offset: The offset from which to read the address.
    static func readAddress(form data: Data, at offset: inout Int) -> Int {
        let msb = Int(readByte(from: data, at: &offset))
        let lsb = Int(readByte(from: data, at: &offset))
        return (msb << 8) | lsb
    }
    
}
