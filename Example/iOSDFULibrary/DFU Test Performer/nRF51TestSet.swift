//
//  nRF51TestSet.swift
//  iOSDFULibrary_Example
//
//  Created by Aleksander Nowakowski on 06/02/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import iOSDFULibrary

class nRF51TestSet: DFUTestSet {
    
    // Firmwares used for testing DFU on nRF51 DK
    var steps: [(firmware: DFUFirmware, description: String, next: Filter?)]? {
        return try? [
            (DFUFirmware.from(zip: "nrf51422_sdk_12.2_app",         locatedIn:  "Firmwares/nRF51"), "Updating app from SDK 12.2",      FilterBy.name("DFU1A122")),
            (DFUFirmware.from(zip: "nrf51422_sdk_11_sd_bl",         locatedIn:  "Firmwares/nRF51"), "Downgrading to SDK 11 (SD only)", FilterBy.name("DFU1B11")),
            (DFUFirmware.from(zip: "nrf51422_sdk_11_app",           locatedIn:  "Firmwares/nRF51"), "Flashing app from SDK 11",        FilterBy.name("DFU1A11")),
            (DFUFirmware.from(zip: "nrf51422_sdk_11_all_in_one",    locatedIn:  "Firmwares/nRF51"), "Updating SD+BL+App from SDK 11",  FilterBy.name("DFU1A11")),
            (DFUFirmware.from(zip: "nrf51422_sdk_8_all_in_one",     locatedIn:  "Firmwares/nRF51"), "Downgrading to SDK 8",            FilterBy.name("DFU1A08")),
            (DFUFirmware.from(zip: "nrf51422_sdk_8_app",            locatedIn:  "Firmwares/nRF51"), "Updating app from SDK 8",         FilterBy.name("DFU1A08")),
            (DFUFirmware.from(zip: "nrf51422_sdk_6.1_all_in_one",   locatedIn:  "Firmwares/nRF51"), "Downgrading to SDK 6.1",          FilterBy.name("DFU1A061")),
            (DFUFirmware.from(zip: "nrf51422_sdk_6.1_app",          locatedIn:  "Firmwares/nRF51"), "Updating app from SDK 6.1",       FilterBy.name("DFU1A061")),
            // For the 2nd part of the following update PRNs must be enabled. Flash operation in DFU bootloader was too slow to support full upload speed.
            (DFUFirmware.from(zip: "nrf51422_sdk_6.0_all_in_one",   locatedIn:  "Firmwares/nRF51"), "Downgrading to SDK 6",            nil)
            // App from SDK 6.0 does not have Buttonless jump service. No further update is possible.
        ]
    }
    
    static var requiredName: String {
        return "DFU1A122"
    }
}
