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
 The DFU peripheral selector delegate is used to select the device advertising in
 DFU bootloader mode after switching from application mode.
 
 When a peripheral is switching to the bootloader mode that will change its MAC
 address the library needs to select the correct device to continue the DFU
 process. As MAC addresses are not exposed using iOS API, the selector
 provides a mechanism choosing the correct target.
 
 The default implementation is provided by ``DFUPeripheralSelector``.
 
 This library supports sending both BIN files from a ZIP Distribution
 Packet automatically. However, when sending the SoftDevice update, the
 DFU Bootloader may remove the current application in order to make space
 for the new SoftDevice firmware (Legacy DFU, or Secure DFU with single
 bank enabled when new SD+BL are larger then space available) or may
 advertise in Bootloader mode for number of seconds (Secure DFU). When the
 new SoftDevice is flashed the bootloader restarts the device and starts
 advertising in DFU Bootloader mode.
 
 Since SDK 8.0.0, to solve caching problem on a host that is not bonded
 (in case there is no Service Changed characteristic), the bootloader
 starts to advertise with an address incremented by 1. The DFU Library has
 to scan for a peripheral with this new address. However, as iOS does not
 expose the device address in the public CoreBluetooth API, address matching,
 used on Android, can not be used. Instead, this selector is used. The DFU
 Service will start scanning for peripherals with a UUID filter, where the
 list of required UUID is returned by the ``filterBy(hint:)`` method. If your
 device in the Bootloader mode does not advertise with any service UUIDs,
 or this is not enough, you may select a target device by their advertising
 packet or RSSI using this delegate.
 
 In SDK 14.0.0 a new feature was added to the Buttonless DFU for non-bonded
 devices which allows to send a unique name to the device before it is
 switched to bootloader mode. After jump, the bootloader will advertise
 with this name as the Complete Local Name making it easy to select proper
 device. In this case you don't have to override the default peripheral
 selector.
 
 Read more about the new feature on [Infocenter](https://infocenter.nordicsemi.com/topic/sdk_nrf5_v17.1.0/ble_sdk_app_buttonless_dfu.html?cp=9_1_4_4_1).
 */
@objc public protocol DFUPeripheralSelectorDelegate: AnyObject {
    
    /**
     Returns whether the given peripheral is a device in DFU Bootloader mode.
     
     - parameters:
       - peripheral:        The peripheral to be checked.
       - advertisementData: Scanned advertising data.
       - RSSI:              Received signal strength indication in dBm.
       - name:              An optional name to look for in the
                            advertisement packet (see Buttonless DFU in SDK 14).
     
     - returns: True (YES) if given peripheral is what service is looking for.
     */
    @objc func select(_ peripheral: CBPeripheral, advertisementData: [String : AnyObject],
                      RSSI: NSNumber, hint name: String?) -> Bool
    
    /**
     Returns an optional list of services that the scanner will use to filter
     advertising packets when scanning for a device in DFU Bootloader mode.
     
     To find out what UUID you should return, switch your device to DFU Bootloader
     mode (with a button!) and check the advertisement packet. The result of this
     method will be applied to
     `centralManager.scanForPeripherals(withServices: [CBUUID]?, options: [String : AnyObject]?)`.
     
     - parameter dfuServiceUUID: The UUID of the DFU service that was used to
                                 flash SoftDevice and/or Bootloader. Usually, this
                                 service UUID is present in the DFU Bootloader's
                                 advertising packet. Then this method may simply
                                 return `[dfuServiceUUID]`.
     
     - returns: An optional list of services or nil.
     */
    @objc func filterBy(hint dfuServiceUUID: CBUUID) -> [CBUUID]?
}
