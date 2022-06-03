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

// MARK: - SoftdeviceBootloaderInfo

struct SoftdeviceBootloaderInfo: ManifestFirmware, Codable {
    
    // MARK: Properties
    
    let binFile: String?
    let datFile: String?
    let metadata: Metadata?
    let _blSize: UInt32?
    let _sdSize: UInt32?
    
    // MARK: Computed Properties
    
    var blSize: UInt32 {
        return metadata?.blSize ?? _blSize ?? 0
    }
    
    var sdSize: UInt32 {
        return metadata?.sdSize ?? _sdSize ?? 0
    }
    
    // MARK: CodingKeys
    
    enum CodingKeys: String, CodingKey {
        case binFile = "bin_file"
        case datFile = "dat_file"
        case metadata = "info_read_only_metadata"
        case _blSize = "bl_size"
        case _sdSize = "sd_size"
    }
}

// MARK: - SoftdeviceBootloaderInfo.SecureMetadata

extension SoftdeviceBootloaderInfo {

    struct Metadata: Codable {

        let blSize: UInt32
        let sdSize: UInt32

        // MARK: CodingKeys

        enum CodingKeys: String, CodingKey {
            case blSize = "bl_size"
            case sdSize = "sd_size"
        }
    }
}
