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

class nRF51TestSet: DFUTestSet {
    
    // Firmwares used for testing DFU on nRF51 DK
    var steps: [(firmware: DFUFirmware, options: ServiceModifier?, expectedError: DFUError?, description: String, next: Filter?)]? {
        return try? [
            // Try to update SDK 12.2, but with experimental buttonless service disabled (default)
            (DFUFirmware.from(zip: "nrf51422_sdk_12.2_app",         locatedIn:  "Firmwares/nRF51"),
             nil, DFUError.deviceNotSupported, "Testing experimental buttonless service", FilterBy.name("DFU1A122")),
            // Do the same, but by with this service enabled
            (DFUFirmware.from(zip: "nrf51422_sdk_12.2_app",         locatedIn:  "Firmwares/nRF51"),
             Option.experimentalButtonlessEnabled, nil, "Updating app from SDK 12.2",      FilterBy.name("DFU1A122")),
            // Try downgrading to SDK 8. This should fail as a) Secure DFU packet is required, b) required SD ID is invalid
            (DFUFirmware.from(zip: "nrf51422_sdk_8_app",            locatedIn:  "Firmwares/nRF51"),
             Option.experimentalButtonlessEnabled, DFUError.remoteSecureDFUInvalidObject,
             "Updating app from SDK 8", FilterBy.name("DFU1B122")), // Name with B, as the device was switched to Bootloader mode
            // Continue with testing:
            (DFUFirmware.from(zip: "nrf51422_sdk_11_sd_bl",         locatedIn:  "Firmwares/nRF51"), nil, nil, "Downgrading to SDK 11 (SD only)", FilterBy.name("DFU1B11")),
            (DFUFirmware.from(zip: "nrf51422_sdk_11_app",           locatedIn:  "Firmwares/nRF51"), Option.prn(4), nil, "Flashing app from SDK 11 with PRN set to 4", FilterBy.name("DFU1A11")),
            (DFUFirmware.from(zip: "nrf51422_sdk_11_all_in_one",    locatedIn:  "Firmwares/nRF51"), nil, nil, "Updating SD+BL+App from SDK 11",  FilterBy.name("DFU1A11")),
            (DFUFirmware.from(zip: "nrf51422_sdk_8_all_in_one",     locatedIn:  "Firmwares/nRF51"), nil, nil, "Downgrading to SDK 8",            FilterBy.name("DFU1A08")),
            (DFUFirmware.from(zip: "nrf51422_sdk_8_app",            locatedIn:  "Firmwares/nRF51"), nil, nil, "Updating app from SDK 8",         FilterBy.name("DFU1A08")),
            (DFUFirmware.from(zip: "nrf51422_sdk_6.1_all_in_one",   locatedIn:  "Firmwares/nRF51"), nil, nil, "Downgrading to SDK 6.1",          FilterBy.name("DFU1A061")),
            (DFUFirmware.from(zip: "nrf51422_sdk_6.1_app",          locatedIn:  "Firmwares/nRF51"), nil, nil, "Updating app from SDK 6.1",       FilterBy.name("DFU1A061")),
            // For the 2nd part of the following update PRNs will be enabled and set to 1.
            // Additionally, a 2000 ms delay before sending the firmware is added.
            // Flash operation in DFU bootloader was too slow to support full upload speed.
            (DFUFirmware.from(zip: "nrf51422_sdk_6.0_all_in_one",   locatedIn:  "Firmwares/nRF51"), nil, nil, "Downgrading to SDK 6",            nil)
            // App from SDK 6.0 does not have Buttonless jump service. No further update is possible.
        ]
    }
    
    static var requiredName: String {
        return "DFU1A122"
    }
}
