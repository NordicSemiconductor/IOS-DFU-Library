//
//  DFUExecutor.swift
//  Pods
//
//  Created by Mostafa Berg on 17/06/16.
//
//

import CoreBluetooth

class DFUExecutor : NSObject {
    internal var initiator  : DFUServiceInitiator
    internal var firmware   : DFUFirmware
    internal var peripheral : CBPeripheral
//    internal var delegate   : DFUServiceDelegate
    init(_ initiator:DFUServiceInitiator) {
        self.initiator  = initiator
        self.firmware   = initiator.file!
        self.peripheral = initiator.target
//        self.delegate   = DFUServiceDelegate()
    }
    
    
    
    // MARK: - DFU Controller methods
    func start() {
        dispatch_async(dispatch_get_main_queue(), {
//            self.delegate?.didStateChangedTo(DFUState.Connecting)
        })
    }
    
    func pause() -> Bool {
        return true
//        return peripheral.pause()
    }
    
    func resume() -> Bool {
        return true
//        return peripheral.resume()
    }
    
    func abort() {
//        peripheral.abort()
    }
}
