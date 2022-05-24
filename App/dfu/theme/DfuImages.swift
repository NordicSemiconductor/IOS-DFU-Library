//
//  DfuImages.swift
//  dfu
//
//  Created by Nordic on 02/05/2022.
//

enum DfuImages : String {
    case idle = "filled-circle"
    case success = "success"
    case progress = "progress"
    case error = "error"
    
    case fileUpload = "file-upload-outline"
    case bluetooth = "bluetooth"
    case upload = "upload"
    
    case dfu = "dfu"
    
    var imageName: String {
        self.rawValue
    }
}
