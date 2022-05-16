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
                SectionImage(image: DfuImages.fileUpload)
                Text(DfuStrings.file)
                    .font(.title)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
               
                if (viewModel.isFileLoading) {
                    ProgressBar()
                } else {
                    DfuButton(title: DfuStrings.select, action: {
                        self.openFile.toggle()
                        viewModel.isFileLoading = true
                        viewModel.clearFileError()
                    })
                }
            }
            .padding()
            .onOpenURL { url in
                viewModel.isFileLoading = true
                onFileOpen(opened: url)
            }
            
            HStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.gray)
                    .frame(width: 5, height: 30)
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                
                VStack {
                    if let file = viewModel.zipFile {
                        Text(String(format: DfuStrings.fileName, file.name)).frame(maxWidth: .infinity, alignment: .leading)
                        Text(String(format: DfuStrings.fileSize, file.size)).frame(maxWidth: .infinity, alignment: .leading)
                        }
                    else {
                        Text(DfuStrings.fileSelect).frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if viewModel.fileError != nil {
                        Spacer()
                        Text(viewModel.fileError!)
                            .foregroundColor(ThemeColor.nordicRed)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
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
            
            let zipFile = ZipFile(name: fileName, size: fileSize, url: fileUrl)
            try viewModel.onFileSelected(selected: zipFile)
            
            fileUrl.stopAccessingSecurityScopedResource()
            print(fileUrl)
            
            defer {
                viewModel.isFileLoading = false
            }
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
