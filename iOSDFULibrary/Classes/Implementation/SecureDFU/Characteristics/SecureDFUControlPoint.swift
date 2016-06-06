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

internal typealias SecureDFUProgressCallback = (bytesReceived:Int) -> Void

@available(iOS, introduced=0.1.9)
internal enum SecureDFUOpCode : UInt8 {
    case StartDfu                           = 1
    case InitDfuParameters                  = 2
    case ReceiveFirmwareImage               = 3
    case ValidateFirmware                   = 4
    case ActivateAndReset                   = 5
    case Reset                              = 6
    case ReportReceivedImageSize            = 7 // unused in this library
    case PacketReceiptNotificationRequest   = 8
    case ResponseCode                       = 16
    case PacketReceiptNotification          = 17
    
    var code:UInt8 {
        return rawValue
    }
}

internal enum SecureDFURequest {
}

internal enum SecureDFUResultCode : UInt8 {
    case Success              = 1
    case InvalidState         = 2
    case NotSupported         = 3
    case DataSizeExceedsLimit = 4
    case CRCError             = 5
    case OperationFailed      = 6
    
    var description:String {
        switch self {
        case .Success: return "Success"
        case .InvalidState: return "Device is in invalid state"
        case .NotSupported: return "Operation not supported"
        case .DataSizeExceedsLimit:  return "Data size exceeds limit"
        case .CRCError: return "CRC Error"
        case .OperationFailed: return "Operation failed"
        }
    }
    
    var code:UInt8 {
        return rawValue
    }
}

internal struct SecureDFUResponse {
    let opCode:OpCode?
    let requestOpCode:OpCode?
    let status:StatusCode?
    
    init?(_ data:NSData) {
        var opCode:UInt8 = 0
        var requestOpCode:UInt8 = 0
        var status:UInt8 = 0
        data.getBytes(&opCode, range: NSRange(location: 0, length: 1))
        data.getBytes(&requestOpCode, range: NSRange(location: 1, length: 1))
        data.getBytes(&status, range: NSRange(location: 2, length: 1))
        self.opCode = OpCode(rawValue: opCode)
        self.requestOpCode = OpCode(rawValue: requestOpCode)
        self.status = StatusCode(rawValue: status)
        
        if self.opCode != OpCode.ResponseCode || self.requestOpCode == nil || self.status == nil {
            return nil
        }
    }
    
    var description:String {
        return "Response (Op Code = \(requestOpCode!.rawValue), Status = \(status!.rawValue))"
    }
}

internal struct SecureDFUPacketReceiptNotification {
    let opCode:SecureDFUOpCode?
    let bytesReceived:Int
    
    init?(_ data:NSData) {
        var opCode:UInt8 = 0
        data.getBytes(&opCode, range: NSRange(location: 0, length: 1))
        self.opCode = SecureDFUOpCode(rawValue: opCode)
        
        if self.opCode != SecureDFUOpCode.PacketReceiptNotification {
            return nil
        }
        
        var bytesReceived:UInt32 = 0
        data.getBytes(&bytesReceived, range: NSRange(location: 1, length: 4))
        self.bytesReceived = Int(bytesReceived)
    }
}

internal class SecureDFUControlPoint : NSObject, CBPeripheralDelegate {
    static let UUID = CBUUID(string: "00001531-1212-EFDE-1523-785FEABCD123")
    
    static func matches(characteristic:CBCharacteristic) -> Bool {
        return characteristic.UUID.isEqual(UUID)
    }
    
    private var characteristic:CBCharacteristic
    private var logger:LoggerHelper
    
    private var success:SDFUCallback?
    private var proceed:SecureDFUProgressCallback?
    private var report:SDFUErrorCallback?
    private var request:SecureDFURequest?
    private var uploadStartTime:CFAbsoluteTime?
    
    var valid:Bool {
        return characteristic.properties.isSupersetOf([CBCharacteristicProperties.Write, CBCharacteristicProperties.Notify])
    }
    
    // MARK: - Initialization
    init(_ characteristic:CBCharacteristic, _ logger:LoggerHelper) {
        self.characteristic = characteristic
        self.logger = logger
    }
    
    // MARK: - Characteristic API methods
    
    /**
    Enables notifications for the DFU ControlPoint characteristics. Reports success or an error 
    using callbacks.
    
    - parameter success: method called when notifications were successfully enabled
    - parameter report:  method called in case of an error
    */
    func enableNotifications(onSuccess success:SDFUCallback?, onError report:SDFUErrorCallback?) {
        // Save callbacks
        self.success = success
        self.report = report
        
        // Get the peripheral object
        let peripheral = characteristic.service.peripheral
        
        // Set the peripheral delegate to self
        peripheral.delegate = self
        
        logger.v("Enabling notifiactions for \(DFUControlPoint.UUID.UUIDString)...")
        logger.d("peripheral.setNotifyValue(true, forCharacteristic: \(DFUControlPoint.UUID.UUIDString))")
        peripheral.setNotifyValue(true, forCharacteristic: characteristic)
    }

    func send(request:SecureDFURequest, onSuccess success:SDFUCallback?, onError report:SDFUErrorCallback?) {
        // Save callbacks and parameter
        self.success = success
        self.report = report
        self.request = request
//        
//        // Get the peripheral object
//        let peripheral = characteristic.service.peripheral
//        
//        // Set the peripheral delegate to self
//        peripheral.delegate = self
//        
//        switch request {
//        case .InitDfuParameters(let req):
//            if req == InitDfuParametersRequest.ReceiveInitPacket {
//                logger.a("Writing \(request.description)...")
//            }
//        case .InitDfuParameters_v1:
//            logger.a("Writing \(request.description)...")
//        case .JumpToBootloader, .ActivateAndReset, .Reset:
//            // Those three requests may not be confirmed by the remote DFU target. The device may be restarted before sending the ACK.
//            // This would cause an error in peripheral:didWriteValueForCharacteristic:error, which can be ignored in this case.
//            self.resetSent = true
//        default:
//            break
//        }
//        logger.v("Writing to characteristic \(DFUControlPoint.UUID.UUIDString)...")
//        logger.d("peripheral.writeValue(0x\(request.data.hexString), forCharacteristic: \(DFUControlPoint.UUID.UUIDString), type: WithResponse)")
//        peripheral.writeValue(request.data, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
    }
    
    // MARK: - Peripheral Delegate callbacks
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            logger.e("Enabling notifications failed")
            logger.e(error!)
            report?(error:SecureDFUError.EnablingControlPointFailed, withMessage:"Enabling notifications failed")
        } else {
            logger.v("Notifications enabled for \(DFUVersion.UUID.UUIDString)")
            logger.a("DFU Control Point notifications enabled")
            success?()
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
        } else {
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            // This characteristic is never read, the error may only pop up when notification is received
            logger.e("Receiving notification failed")
            logger.e(error!)
            report?(error:SecureDFUError.ReceivingNotificatinoFailed, withMessage:"Receiving notification failed")
        } else {
        }
    }
}
