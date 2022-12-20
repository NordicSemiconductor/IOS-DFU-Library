/*
* Copyright (c) 2022, Nordic Semiconductor
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

import SwiftUI
import NordicDFU

struct FileSectionView: View {
    @State private var openFile = false
    
    @ObservedObject
    var viewModel: DfuViewModel
    
    var body: some View {
        VStack {
            HStack {
                SectionImage(image: DfuImages.fileUpload.rawValue)
                Text(DfuStrings.file.rawValue)
                    .font(.title)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                DfuButton(title: DfuStrings.select.rawValue, action: {
                    self.openFile.toggle()
                    viewModel.clearFileError()
                })
            }
            .padding()
            .onOpenURL { url in
                guard let location = url["file"],
                      let fileUrl = URL(string: location) else {
                    return                    
                }
                onFileOpen(opened: fileUrl)
            }
            
            HStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.gray)
                    .frame(width: 5)
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                
                VStack {
                    if let file = viewModel.zipFile {
                        Text(String(format: DfuStrings.fileName.rawValue, file.name)).frame(maxWidth: .infinity, alignment: .leading)
                        Text(String(format: DfuStrings.fileSize.rawValue, file.size)).frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text(DfuStrings.fileSelect.rawValue).frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if viewModel.fileError != nil {
                        Spacer()
                        Text(viewModel.fileError!)
                            .foregroundColor(ThemeColor.nordicRed.color)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }.padding(.vertical, 8)
            }
        }
        .fileImporter(isPresented: $openFile, allowedContentTypes: [.zip]) { (res) in
            do {
                let fileUrl = try res.get()
                onFileOpen(opened: fileUrl)
            } catch {
                onError(error.localizedDescription)
            }
        }
        .disabled(viewModel.isFileButtonDisabled())
    }
    
    private func onFileOpen(opened fileUrl: URL) {
        let downloadTask = URLSession.shared.downloadTask(with: fileUrl) {
            urlOrNil, responseOrNil, errorOrNil in
            if let error = errorOrNil {
                onError(error.localizedDescription)
                return
            }
            
            if let response = responseOrNil as? HTTPURLResponse {
                guard response.statusCode >= 200 && response.statusCode < 300 else {
                    onError(DfuStrings.fileDownloadError.text)
                    return
                }
            }
            guard let response = responseOrNil else {
                onError(DfuStrings.fileError.text)
                return
            }
            
            guard let fileURL = urlOrNil else { return }
            do {
                let documentsURL = try FileManager.default.url(for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: false)
                let savedURL = documentsURL.appendingPathComponent(response.suggestedFilename ?? "file.zip")
                
                try? FileManager.default.removeItem(at: savedURL)
                try FileManager.default.moveItem(at: fileURL, to: savedURL)
                
                let resources = try savedURL.resourceValues(forKeys:[.fileSizeKey, .nameKey])
                let fileSize = resources.fileSize!
                let fileName = resources.name!
                
                let zipFile = ZipFile(name: fileName, size: fileSize, url: savedURL)
                try onFileSelected(zipFile)
            } catch {
                onError(error.localizedDescription)
            }
        }
        downloadTask.resume()
    }
    
    private func onFileSelected(_ file: ZipFile) throws {
        _ = try DFUFirmware(
            urlToZipFile: file.url,
            type: .softdeviceBootloaderApplication
        )
        DispatchQueue.main.async {
            viewModel.onFileSelected(file)
        }
    }
    
    private func onError(_ message: String) {
        DispatchQueue.main.async {
            viewModel.onFileError(message)
        }
    }
}

struct FileSectionView_Previews: PreviewProvider {
    static var previews: some View {
        FileSectionView(viewModel: DfuViewModel())
    }
}

private extension URL {
    
    subscript(queryParam: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        if let parameters = url.queryItems {
            return parameters.first(where: { $0.name == queryParam })?.value
        } else if let paramPairs = url.fragment?.components(separatedBy: "?").last?.components(separatedBy: "&") {
            for pair in paramPairs where pair.contains(queryParam) {
                return pair.components(separatedBy: "=").last
            }
            return nil
        } else {
            return nil
        }
    }
    
}
