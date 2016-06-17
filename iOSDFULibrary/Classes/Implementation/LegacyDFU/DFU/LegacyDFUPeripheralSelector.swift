//
//  LegacyDFUPeripheralSelector.swift
//  Pods
//
//  Created by Mostafa Berg on 16/06/16.
//
//

import CoreBluetooth

/// The default selector. Returns the first device with DFU Service UUID in the advrtising packet.
class LegacyDFUPeripheralSelector : NSObject, DFUPeripheralSelector {
    func select(peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) -> Bool {
        return true
    }
    
    func filterBy() -> [CBUUID]? {
        return [LegacyDFUService.UUID]
    }
}
