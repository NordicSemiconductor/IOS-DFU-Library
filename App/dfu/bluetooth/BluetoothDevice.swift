//
//  BluetoothDevice.swift
//  dfu
//
//  Created by Nordic on 25/03/2022.
//

import SwiftUI
import Combine
import os
import os.log
import CoreBluetooth

struct BluetoothDevice : Identifiable {
    let id = UUID()
    
    let peripheral: CBPeripheral
    
    let rssi: NSNumber
    
    let name: String
    
    func getSignalStrength() -> SignalStrength {
        if (rssi.compare(NSNumber(-65)) == ComparisonResult.orderedDescending) {
            return SignalStrength.strong
        }
        else if (rssi.compare(NSNumber(-85)) == ComparisonResult.orderedDescending) {
            return SignalStrength.normal
        }
        else {
            return SignalStrength.weak
        }
    }
}
