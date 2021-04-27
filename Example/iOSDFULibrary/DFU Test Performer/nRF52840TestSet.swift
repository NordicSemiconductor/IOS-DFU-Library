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

class nRF52840TestSet: DFUTestSet {
    
    // Firmwares used for testing DFU on nRF52840 DK.
    var steps: [(firmware: DFUFirmware, options: ServiceModifier?, expectedError: DFUError?, description: String, next: Filter?)]? {
        return try? [
            // The MBR in nrf52840_sdk_13_all_in_one.hex has been replaced with 2.3.0 version (MBR from SD s140 6.0.0).
            // The original one (2.1.0) had a bug preventing writing in Bootloader space, so the Bootloader was not updatable.
            // This is not something a customer would do, but with this trick it is possible to test DFU on older SDKs.
            
            // Files with 'bl' must be uploaded in the correct order, as each next version must have bl_version greater then the last one.
            (DFUFirmware.from(zip: "nrf52840_sdk_13_app"               , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating app",          FilterBy.name("DFU3A13")),
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
            (DFUFirmware.from(zip: "nrf52840_sdk_15.2_sd_bl_app_3"     , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD+BL+App",    FilterBy.name("DFU3A152")),
            
            // Updating to SDK 15.3.
            (DFUFirmware.from(zip: "nrf52840_sdk_15.2_to_15.3_all_in_one",locatedIn: "Firmwares/nRF52840"), nil, nil, "Upgrading to SDK 15.3", FilterBy.name("DFU3A153")),
            (DFUFirmware.from(zip: "nrf52840_sdk_15.3_app"             , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating app",          FilterBy.name("DFU3A153")),
            // The following steps may be removed without any harm if more SDKs are added.
            (DFUFirmware.from(zip: "nrf52840_sdk_15.3_sd"              , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD only",      FilterBy.name("DFU3A153")),
            (DFUFirmware.from(zip: "nrf52840_sdk_15.3_sd_bl_1"         , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD+BL",        FilterBy.name("DFU3A153")),
            (DFUFirmware.from(zip: "nrf52840_sdk_15.3_bl_2"            , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating BL only",      FilterBy.name("DFU3A153")),
            (DFUFirmware.from(zip: "nrf52840_sdk_15.3_sd_bl_app_3"     , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD+BL+App",    FilterBy.name("DFU3A153")),
            
            // Updating to SDK 16.
            (DFUFirmware.from(zip: "nrf52840_sdk_15.3_to_16_all_in_one", locatedIn:  "Firmwares/nRF52840"), nil, nil, "Upgrading to SDK 16",   FilterBy.name("DFU3A16")),
            (DFUFirmware.from(zip: "nrf52840_sdk_16_app"               , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating app",          FilterBy.name("DFU3A16")),
            // The following steps may be removed without any harm if more SDKs are added.
            (DFUFirmware.from(zip: "nrf52840_sdk_16_sd"                , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD only",      FilterBy.name("DFU3A16")),
            (DFUFirmware.from(zip: "nrf52840_sdk_16_sd_bl_1"           , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD+BL",        FilterBy.name("DFU3A16")),
            (DFUFirmware.from(zip: "nrf52840_sdk_16_bl_2"              , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating BL only",      FilterBy.name("DFU3A16")),
            (DFUFirmware.from(zip: "nrf52840_sdk_16_sd_bl_app_3"       , locatedIn:  "Firmwares/nRF52840"), nil, nil, "Updating SD+BL+App",    nil),
            
        ]
    }
    
    static var requiredName: String {
        return "DFU3A13"
    }
}

