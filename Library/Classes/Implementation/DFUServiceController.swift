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

import CoreBluetooth

/**
 The controller allows pausing, resuming or aborting the ongoing DFU operation.
 
 Use of the controller is optional. An application does not have to allow users to do any of the actions.
 */
@objc public class DFUServiceController : NSObject {

    internal var executor: BaseExecutorAPI?
    
    private var servicePaused  = false
    private var serviceAborted = false
    
    internal override init() {
        // Empty internal constructor
    }
    
    /**
     Call this method to pause uploading during the transmission process.
     
     The transmission can be resumed only when connection remains. If service
     has already started sending firmware data it will pause after receiving
     next Packet Receipt Notification. Otherwise it will continue to send
     Op Codes and pause before sending the first bytes of the firmware. With
     Packet Receipt Notifications disabled it is the only moment when upload
     may be paused.
     */
    @objc public func pause() {
        guard let executor = executor, !servicePaused, !serviceAborted else { return }
        if executor.pause() {
            servicePaused = true
        }
    }
    
    /**
     Call this method to resume the paused transfer, otherwise does nothing.
     */
    @objc public func resume() {
        guard let executor = executor, servicePaused, !serviceAborted else { return }
        if executor.resume() {
            servicePaused = false
        }
    }
    
    /**
     Aborts the upload. 
     
     As a result, the phone will disconnect from peripheral. The peripheral
     will try to recover the last firmware. Had the application been removed, the device
     will restart in the DFU bootloader mode.
     
     Aborting DFU does not cancel pending connection attempt. It is only when the service
     is sending firmware or an Op Code that the operation can be stopped.
     
     - returns: `True` if DFU has been aborted; `false` otherwise.
     */
    @objc public func abort() -> Bool {
        guard let executor = executor, !serviceAborted else { return serviceAborted }
        serviceAborted = true
        servicePaused = false
        return executor.abort()
    }
    
    /**
     Starts again aborted DFU operation.
     */
    @objc public func restart() {
        guard let executor = executor, serviceAborted else { return }
        serviceAborted = false
        servicePaused = false
        executor.start()
    }
    
    /**
     Returns `true` if DFU operation has been paused.
     */
    @objc public var paused: Bool {
        return servicePaused
    }
    
    /**
     Returns `true` if DFU operation has been aborted.
     */
    @objc public var aborted: Bool {
        return serviceAborted
    }
}
