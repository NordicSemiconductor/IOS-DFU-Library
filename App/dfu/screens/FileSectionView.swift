//
//  CardComponent.swift
//  dfu
//
//  Created by Nordic on 23/03/2022.
//

import SwiftUI

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
                onFileOpen(opened: url)
            }.disabled(viewModel.isFileButtonDisabled())
            
            HStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.gray)
                    .frame(width: 5, height: .infinity)
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                
                //TODO: geometry reader (to get size of the space available)
                
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
                viewModel.onFileError(message: error.localizedDescription)
            }
        }
    }
    
    private func onFileOpen(opened fileUrl: URL) {
        do {
            print(fileUrl)
            
            guard fileUrl.startAccessingSecurityScopedResource() else { return }
            let resources = try fileUrl.resourceValues(forKeys:[.fileSizeKey, .nameKey])
            let fileSize = resources.fileSize!
            let fileName = resources.name!
            
            //TODO: copy file to tmp
            
            let zipFile = ZipFile(name: fileName, size: fileSize, url: fileUrl)
            try viewModel.onFileSelected(selected: zipFile)
            
            fileUrl.stopAccessingSecurityScopedResource()
        } catch {
            viewModel.onFileError(message: error.localizedDescription)
        }
    }
}

struct FileSectionView_Previews: PreviewProvider {
    static var previews: some View {
        FileSectionView(viewModel: DfuViewModel())
    }
}
