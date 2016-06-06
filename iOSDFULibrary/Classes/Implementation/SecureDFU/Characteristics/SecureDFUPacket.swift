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

import CoreBluetooth

internal class SecureDFUPacket {
    static private let UUID = CBUUID(string: "00001532-1212-EFDE-1523-785FEABCD123")
    
    static func matches(characteristic:CBCharacteristic) -> Bool {
        return characteristic.UUID.isEqual(UUID)
    }
    
    private let PacketSize = 20
    
    private var characteristic:CBCharacteristic
    private var logger:LoggerHelper
    
    /// Number of bytes of firmware already sent.
    private(set) var bytesSent = 0
    /// Current progress in percents (0-99).
    private var progress = 0
    private var startTime:CFAbsoluteTime?
    private var lastTime:CFAbsoluteTime?
    
    var valid:Bool {
        return characteristic.properties.contains(CBCharacteristicProperties.WriteWithoutResponse)
    }
    
    init(_ characteristic:CBCharacteristic, _ logger:LoggerHelper) {
        self.characteristic = characteristic
        self.logger = logger
    }
    
    // MARK: - Characteristic API methods
}
