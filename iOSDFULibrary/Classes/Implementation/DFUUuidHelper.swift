//
/*
 * Copyright (c) 2016, Nordic Semiconductor
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation
import CoreBluetooth

/// UUID Helper for DFU Process
///
/// The UUID can be modified for each of the DFU types supported by
/// the Nordic devices.  This should be done prior to calling DFUServiceInitiator
@objc public class DFUUuidHelper: NSObject {

    @objc
    public static let shared: DFUUuidHelper = DFUUuidHelper()

    /// UUID for Legacy DFU Service
    @objc
    public var legacyDFUService: CBUUID

    /// UUID for Legacy DFU Control Point Characteristic
    @objc
    public var legacyDFUControlPoint: CBUUID

    /// UUID for Legacy DFU Packet Characteristic
    @objc
    public var legacyDFUPacket: CBUUID

    /// UUID for Legacy DFU Version Characteristic
    @objc
    public var legacyDFUVersion: CBUUID

    /// UUID for Secure DFU Service
    @objc
    public var secureDFUService: CBUUID

    /// UUID for Secure DFU Control Characteristic
    @objc
    public var secureDFUControlPoint: CBUUID

    /// UUID for Secure DFU Packet Characteristic
    @objc
    public var secureDFUPacket: CBUUID

    /// UUID for Buttonless DFU Service
    ///
    /// This UUID is also used for the Characteristic
    @objc
    public var buttolessExperimentalService: CBUUID

    /// UUID for Buttonless DFU Characteristic
    @objc
    public var buttolessExperimentalCharacteristic: CBUUID

    /// UUID for Buttonless DFU Without Bond Sharing Characterisitic
    @objc
    public var buttolessWithoutBonds: CBUUID

    /// UUID for Buttonless DFU With Bond Sharing Characterisitic
    @objc
    public var buttolessWithBonds: CBUUID

    private override init() {

        ///
        /// Legacy DFU
        ///
        self.legacyDFUService = CBUUID(string: "00001530-1212-EFDE-1523-785FEABCD123")
        self.legacyDFUControlPoint = CBUUID(string: "00001531-1212-EFDE-1523-785FEABCD123")
        self.legacyDFUPacket = CBUUID(string: "00001532-1212-EFDE-1523-785FEABCD123")
        self.legacyDFUVersion = CBUUID(string: "00001534-1212-EFDE-1523-785FEABCD123")

        ///
        /// Secure DFU
        ///
        self.secureDFUService = CBUUID(string: "FE59")
        self.secureDFUControlPoint = CBUUID(string: "8EC90001-F315-4F60-9FB8-838830DAEA50")
        self.secureDFUPacket = CBUUID(string: "8EC90002-F315-4F60-9FB8-838830DAEA50")

        ///
        /// Buttonless DFU
        ///
        self.buttolessExperimentalService = CBUUID(string: "8E400001-F315-4F60-9FB8-838830DAEA50")
        // the same UUID as the service by default
        self.buttolessExperimentalCharacteristic = CBUUID(string: "8E400001-F315-4F60-9FB8-838830DAEA50")
        
        self.buttolessWithoutBonds = CBUUID(string: "8EC90003-F315-4F60-9FB8-838830DAEA50")
        self.buttolessWithBonds = CBUUID(string: "8EC90004-F315-4F60-9FB8-838830DAEA50")

        super.init()
    }

}
