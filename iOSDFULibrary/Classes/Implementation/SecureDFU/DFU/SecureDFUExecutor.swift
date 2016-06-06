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

internal class SecureDFUExecutor : SecureDFUPeripheralDelegate {
    /// The DFU Service Initiator instance that was used to start the service.
    private let initiator:SecureDFUServiceInitiator
    
    /// The service delegate will be informed about status changes and errors.
    private var delegate:SecureDFUServiceDelegate? {
        // The delegate may change during DFU operation (setting a new one in the initiator). Let's allways use the current one.
        return initiator.delegate
    }
    
    /// The progress delegate will be informed about current upload progress.
    private var progressDelegate:SecureDFUProgressDelegate? {
        // The delegate may change during DFU operation (setting a new one in the initiator). Let's allways use the current one.
        return initiator.progressDelegate
    }
    
    /// The DFU Target peripheral. The peripheral keeps the cyclic reference to the DFUExecutor preventing both from being disposed before DFU ends.
    private var peripheral:SecureDFUPeripheral
    /// The firmware to be sent over-the-air
    private var firmware:DFUFirmware
    
    private var error:(error:SecureDFUError, message:String)?
    
    // MARK: - Initialization
    
    init(_ initiator:SecureDFUServiceInitiator) {
        self.initiator = initiator
        self.firmware = initiator.file!
        self.peripheral = SecureDFUPeripheral(initiator)
    }
    
    // MARK: - DFU Controller methods
    
    func start() {
        self.error = nil
        dispatch_async(dispatch_get_main_queue(), {
            self.delegate?.didStateChangedTo(SecureDFUState.Connecting)
        })
        peripheral.delegate = self
        peripheral.connect()
    }
    
    func pause() -> Bool {
        return peripheral.pause()
    }
    
    func resume() -> Bool {
        return peripheral.resume()
    }
    
    func abort() {
        peripheral.abort()
    }
    
    // MARK: - Secure DFU Peripheral Delegate methods
    func onDeviceReady() {

    }

    func onControlPointEnabled() {
        
    }

    func onObjectReadCompleted(var maxLen : UInt32, offset : UInt32, crc :UInt32 ) {
        
    }
    
    func didDeviceFailToConnect() {
        
    }
    
    func peripheralDisconnected() {
        
    }
    
    func peripheralDisconnected(withError anError : NSError) {
        
    }
    
    func onErrorOccured(withError anError:SecureDFUError, andMessage aMessage:String) {
        
    }
}
