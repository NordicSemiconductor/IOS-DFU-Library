//
//  nRF52840TestSet.swift
//  iOSDFULibrary_Example
//
//  Created by Aleksander Nowakowski on 06/02/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import iOSDFULibrary

class nRF52840TestSet: DFUTestSet {
    
    // Firmwares used for testing DFU on nRF52840 DK
    var steps: [(firmware: DFUFirmware, options: ServiceModifier?, expectedError: DFUError?, description: String, next: Filter?)]? {
        return try? [
            // Using SD 5.0.0-alpha.2 it is not possible to update the Bootloader. The MBR prevents writing to the Bootloader region.
            // Bofore SDK 15 is out this test updates only Applications and SD as they all use the same SD.
            // Also, updating buttonless app from SDK 13 to SDK 14 or 14.1 didn't work. DFU completes successfully, but the new app
            // does not start. Let's start from SDK 14 then.
            (DFUFirmware.from(zip: "nrf52840_sdk_14_app"  , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating app from SDK 14",   FilterBy.name("DFU3A14")),
            (DFUFirmware.from(zip: "nrf52840_sdk_14.1_app", locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating app from SDK 14.1", FilterBy.name("DFU3A141")),
            (DFUFirmware.from(zip: "nrf52840_sdk_14.1_sd" , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD only",           FilterBy.name("DFU3A141"))
        ]
    }
    
    static var requiredName: String {
        return "DFU3A14"
    }
}

