/*
* Copyright (c) 2019, Nordic Semiconductor
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
