//
//  BluetoothManager.swift
//  dfu
//
//  Created by Nordic on 24/03/2022.
//
import SwiftUI
import Combine
import os
import os.log
import CoreBluetooth

class BluetoothManager : NSObject, CBPeripheralDelegate, ObservableObject {
    
    private let MIN_RSSI = NSNumber(-65)
    
    @Published
    var devices: [BluetoothDevice] = []
    
    @Published
    var nearbyOnlyFilter = false
    
    private var centralManager: CBCentralManager!
    
    private var isOnScreen = false
    private var isBluetoothReady = false
    
    override init() {
        super.init()
        os_log("init")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func filteredDevices() -> [BluetoothDevice] {
        if nearbyOnlyFilter {
            return devices.filter { device in
                let result: ComparisonResult = device.rssi.compare(MIN_RSSI)
                return result == ComparisonResult.orderedDescending
            }
        } else {
            return devices
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
        //TODO: show devices with no name (+filter)
        if let pname = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            let device = BluetoothDevice(peripheral: peripheral, rssi: RSSI, name: pname)
            let index = devices.map { $0.peripheral }.firstIndex(of: peripheral)
            if let index = index {
                devices[index] = device
            } else {
                devices.append(device)
            }
        }
    }
}
