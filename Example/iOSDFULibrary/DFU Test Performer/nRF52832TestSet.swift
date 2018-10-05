//
//  nRF52832TestSet.swift
//  iOSDFULibrary_Example
//
//  Created by Aleksander Nowakowski on 06/02/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import iOSDFULibrary

class nRF52832TestSet: DFUTestSet {
    
    // Firmwares used for testing DFU on nRF52832 DK
    var steps: [(firmware: DFUFirmware, options: ServiceModifier?, expectedError: DFUError?, description: String, next: Filter?)]? {
        return try? [
            // Files with 'bl' must be uploaded in the correct order, as each next version mu must have bl_version greater then the last one.
            
            // Update from SDK 11 to 12.x is not working despite the 11th BL was compiled to match the start address of Secure DFU.
            // New BL erases some memory from the new SD when started (addresses 0xE000 -> 0xE7F0)
            // Let's start from SDK 12.2 then.
            (DFUFirmware.from(zip: "nrf52832_sdk_12.2_app"             , locatedIn:  "Firmwares/nRF52832"),
             Option.experimentalButtonlessEnabled, nil, "Flashing app from SDK 12.2", FilterBy.name("DFU2A122")),
            (DFUFirmware.from(zip: "nrf52832_sdk_12.2_to_13_all_in_one", locatedIn:  "Firmwares/nRF52832"),
             Option.experimentalButtonlessEnabled, nil, "Upgrading to SDK 13",        FilterBy.name("DFU2A13")),
            (DFUFirmware.from(zip: "nrf52832_sdk_13_app"               , locatedIn:  "Firmwares/nRF52832"), nil, nil, "Updating app from SDK 13", FilterBy.name("DFU2A13")),
            // In SDK 14 there was a bug releated to SD size. As SD size increased from pre-14 to 14 it is not possible to update without a fix that was added in SDK 14.1.
            // Here we can just skip this version and upgrade directly to 14.1.
            (DFUFirmware.from(zip: "nrf52832_sdk_13_to_14.1_all_in_one", locatedIn:  "Firmwares/nRF52832"), nil, nil, "Upgrading to SDK 14.1", FilterBy.name("DFU2A141")),
            (DFUFirmware.from(zip: "nrf52832_sdk_14.1_app"             , locatedIn:  "Firmwares/nRF52832"), nil, nil, "Updating app",          FilterBy.name("DFU2A141")),
            // The following steps may be removed without any harm if more SDKs are added.
            (DFUFirmware.from(zip: "nrf52832_sdk_14.1_sd"              , locatedIn:  "Firmwares/nRF52832"), nil, nil, "Updating SD only",      FilterBy.name("DFU2A141")),
            (DFUFirmware.from(zip: "nrf52832_sdk_14.1_sd_bl_1"         , locatedIn:  "Firmwares/nRF52832"), nil, nil, "Updating SD+BL",        FilterBy.name("DFU2A141")),
            (DFUFirmware.from(zip: "nrf52832_sdk_14.1_bl_2"            , locatedIn:  "Firmwares/nRF52832"), nil, nil, "Updating BL only",      FilterBy.name("DFU2A141")),
            (DFUFirmware.from(zip: "nrf52832_sdk_14.1_sd_bl_app_3"     , locatedIn:  "Firmwares/nRF52832"), nil, nil, "Updating SD+BL+App",    FilterBy.name("DFU2A141")),
            // Updating to SDK 15.
            (DFUFirmware.from(zip: "nrf52832_sdk_14.1_to_15_all_in_one", locatedIn:  "Firmwares/nRF52832"), nil, nil, "Upgrading to SDK 15",   FilterBy.name("DFU2A15")),
            (DFUFirmware.from(zip: "nrf52832_sdk_15_app"               , locatedIn:  "Firmwares/nRF52832"), nil, nil, "Updating app",          FilterBy.name("DFU2A15")),
            // The following steps may be removed without any harm if more SDKs are added.
            (DFUFirmware.from(zip: "nrf52832_sdk_15_sd"                , locatedIn:  "Firmwares/nRF52832"), nil, nil, "Updating SD only",      FilterBy.name("DFU2A15")),
            (DFUFirmware.from(zip: "nrf52832_sdk_15_sd_bl_1"           , locatedIn:  "Firmwares/nRF52832"), nil, nil, "Updating SD+BL",        FilterBy.name("DFU2A15")),
            (DFUFirmware.from(zip: "nrf52832_sdk_15_bl_2"              , locatedIn:  "Firmwares/nRF52832"), nil, nil, "Updating BL only",      FilterBy.name("DFU2A15")),
            (DFUFirmware.from(zip: "nrf52832_sdk_15_sd_bl_app_3"       , locatedIn:  "Firmwares/nRF52832"), nil, nil, "Updating SD+BL+App",    FilterBy.name("DFU2A15")),
            // Updating to SDK 15.2.
            (DFUFirmware.from(zip: "nrf52832_sdk_15_to_15.2_all_in_one", locatedIn:  "Firmwares/nRF52832"), nil, nil, "Upgrading to SDK 15.2", FilterBy.name("DFU2A152")),
            (DFUFirmware.from(zip: "nrf52832_sdk_15.2_app"             , locatedIn:  "Firmwares/nRF52832"), nil, nil, "Updating app",          FilterBy.name("DFU2A152")),
            // The following steps may be removed without any harm if more SDKs are added.
            (DFUFirmware.from(zip: "nrf52832_sdk_15.2_sd"              , locatedIn:  "Firmwares/nRF52832"), nil, nil, "Updating SD only",      FilterBy.name("DFU2A152")),
            (DFUFirmware.from(zip: "nrf52832_sdk_15.2_sd_bl_1"         , locatedIn:  "Firmwares/nRF52832"), nil, nil, "Updating SD+BL",        FilterBy.name("DFU2A152")),
            (DFUFirmware.from(zip: "nrf52832_sdk_15.2_bl_2"            , locatedIn:  "Firmwares/nRF52832"), nil, nil, "Updating BL only",      FilterBy.name("DFU2A152")),
            (DFUFirmware.from(zip: "nrf52832_sdk_15.2_sd_bl_app_3"     , locatedIn:  "Firmwares/nRF52832"), nil, nil, "Updating SD+BL+App",    nil),
        ]
    }
    
    static var requiredName: String {
        return "DFU2A122"
    }
}
