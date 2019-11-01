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
import iOSDFULibrary
import CoreBluetooth

enum DFUTestError : Error {
    case fileNotFound
    case invalidFirmware
}

typealias AdvertisingData = [String : Any]
typealias Filter = (AdvertisingData) -> Bool
typealias ServiceModifier = (DFUServiceInitiator) -> ()

protocol DFUTestSet {
    /**
     The list contains number of tripples:
     [0] firmware to be sent in this step,
     [1] DfuServiceInitiator modifier,
     [2] step description to show on the screen,
     [3] optional expected error, in case the test is expected to fail,
     [4] filter method to be used to find the next target. The first map is the advertisement data.
     The last step returns nil as 'next'.
     */
    var steps: [(firmware: DFUFirmware, options: ServiceModifier?, expectedError: DFUError?, description: String, next: Filter?)]? { get }
}

extension DFUTestSet {
    
    var totalParts: Int {
        guard let steps = steps else {
            return 0
        }
        
        var i = 0
        for step in steps {
            i += step.firmware.parts
        }
        return i
    }
}

class FilterBy {
    
    static func name(_ name: String) -> Filter? {
        return {
            (advertisementData: AdvertisingData) -> Bool in
            return advertisementData[CBAdvertisementDataLocalNameKey] as! String? == name
        }
    }
    
}

class Option {
    
    static let prn : (UInt16) -> ServiceModifier = {
        aPRNValue in
        return {
            initiator in initiator.packetReceiptNotificationParameter = aPRNValue
        }
    }
    
    static let experimentalButtonlessEnabled : ServiceModifier = {
        initiator in initiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = true
    }
}

extension DFUFirmware {
    
    private static func from(urlToZipFile url: URL?, type: DFUFirmwareType) throws -> DFUFirmware {
        guard url != nil else {
            throw DFUTestError.fileNotFound
        }
        let firmware = DFUFirmware(urlToZipFile: url!, type: type)
        guard firmware != nil else {
            throw DFUTestError.invalidFirmware
        }
        return firmware!
    }
    
    static func from(zip name: String, locatedIn subdirectory: String) throws -> DFUFirmware {
        let url = Bundle.main.url(forResource: name, withExtension: "zip", subdirectory: subdirectory)
        return try DFUFirmware.from(urlToZipFile: url, type: .softdeviceBootloaderApplication)
    }
    
    static func from(zip name: String, locatedIn subdirectory: String, withType type: DFUFirmwareType) throws -> DFUFirmware {
        let url = Bundle.main.url(forResource: name, withExtension: "zip", subdirectory: subdirectory)
        return try DFUFirmware.from(urlToZipFile: url, type: type)
    }
    
    static func fromCustomZip() throws -> DFUFirmware {
        let urls = Bundle.main.urls(forResourcesWithExtension: "zip", subdirectory: "Firmwares/Custom")
        return try DFUFirmware.from(urlToZipFile: urls?.first, type: .softdeviceBootloaderApplication)
    }
    
}
