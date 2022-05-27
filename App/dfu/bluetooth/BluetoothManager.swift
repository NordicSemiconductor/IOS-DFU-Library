/*
* Copyright (c) 2022, Nordic Semiconductor
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

import SwiftUI
import Combine
import os
import os.log
import CoreBluetooth

class BluetoothManager : NSObject, CBPeripheralDelegate, ObservableObject {
    
    private let MIN_RSSI = NSNumber(-65)
    
    @Published var devices: [BluetoothDevice] = []
    
    @Published var nearbyOnlyFilter = false
    
    @Published var withNameOnlyFilter = false
    
    private var centralManager: CBCentralManager!
    
    private var isOnScreen = false
    private var isBluetoothReady = false
    
    override init() {
        super.init()
        os_log("init")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func filteredDevices() -> [BluetoothDevice] {
        return devices.filter { device in
            if !nearbyOnlyFilter {
                return true
            }
            let result: ComparisonResult = device.rssi.compare(MIN_RSSI)
            return result == ComparisonResult.orderedDescending
        }.filter { device in
            if !withNameOnlyFilter {
                return true
            }
            return device.name != nil
        }
    }
    
    func startScan() {
        isOnScreen = true
        runScanningWhenNeeded()
    }
    
    func stopScan() {
        isOnScreen = false
        centralManager.stopScan()
    }
    
    private func runScanningWhenNeeded() {
        if (isOnScreen && isBluetoothReady) {
            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
}

// MARK: - CB Central Manager impl

extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            os_log("BLE powered on")
            // Turned on
            isBluetoothReady = true
            runScanningWhenNeeded()
        }
        else {
            isBluetoothReady = false
            os_log("Something wrong with BLE")
            // Not on, but can have different issues
        }
        
        var consoleLog = ""

        switch central.state {
            case .poweredOff:
                consoleLog = "BLE is powered off"
            case .poweredOn:
                consoleLog = "BLE is poweredOn"
            case .resetting:
                consoleLog = "BLE is resetting"
            case .unauthorized:
                consoleLog = "BLE is unauthorized"
            case .unknown:
                consoleLog = "BLE is unknown"
            case .unsupported:
                consoleLog = "BLE is unsupported"
            default:
                consoleLog = "default"
        }
        
        os_log("BluetoothManager status: %@", consoleLog)
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        os_log("Device: \(peripheral.name ?? "NO_NAME"), Rssi: \(RSSI)")
        
        let pname = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        let device = BluetoothDevice(peripheral: peripheral, rssi: RSSI, name: pname)
        let index = devices.map { $0.peripheral }.firstIndex(of: peripheral)
        if let index = index {
            devices[index] = device
        } else {
            devices.append(device)
        }
    }
}
