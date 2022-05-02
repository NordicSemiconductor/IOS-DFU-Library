//
//  CardComponent.swift
//  dfu
//
//  Created by Nordic on 23/03/2022.
//

import SwiftUI

struct FileSectionView: View {
    @State private var openFile = false
    @State private var errorMessage: String? = nil
    
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
               
                DfuButton(title: DfuStrings.select, action: {
                    self.openFile.toggle()
                    errorMessage = nil
                })
            }.padding()
            
            HStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.gray)
                    .frame(width: 5, height: 30)
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                
                if let file = viewModel.zipFile {
                    VStack {
                        Text(String(format: DfuStrings.fileName, file.name)).frame(maxWidth: .infinity, alignment: .leading)
                        Text(String(format: DfuStrings.fileSize, file.size)).frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                    Spacer()
                } else {
                    Text(DfuStrings.fileSelect)
                    Spacer()
                }
            }
        }
        .fileImporter(isPresented: $openFile, allowedContentTypes: [.zip]) { (res) in
            do {
                let fileUrl = try res.get()
                print(fileUrl)
                
                guard fileUrl.startAccessingSecurityScopedResource() else { return }
                let resources = try fileUrl.resourceValues(forKeys:[.fileSizeKey, .nameKey])
                let fileSize = resources.fileSize!
                let fileName = resources.name!
                
                viewModel.zipFile = ZipFile(name: fileName, size: fileSize, url: fileUrl)
                
                fileUrl.stopAccessingSecurityScopedResource()
                
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct FileSectionView_Previews: PreviewProvider {
    static var previews: some View {
        FileSectionView(viewModel: DfuViewModel())
    }
}
