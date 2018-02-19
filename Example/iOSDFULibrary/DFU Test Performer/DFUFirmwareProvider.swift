//
//  DFUFirmwareProvider.swift
//  iOSDFULibrary_Example
//
//  Created by Aleksander Nowakowski on 07/02/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import iOSDFULibrary

class DFUFirmwareProvider {
    private var steps: [(firmware: DFUFirmware, options: ServiceModifier?, expectedError: DFUError?, description: String, next: Filter?)]?
    private var index: Int
    public  let count: Int
    public  let totalParts: Int
    
    private init(testSet: DFUTestSet) {
        steps = testSet.steps
        count = steps?.count ?? 0
        totalParts = testSet.totalParts
        index = 0
        
        if count == 0 {
            print("Empty test set! Check if the Test Set is correct or if the custom firmware is in Firmwares/Custom folder")
        }
    }
    
    var firmware: DFUFirmware? {
        guard index < count else {
            return nil
        }
        return steps![index].firmware
    }
    
    var description: String? {
        guard index < count else {
            return nil
        }
        return steps![index].description
    }
    
    var expectedError: DFUError? {
        guard index < count else {
            return nil
        }
        return steps![index].expectedError
    }
    
    func applyModifier(to initiator: DFUServiceInitiator) {
        steps![index].options?(initiator)
    }
    
    var filter: Filter? {
        guard index < count else {
            return nil
        }
        return steps![index].next
    }
    
    func hasNext() -> Bool {
        return index + 1 < count && steps![index].next != nil
    }
    
    func next() {
        index += 1
    }
    
    static func get(byName name: String?) -> DFUFirmwareProvider {
        switch name {
        case .some(nRF51TestSet.requiredName):
            return DFUFirmwareProvider(testSet: nRF51TestSet())
        case .some(nRF52832TestSet.requiredName):
            return DFUFirmwareProvider(testSet: nRF52832TestSet())
        case .some(nRF52840TestSet.requiredName):
            return DFUFirmwareProvider(testSet: nRF52840TestSet())
        default:
            return DFUFirmwareProvider(testSet: CustomTestSet())
        }
    }
}
