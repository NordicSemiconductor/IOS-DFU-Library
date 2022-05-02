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
}
