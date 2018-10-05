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
            // The MBR in nrf52840_sdk_13_all_in_one.hex has been replaced with 2.3.0 version (MBR from SD s140 6.0.0).
            // The original one (2.1.0) had a bug preventing writing in Bootloader space, so the Bootloader was not updatable.
            // This is not something a customer would do, but with this trick it is possible to test DFU on older SDKs.
            
            // Files with 'bl' must be uploaded in the correct order, as each next version mu must have bl_version greater then the last one.
            
            (DFUFirmware.from(zip: "nrf52840_sdk_13_app"               , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating app from SDK 13", FilterBy.name("DFU3A13")),
            // The following steps may be removed without any harm if more SDKs are added.
            (DFUFirmware.from(zip: "nrf52840_sdk_13_sd"                , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD only",      FilterBy.name("DFU3A13")),
            (DFUFirmware.from(zip: "nrf52840_sdk_13_sd_bl_1"           , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD+BL",        FilterBy.name("DFU3A13")),
            (DFUFirmware.from(zip: "nrf52840_sdk_13_bl_2"              , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating BL only",      FilterBy.name("DFU3A13")),
            (DFUFirmware.from(zip: "nrf52840_sdk_13_sd_bl_app_3"       , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD+BL+App",    FilterBy.name("DFU3A13")),
            
            // Updating to SDK 14. SDK 14 uses the same SD s140 5.0.0-2.alpha
            (DFUFirmware.from(zip: "nrf52840_sdk_13_to_14_all_in_one"  , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Upgrading to SDK 14",   FilterBy.name("DFU3A14")),
            (DFUFirmware.from(zip: "nrf52840_sdk_14_app"               , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating app",          FilterBy.name("DFU3A14")),
            // The following steps may be removed without any harm if more SDKs are added.
            (DFUFirmware.from(zip: "nrf52840_sdk_14_sd"                , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD only",      FilterBy.name("DFU3A14")),
            (DFUFirmware.from(zip: "nrf52840_sdk_14_sd_bl_1"           , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD+BL",        FilterBy.name("DFU3A14")),
            (DFUFirmware.from(zip: "nrf52840_sdk_14_bl_2"              , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating BL only",      FilterBy.name("DFU3A14")),
            (DFUFirmware.from(zip: "nrf52840_sdk_14_sd_bl_app_3"       , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD+BL+App",    FilterBy.name("DFU3A14")),
            
            // Updating to SDK 14.1. SDK 14.1 uses the same SD s140 5.0.0-2.alpha
            (DFUFirmware.from(zip: "nrf52840_sdk_14_to_14.1_all_in_one", locatedIn:  "Firmwares/nRF52840"), nil, nil, "Upgrading to SDK 14.1", FilterBy.name("DFU3A141")),
            (DFUFirmware.from(zip: "nrf52840_sdk_14.1_app"             , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating app",          FilterBy.name("DFU3A141")),
            // The following steps may be removed without any harm if more SDKs are added.
            (DFUFirmware.from(zip: "nrf52840_sdk_14.1_sd"              , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD only",      FilterBy.name("DFU3A141")),
            (DFUFirmware.from(zip: "nrf52840_sdk_14.1_sd_bl_1"         , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD+BL",        FilterBy.name("DFU3A141")),
            (DFUFirmware.from(zip: "nrf52840_sdk_14.1_bl_2"            , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating BL only",      FilterBy.name("DFU3A141")),
            (DFUFirmware.from(zip: "nrf52840_sdk_14.1_sd_bl_app_3"     , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD+BL+App",    FilterBy.name("DFU3A141")),
            
            // Updating to SDK 15.
            (DFUFirmware.from(zip: "nrf52840_sdk_14.1_to_15_all_in_one", locatedIn:  "Firmwares/nRF52840"), nil, nil, "Upgrading to SDK 15",   FilterBy.name("DFU3A15")),
            (DFUFirmware.from(zip: "nrf52840_sdk_15_app"               , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating app",          FilterBy.name("DFU3A15")),
            // The following steps may be removed without any harm if more SDKs are added.
            (DFUFirmware.from(zip: "nrf52840_sdk_15_sd"                , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD only",      FilterBy.name("DFU3A15")),
            (DFUFirmware.from(zip: "nrf52840_sdk_15_sd_bl_1"           , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD+BL",        FilterBy.name("DFU3A15")),
            (DFUFirmware.from(zip: "nrf52840_sdk_15_bl_2"              , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating BL only",      FilterBy.name("DFU3A15")),
            (DFUFirmware.from(zip: "nrf52840_sdk_15_sd_bl_app_3"       , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD+BL+App",    FilterBy.name("DFU3A15")),
            
            // Updating to SDK 15.2.
            (DFUFirmware.from(zip: "nrf52840_sdk_15_to_15.2_all_in_one", locatedIn:  "Firmwares/nRF52840"), nil, nil, "Upgrading to SDK 15.2", FilterBy.name("DFU3A152")),
            (DFUFirmware.from(zip: "nrf52840_sdk_15.2_app"             , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating app",          FilterBy.name("DFU3A152")),
            // The following steps may be removed without any harm if more SDKs are added.
            (DFUFirmware.from(zip: "nrf52840_sdk_15.2_sd"              , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD only",      FilterBy.name("DFU3A152")),
            (DFUFirmware.from(zip: "nrf52840_sdk_15.2_sd_bl_1"         , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD+BL",        FilterBy.name("DFU3A152")),
            (DFUFirmware.from(zip: "nrf52840_sdk_15.2_bl_2"            , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating BL only",      FilterBy.name("DFU3A152")),
            (DFUFirmware.from(zip: "nrf52840_sdk_15.2_sd_bl_app_3"     , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD+BL+App",    nil),
            
        ]
    }
    
    static var requiredName: String {
        return "DFU3A13"
    }
}

