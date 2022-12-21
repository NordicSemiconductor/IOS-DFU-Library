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
    private let MIN_RSSI = -50
    
    @Published var devices: [BluetoothDevice] = []
    
    @Published var nearbyOnlyFilter = false
    
    @Published var withNameOnlyFilter = false
    
    private var centralManager: CBCentralManager!
    
    private var isOnScreen = false
    private var isBluetoothReady = false
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func filteredDevices() -> [BluetoothDevice] {
        return devices
            .filter { !nearbyOnlyFilter || $0.highestRssi > MIN_RSSI }
            .filter { !withNameOnlyFilter || $0.hadName }
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
        if isOnScreen && isBluetoothReady {
            centralManager.scanForPeripherals(
                withServices: nil,
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
            )
        }
    }
}

// MARK: - CB Central Manager impl

extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        os_log("BluetoothManager status: %@", central.state.name)
        
        if central.state == CBManagerState.poweredOn {
            // Turned on
            isBluetoothReady = true
            runScanningWhenNeeded()
        }
        else {
            isBluetoothReady = false
        }
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        let index = devices.firstIndex { $0.peripheral == peripheral }
        if let index = index {
            devices[index].update(rssi: Int(truncating: RSSI), name: name)
        } else {
            let device = BluetoothDevice(peripheral: peripheral, rssi: Int(truncating: RSSI), name: name)
            devices.append(device)
        }
    }
}

private extension CBManagerState {
    
    var name: String {
        switch self {
            case .poweredOff:
                return "BLE is powered off"
            case .poweredOn:
                return "BLE is powered on"
            case .resetting:
                return "BLE is resetting"
            case .unauthorized:
                return "BLE is unauthorized"
            case .unknown:
                return "BLE is unknown"
            case .unsupported:
                return "BLE is unsupported"
            default:
                return "default"
        }
    }
    
}
