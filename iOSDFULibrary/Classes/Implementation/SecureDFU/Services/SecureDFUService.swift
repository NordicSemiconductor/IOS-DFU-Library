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

internal typealias SDFUCallback = Void -> Void
internal typealias SDFUErrorCallback = (error:SecureDFUError, withMessage:String) -> Void

@objc internal class SecureDFUService : NSObject, CBPeripheralDelegate {
    static internal let UUID = CBUUID.init(string: "00001530-1212-EFDE-1523-785FEABCD123")
    
    static func matches(service:CBService) -> Bool {
        return service.UUID.isEqual(UUID)
    }
    
    /// The logger helper.
    private var logger:LoggerHelper
    /// The service object from CoreBluetooth used to initialize the SecureDFUService instance.
    private let service:CBService
    private var dfuPacketCharacteristic:SecureDFUPacket?
    private var dfuControlPointCharacteristic:SecureDFUControlPoint?

    private var paused = false
    private var aborted = false
    
    /// A temporary callback used to report end of an operation.
    private var success:SDFUCallback?
    /// A temporary callback used to report an operation error.
    private var report:SDFUErrorCallback?
    /// A temporaty callback used to report progress status.
    private var progressDelegate:SecureDFUProgressDelegate?
    
    // -- Properties stored when upload started in order to resume it --
    private var firmware:DFUFirmware?
    private var packetReceiptNotificationNumber:UInt16?
    // -- End --
    
    // MARK: - Initialization
    
    init(_ service:CBService, _ logger:LoggerHelper) {
        self.service = service
        self.logger = logger
        super.init()
    }
    
    // MARK: - Service API methods
    
    /**
    Discovers characteristics in the DFU Service.
    */
    func discoverCharacteristics(onSuccess success: SDFUCallback, onError report:SDFUErrorCallback) {
        // Save callbacks
        self.success = success
        self.report = report
        
        // Get the peripheral object
        let peripheral = service.peripheral
        
        // Set the peripheral delegate to self
        peripheral.delegate = self
        
        // Discover DFU characteristics
        logger.v("Discovering characteristics in DFU Service...")
        logger.d("peripheral.discoverCharacteristics(nil, forService:DFUService)")
        peripheral.discoverCharacteristics(nil, forService:service)
    }
    
    /**
     This method tries to estimate whether the DFU target device is in Application mode which supports
     the buttonless jump to the DFU Bootloader.
     
     - returns: true, if it is for sure in the Application more, false, if definitely is not, nil if uknown
     */
    func isInApplicationMode() -> Bool? {        
        // The mbed implementation of DFU does not have DFU Packet characteristic in application mode
        if dfuPacketCharacteristic == nil {
            return true
        }
        
        // At last, count services. When only one service found - the DFU Service - we must be in the DFU mode already
        // (otherwise the device would be useless...)
        // Note: On iOS the Generic Access and Generic Attribute services (nor HID Service)
        //       are not returned during service discovery.
        let services = service.peripheral.services!
        if services.count == 1 {
            return false
        }
        // If there are more services than just DFU Service, the state is uncertain
        return nil
    }
    
    /**
     Enables notifications for DFU Control Point characteristic. Result it reported using callbacks.
     
     - parameter success: method called when notifications were enabled without a problem
     - parameter report:  method called when an error occurred
     */
    func enableControlPoint(onSuccess success: SDFUCallback, onError report:SDFUErrorCallback) {
        if !aborted {
            dfuControlPointCharacteristic?.enableNotifications(onSuccess: success, onError: report)
        } else {
            //TODO: Not implemented
//            sendReset(onError: report)
        }
    }
    
    func pause() {
        if !aborted {
            paused = true
        }
    }
    
    func resume() {
//        if !aborted && paused && firmware != nil {
//            paused = false
//            // onSuccess and onError callbacks are still kept by dfuControlPointCharacteristic
//            dfuPacketCharacteristic!.sendNext(packetReceiptNotificationNumber!, packetsOf: firmware!, andReportProgressTo: progressDelegate)
//        }
//        paused = false
    }
    
    func abort() {
//        aborted = true
//        // When upload has been started and paused, we have to send the Reset command here as the device will 
//        // not get a Packet Receipt Notification. If it hasn't been paused, the Reset command will be sent after receiving it, on line 270.
//        if paused && firmware != nil {
//            // Upload has been aborted. Reset the target device. It will disconnect automatically
//            sendReset(onError: report!)
//        }
//        paused = false
    }
    
    // MARK: - Peripheral Delegate callbacks
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        // Create local references to callback to release the global ones
        let _success = self.success
        let _report = self.report
        self.success = nil
        self.report = nil
        
        if error != nil {
            logger.e("Characteristics discovery failed")
            logger.e(error!)
            _report?(error: SecureDFUError.ServiceDiscoveryFailed, withMessage: "Characteristics discovery failed")
        } else {
            logger.i("DFU characteristics discovered")
            
            // Find DFU characteristics
            for characteristic in service.characteristics! {
                if (DFUPacket.matches(characteristic)) {
                    dfuPacketCharacteristic = SecureDFUPacket(characteristic, logger)
                } else if (DFUControlPoint.matches(characteristic)) {
                    dfuControlPointCharacteristic = SecureDFUControlPoint(characteristic, logger)
                }
            }
            
            // Some validation
            if dfuControlPointCharacteristic == nil {
                logger.e("DFU Control Point characteristics not found")
                // DFU Control Point characteristic is required
                _report?(error: SecureDFUError.DeviceNotSupported, withMessage: "DFU Control Point characteristic not found")
                return
            }
            if !dfuControlPointCharacteristic!.valid {
                logger.e("DFU Control Point characteristics must have Write and Notify properties")
                // DFU Control Point characteristic must have Write and Notify properties
                _report?(error: SecureDFUError.DeviceNotSupported, withMessage: "DFU Control Point characteristic does not have the Write and Notify properties")
                return
            }
            
            // Note: DFU Packet characteristic is not required in the App mode.
            //       The mbed implementation of DFU Service doesn't have such.
            _success?()
        }
    }
}