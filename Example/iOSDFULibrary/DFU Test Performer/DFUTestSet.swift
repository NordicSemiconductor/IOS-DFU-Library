//
//  DFUTestSet.swift
//  iOSDFULibrary_Example
//
//  Created by Aleksander Nowakowski on 06/02/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import iOSDFULibrary
import CoreBluetooth

enum DFUTestError : Error {
    case fileNotFound
    case invalidFirmware
}

typealias AdvertisingData = [String : Any]
typealias Filter = (AdvertisingData) -> Bool

protocol DFUTestSet {
    /**
     The list contains number of tripples:
     [0] firmware to be sent in this step,
     [1] step description to show on the screen,
     [1] filter method to be used to find the next target. The first map is the advertisement data.
     The last step returns nil as [2].
     */
    var steps: [(firmware: DFUFirmware, description: String, next: Filter?)]? { get }
}

extension DFUTestSet {
    
    var totalParts: Int {
        guard let steps = steps else {
            return 0
        }
        
        var i = 0
        for step in steps {
            i += step.firmware.parts
        }
        return i
    }
}

class FilterBy {
    
    static func name(_ name: String) -> Filter? {
        return {
            (advertisementData: AdvertisingData) -> Bool in
            return advertisementData[CBAdvertisementDataLocalNameKey] as! String? == name
        }
    }
    
}

extension DFUFirmware {
    
    private static func from(urlToZipFile url: URL?) throws -> DFUFirmware {
        guard url != nil else {
            throw DFUTestError.fileNotFound
        }
        let firmware = DFUFirmware(urlToZipFile: url!)
        guard firmware != nil else {
            throw DFUTestError.invalidFirmware
        }
        return firmware!
    }
    
    static func from(zip name: String, locatedIn subdirectory: String) throws -> DFUFirmware {
        let url = Bundle.main.url(forResource: name, withExtension: "zip", subdirectory: subdirectory)
        return try DFUFirmware.from(urlToZipFile: url)
    }
    
    static func fromCustomZip() throws -> DFUFirmware {
        let urls = Bundle.main.urls(forResourcesWithExtension: "zip", subdirectory: "Firmwares/Custom")
        return try DFUFirmware.from(urlToZipFile: urls?.first)
    }
    
}
