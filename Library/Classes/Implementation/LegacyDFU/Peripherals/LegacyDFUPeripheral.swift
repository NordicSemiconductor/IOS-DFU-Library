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

internal class LegacyDFUPeripheral : BaseCommonDFUPeripheral<LegacyDFUExecutor, LegacyDFUService> {
    var slowDfuMode = false
    
    // MARK: - Peripheral API
    
    override var requiredServices: [CBUUID]? {
        return [LegacyDFUService.serviceUuid(from: uuidHelper)]
    }
    
    override func isInitPacketRequired() -> Bool {
        // Init packet has started being required the same time when the DFU Version
        // characteristic was introduced (SDK 7.0.0). It version exists, and we are not
        // in Application mode, then the Init Packet is required.
        
        if let version = dfuService?.version {
            // In the application mode we don't know whether init packet is required
            // as the app is independent from the DFU Bootloader.
            let isInApplicationMode = version.major == 0 && version.minor == 1
            return !isInApplicationMode
        }
        return false
    }
    
    // MARK: - Implementation
    
    /**
     Enables notifications on DFU Control Point characteristic.
     */
    func enableControlPoint() {
        dfuService?.enableControlPoint(
            onSuccess: { [weak self] in self?.delegate?.peripheralDidEnableControlPoint() },
            onError: defaultErrorCallback
        )
    }
    
    override func isInApplicationMode(_ forceDfu: Bool) -> Bool {
        let applicationMode = dfuService?.isInApplicationMode() ?? !forceDfu
        
        if applicationMode {
            logger.w("Application with buttonless update found")
        }
        
        return applicationMode
    }
    
    /**
     Switches target device to the DFU Bootloader mode.
     
     - parameter forceNewAddress: Set to true if the bootloader is expected to advertise
                                  with a different address than when in app mode.
     */
    func jumpToBootloader(forceNewAddress: Bool) {
        guard let dfuService = dfuService else { return }
        jumpingToBootloader = true
        newAddressExpected = dfuService.newAddressExpected || forceNewAddress
        dfuService.jumpToBootloaderMode(
            // On success, the device gets disconnected and
            // `centralManager(_:didDisconnectPeripheral:error)` will be called.
            onError: { [weak self] error, message in
                self?.jumpingToBootloader = false
                self?.delegate?.error(error, didOccurWithMessage: message)
            }
        )
    }
    
    /**
     Sends the DFU Start command.
     
     The DFU Start command with the specified firmware type is sent to the
     DFU Control Point characteristic followed by firmware sizes (in bytes) to
     the DFU Packet characteristic. Then it waits for a response notification
     from the device. In case of a *Success*, it calls `delegate.peripheralDidStartDfu()`.
     If the response has an error code *NotSupported* it means, that the target
     device does not support updating SoftDevice or Bootloader and the old Start DFU
     command needs to be used. The old command (without a type) allowed to send only
     an application firmware.
     
     - parameter type: The firmware type bitfield. See `FIRMWARE_TYPE_*` constants.
     - parameter size: The size of all parts of the firmware.
     */
    func sendStartDfu(withFirmwareType type: UInt8, andSize size: DFUFirmwareSize) {
        dfuService?.sendStartDfu(withFirmwareType: type, andSize: size,
            onSuccess: { [weak self] in self?.delegate?.peripheralDidStartDfu() },
            onError: { [weak self] error, message in
                guard let self = self else { return }
                if error == .remoteLegacyDFUNotSupported {
                    self.logger.w("DFU target does not support DFU v.2")
                    self.delegate?.peripheralDidFailToStartDfuWithType()
                } else {
                    self.delegate?.error(error, didOccurWithMessage: message)
                }
            }
        )
    }
    
    /**
     Sends the old Start DFU command, where there was no type byte. 
     
     The old format allowed to send the application update only. Try this method if
     `sendStartDfuWithFirmwareType(_:andSize:)`
     returned *NotSupported* and the firmware contains only the application.
     
     - parameter size: The size of all parts of the firmware, where size of
                       SoftDevice and Bootloader are 0.
     */
    func sendStartDfu(withFirmwareSize size: DFUFirmwareSize) {
        guard let dfuService = dfuService else { return }
        logger.v("Switching to DFU v.1")
        
        // Flash operation in DFU Bootloaders from SDK 6.0 and older were too slow
        // for modern iDevices, so PRNs must be enabled to slow the transfer down.
        // Also, a 1000ms delay is required before starting sending data.
        slowDfuMode = true
        
        dfuService.sendStartDfu(withFirmwareSize: size,
            onSuccess: { [weak self] in self?.delegate?.peripheralDidStartDfu() },
            onError: defaultErrorCallback
        )
    }

    /**
     Sends the Init Packet with firmware metadata. 
     
     When complete, the `delegate.peripheralDidReceiveInitPacket()`
     callback is called.
     
     - parameter data: Init Packet data.
     */
    func sendInitPacket(_ data: Data) {
        dfuService?.sendInitPacket(data,
            onSuccess: { [weak self] in self?.delegate?.peripheralDidReceiveInitPacket() },
            onError: defaultErrorCallback
        )
    }
    
    /**
     Sends the firmware to the DFU target device. 
     
     Before the firmware is sent,, it will send the desired number of packets
     to be received before sending a new Packet Receipt Notification.
     
     When the whole firmware is transferred the
     `delegate.peripheralDidReceiveFirmware()` callback is invoked.
     
     - parameter firmware: The firmware to be sent.
     - parameter prnValue: Number of packets of firmware data to be received by the
                           DFU target before sending a new Packet Receipt Notification.
                           Set 0 to disable PRNs.
     - parameter progress: The delegate that will be informed about progress changes.
     - parameter queue:    The queue to dispatch progress delegate events.
     */
    func sendFirmware(_ firmware: DFUFirmware, withPacketReceiptNotificationNumber prnValue: UInt16,
                      andReportProgressTo progress: DFUProgressDelegate?, on queue: DispatchQueue) {
        var prn = prnValue
        if slowDfuMode {
            // Force PRN set to 1 on older devices.
            // Otherwise, the device could send error 6: Operation failed.
            prn = 1
        }
        dfuService?.sendPacketReceiptNotificationRequest(prn,
            onSuccess: { [weak self] in
                guard let self = self else { return }
                // Now the service is ready to send the firmware.
                self.dfuService?.sendFirmware(firmware, withDelay: self.slowDfuMode,
                    andReportProgressTo: progress, on: queue,
                    onSuccess: { [weak self] in self?.delegate?.peripheralDidReceiveFirmware() },
                    onError: self.defaultErrorCallback
                )
            },
            onError: defaultErrorCallback
        )
    }
    
    /**
     Sends the Validate Firmware request to DFU Control Point characteristic.
     
     On success, the `delegate.peripheralDidVerifyFirmware()` method will be called.
     */
    func validateFirmware() {
        dfuService?.sendValidateFirmwareRequest(
            onSuccess: { [weak self] in self?.delegate?.peripheralDidVerifyFirmware() },
            onError: defaultErrorCallback
        )
    }
    
    /**
     Sends the Activate and Reset command to the DFU Control Point characteristic.
     */
    func activateAndReset() {
        guard let dfuService = dfuService else { return }
        activating = true
        
        // In Legacy DFU the Buttonless service does not increment the device address.
        // However, after sending the first part of the firmware, the device reboots
        // and may use incremented MAC address to receive the second part.
        newAddressExpected = true
        
        dfuService.sendActivateAndResetRequest(
            // On success, the device gets disconnected and
            // `centralManager(_:didDisconnectPeripheral:error)` will be called.
            onError: { [weak self] error, message in
                self?.activating = false
                self?.delegate?.error(error, didOccurWithMessage: message)
            }
        )
    }
    
    override func resetDevice() {
        guard let dfuService = dfuService, dfuService.supportsReset() else {
            super.resetDevice()
            return
        }
        dfuService.sendReset(onError: defaultErrorCallback)
    }
}
