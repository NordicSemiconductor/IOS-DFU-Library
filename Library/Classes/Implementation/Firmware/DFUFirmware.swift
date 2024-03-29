/*
* Copyright (c) 2019, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation

/**
 The type of the BIN or HEX file, or selection of content from the Distribution
 packet (ZIP) file.
 
 Select ``softdeviceBootloaderApplication`` to sent all files from the ZIP
 (even it there is let's say only application). This works as a filter.
 If you have SD+BL+App in the ZIP, but want to send only App, you may set the
 type to ``application``.
*/
@objc public enum DFUFirmwareType : UInt8 {
    /// Firmware file will be sent as a new SoftDevice.
    case softdevice = 1
    /// Firmware file will be sent as a new Bootloader.
    case bootloader = 2
    /// Firmware file will be sent as a new Application.
    case application = 4
    
    // Merged option values (due to objc - Swift compatibility).
    
    /// Firmware file will be sent as a new SoftDevice + Bootloader.
    case softdeviceBootloader = 3
    /// All content of the ZIP file will be sent.
    case softdeviceBootloaderApplication = 7
}

/**
 An error thrown when instantiating a ``DFUFirmware`` type from an invalid file.
 */
public struct DFUFirmwareError : Error {
    /// The firmware type.
    public enum FileType {
        /// A Distribution packet (ZIP) has failed to be parsed.
        case zip
        /// The file is a BIN or a HEX file.
        case binOrHex
        /// The file is an Init file.
        case dat
    }
    /// The firmware type.
    public let type: FileType
}

extension DFUFirmwareError : LocalizedError {
    
    public var errorDescription: String? {
        return NSLocalizedString("The \(type) file is invalid", comment: "")
    }
    
}

/**
 The DFU Firmware object wraps the firmware file and provides access to its content.
 */
@objc public class DFUFirmware : NSObject, DFUStream {
    internal let stream: DFUStream
    
    /// The name of the firmware file.
    @objc public let fileName: String?
    /// The URL to the firmware file.
    @objc public let fileUrl: URL?
    
    /// Information whether the firmware was successfully initialized.
    @objc public var valid: Bool {
        // init(...) would return nil if the firmware was invalid.
        return true
    }
    
    /// The size of each component of the firmware.
    @objc public var size: DFUFirmwareSize {
        return stream.size
    }
    
    /**
     Number of connections required to transfer the firmware.
    
     If a ZIP file contains a new firmware for the SoftDevice (and/or Bootloader)
     and the Application, the number of parts is equal to 2. Otherwise this is
     always 1.
     */
    @objc public var parts: Int {
        return stream.parts
    }
    
    internal var currentPartSize: DFUFirmwareSize {
        return stream.currentPartSize
    }
    
    internal var currentPartType: UInt8 {
        return stream.currentPartType
    }
    
    internal var currentPart: Int {
        return stream.currentPart
    }
    
    /**
     Creates the DFU Firmware object from a Distribution packet (ZIP).
     
     Such file must contain a manifest.json file with firmware metadata and at
     least one firmware binaries. Read more about the Distribution packet on
     the DFU documentation.
     
     - parameter urlToZipFile: URL to the Distribution packet (ZIP).
     
     - returns: The DFU firmware object or `nil` in case of an error.
     - throws: ``DFUFirmwareError`` if the file is invalid, or
               ``DFUStreamZipError`` if creating a Zip stream failed.
     */
    @objc convenience public init(urlToZipFile: URL) throws {
        try self.init(urlToZipFile: urlToZipFile,
                      type: DFUFirmwareType.softdeviceBootloaderApplication)
    }
    
    /**
     Creates the DFU Firmware object from a Distribution packet (ZIP).
     
     Such file must contain a manifest.json file with firmware metadata and at
     least one firmware binaries. Read more about the Distribution packet on
     the DFU documentation.
     
     - parameters:
       - urlToZipFile: URL to the Distribution packet (ZIP).
       -  type: The type of the firmware to use.
     
     - returns: The DFU firmware object or `nil` in case of an error.
     - throws: ``DFUFirmwareError`` if the file is invalid, or
               ``DFUStreamZipError`` if creating a Zip stream failed.
     */
    @objc public init(urlToZipFile: URL, type: DFUFirmwareType) throws {
        fileUrl = urlToZipFile
        fileName = urlToZipFile.lastPathComponent
        
        // Quickly check if it's a ZIP file
        let ext = urlToZipFile.pathExtension
        if ext.caseInsensitiveCompare("zip") != .orderedSame {
            throw DFUFirmwareError(type: .zip)
        }
        
        stream = try DFUStreamZip(urlToZipFile: urlToZipFile, type: type)
        super.init()
    }
    
    /**
     Creates the DFU Firmware object from a Distribution packet (ZIP).
     
     Such file must contain a manifest.json file with firmware metadata and at
     least one firmware binaries. Read more about the Distribution packet on
     the DFU documentation.
     
     - parameter zipFile: The Distribution packet (ZIP) data.
     
     - returns: The DFU firmware object or `nil` in case of an error.
     - throws: ``DFUFirmwareError`` if the file is invalid,
               ``DFUStreamZipError`` if creating a Zip stream failed,
               or an error in the Cocoa domain, if the data cannot be written
               to a temporary location.
     */
    @objc convenience public init(zipFile: Data) throws {
        try self.init(zipFile: zipFile, type: DFUFirmwareType.softdeviceBootloaderApplication)
    }
    
    /**
     Creates the DFU Firmware object from a Distribution packet (ZIP).
     
     Such file must contain a manifest.json file with firmware metadata and at
     least one firmware binaries. Read more about the Distribution packet on
     the DFU documentation.
     
     - parameters:
       - zipFile: The Distribution packet (ZIP) data.
       - type: The type of the firmware to use.
     
     - returns: The DFU firmware object or `nil` in case of an error.
     - throws: ``DFUFirmwareError`` if the file is invalid,
               ``DFUStreamZipError`` if creating a Zip stream failed,
               or an error in the Cocoa domain, if the data cannot be written
               to a temporary location.
     */
    @objc public init(zipFile: Data, type: DFUFirmwareType) throws {
        fileUrl = nil
        fileName = nil
        stream = try DFUStreamZip(zipFile: zipFile, type: type)
        super.init()
    }
    
    /**
     Creates the DFU Firmware object from a BIN or HEX file. 
     
     Setting the DAT file with an Init packet is optional, but may be required by the
     bootloader (SDK 7.0.0+).
     
     - parameters:
       - urlToBinOrHexFile: URL to a BIN or HEX file with the firmware.
       - urlToDatFile: An optional URL to a DAT file with the Init packet.
       - type: The type of the firmware.
     
     - returns: The DFU firmware object or `nil` in case of an error.
     - throws: ``DFUFirmwareError`` if the file is invalid,
               ``DFUStreamHexError`` if the hex file is invalid,
               or an error in the Cocoa domain, if `url` cannot be read.
     */
    @objc public init(urlToBinOrHexFile: URL, urlToDatFile: URL?, type: DFUFirmwareType) throws {
        fileUrl = urlToBinOrHexFile
        fileName = urlToBinOrHexFile.lastPathComponent
        
        // Quickly check if it's a BIN file
        let ext = urlToBinOrHexFile.pathExtension
        let bin = ext.caseInsensitiveCompare("bin") == .orderedSame
        let hex = ext.caseInsensitiveCompare("hex") == .orderedSame
        guard bin || hex else {
            throw DFUFirmwareError(type: .binOrHex)
        }
        
        if let datUrl = urlToDatFile {
            let datExt = datUrl.pathExtension
            guard datExt.caseInsensitiveCompare("dat") == .orderedSame else {
                throw DFUFirmwareError(type: .dat)
            }
        }
        
        if bin {
            stream = try DFUStreamBin(urlToBinFile: urlToBinOrHexFile,
                                      urlToDatFile: urlToDatFile, type: type)
        } else {
            stream = try DFUStreamHex(urlToHexFile: urlToBinOrHexFile,
                                      urlToDatFile: urlToDatFile, type: type)
        }
        super.init()
    }
    
    /**
     Creates the DFU Firmware object from a BIN data. 
     
     Setting the DAT file with an Init packet is optional, but may be required by the
     bootloader (SDK 7.0.0+).
     
     - parameters:
       - binFile: Content of the new firmware as BIN.
       - datFile: An optional DAT file data with the Init packet.
       - type: The type of the firmware.
     
     - returns: The DFU firmware object or `nil` in case of an error.
     */
    @objc public init(binFile: Data, datFile: Data?, type: DFUFirmwareType) {
        fileUrl = nil
        fileName = nil
        stream = DFUStreamBin(binFile: binFile, datFile: datFile, type: type)
        super.init()
    }
    
    /**
     Creates the DFU Firmware object from a HEX data.
     
     Setting the DAT file with an Init packet is optional, but may be required by the 
     bootloader (SDK 7.0.0+).
     
     - parameters:
       - hexFile: Content of the HEX file containing new firmware.
       - datFile: An optional DAT file data with the Init packet.
       - type:The type of the firmware.
     
     - returns: The DFU firmware object or `nil` in case of an error.
     - throws: `DFUStreamHexError` if the hex file is invalid.
     */
    @objc public init(hexFile: Data, datFile: Data?, type: DFUFirmwareType) throws {
        fileUrl = nil
        fileName = nil
        stream = try DFUStreamHex(hexFile: hexFile, datFile: datFile, type: type)
        super.init()
    }
    
    internal var data: Data {
        return stream.data as Data
    }
    
    internal var initPacket: Data? {
        return stream.initPacket as Data?
    }
    
    internal func hasNextPart() -> Bool {
        return stream.hasNextPart()
    }
    
    internal func switchToNextPart() {
        stream.switchToNextPart()
    }
}
