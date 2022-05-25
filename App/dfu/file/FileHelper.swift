//
//  FileManager.swift
//  dfu
//
//  Created by Nordic on 24/05/2022.
//

import Foundation

class FileHelper {
    
    func copyFileToTmpDirectory(fileName name: String, readFromDisk file: URL) -> URL? {
        do {
            let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)

            let displayName = (name as NSString).deletingPathExtension
            var temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(displayName, isDirectory: false)
            temporaryFileURL = temporaryFileURL.appendingPathExtension("zip")

            let readFileHandle = try FileHandle(forReadingFrom: file)
      
            defer { readFileHandle.closeFile() }
       
            if let data = try readFileHandle.readToEnd() {
                try data.write(to: temporaryFileURL)
            } else {
                return nil
            }
        
            return temporaryFileURL
        } catch {
            print("Error info: \(error)")
            return nil
        }
    }
}
