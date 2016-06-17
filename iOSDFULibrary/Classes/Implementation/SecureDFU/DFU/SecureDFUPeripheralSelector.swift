//
//  SecureDFUPeripheralSelector.swift
//  Pods
//
//  Created by Mostafa Berg on 16/06/16.
//
//

import CoreBluetooth

/// The default selector. Returns the first device with DFU Service UUID in the advrtising packet.
public class SecureDFUPeripheralSelector : NSObject, DFUPeripheralSelector {
    public func select(peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) -> Bool {
        return true
    }
    
    public func filterBy() -> [CBUUID]? {
        return [SecureDFUService.UUID]
    }
}