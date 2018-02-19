//
//  CustomTestSet.swift
//  iOSDFULibrary_Example
//
//  Created by Aleksander Nowakowski on 07/02/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import iOSDFULibrary

class CustomTestSet: DFUTestSet {
    
    // Find and return the name of the first found ZIP file in Resources/Custom, or nil if not found
    var steps: [(firmware: DFUFirmware, options: ServiceModifier?, expectedError: DFUError?, description: String, next: Filter?)]? {
        return try? [(DFUFirmware.fromCustomZip(), nil, nil, "Custom firmware update", nil)]
    }
    
}
