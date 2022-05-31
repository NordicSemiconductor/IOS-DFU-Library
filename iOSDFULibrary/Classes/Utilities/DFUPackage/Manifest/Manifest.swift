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

class Manifest: NSObject {
    
    // MARK: - Properties
    
    var application: ManifestFirmwareInfo?
    var softdevice:  ManifestFirmwareInfo?
    var bootloader:  ManifestFirmwareInfo?
    var softdeviceBootloader: SoftdeviceBootloaderInfo?
    
    var valid: Bool {
        // The manifest.json file may specify only:
        // 1. a softdevice, a bootloader, or both combined (with, or without an app)
        // 2. only the app
        let hasApplication = application != nil
        var count = 0
        
        count += softdevice != nil ? 1 : 0
        count += bootloader != nil ? 1 : 0
        count += softdeviceBootloader != nil ? 1 : 0
        
        return count == 1 || (count == 0 && hasApplication)
    }
    
    // MARK: - Init
    
    init(withJsonString aString: String) {
        do {
            guard let data = aString.data(using: String.Encoding.utf8),
                  let aDictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, AnyObject> else {
                throw Error.unableToParseJSON(description: "Unable to Decode root JSON Dictionary.")
            }
            
            guard let mainObject = aDictionary["manifest"] as? Dictionary<String, AnyObject> else {
                throw Error.unableToParseJSON(description: "Manifest JSON Dictionary could not be found.")
            }
            
            if let applicationDictionary = mainObject["application"] as? Dictionary<String, AnyObject> {
                self.application = ManifestFirmwareInfo(withDictionary: applicationDictionary)
            }
            
            if let bootloaderDictionary = mainObject["softdevice_bootloader"] as? Dictionary<String, AnyObject> {
                self.softdeviceBootloader = SoftdeviceBootloaderInfo(withDictionary: bootloaderDictionary)
            }
            
            if let softDeviceDictionary = mainObject["softdevice"] as? Dictionary<String, AnyObject> {
                self.softdevice = ManifestFirmwareInfo(withDictionary: softDeviceDictionary)
            }
            
            if let bootloaderDictionary = mainObject["bootloader"] as? Dictionary<String, AnyObject> {
                self.bootloader = ManifestFirmwareInfo(withDictionary: bootloaderDictionary)
            }
        } catch {
            print("Encountered an error while parsing manifest.json: \(error.localizedDescription)")
        }        
    }
}

// MARK: - Manifest.Error

extension Manifest {
    
    enum Error: Swift.Error, LocalizedError {
        case unableToParseJSON(description: String)
        
        var errorDescription: String? {
            switch self {
            case .unableToParseJSON(let description):
                return description
            }
        }
    }
}
