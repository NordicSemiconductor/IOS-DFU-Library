//
//  FileSection.swift
//  dfu
//
//  Created by Nordic on 23/03/2022.
//
import SwiftUI

struct DeviceSectionView: View {
    
    @ObservedObject
    var viewModel: DfuViewModel
    
    @State private var action: Bool?
    
    var body: some View {
        VStack {
            HStack {
                SectionImage(image: DfuImages.bluetooth)
                Text(DfuStrings.device)
                    .padding()
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                NavigationLink(destination: ScannerView(viewModel: viewModel), tag: true, selection: $action) { }
                DfuButton(title: DfuStrings.select, action: {
                    action = true
                })
            }.padding()
            
            HStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.gray)
                    .frame(width: 5, height: 30)
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                if let device = viewModel.device {
                    Text(String(format: DfuStrings.deviceName, device.name))
                } else {
                    Text(DfuStrings.deviceSelect)
                }
                Spacer()
            }
        }.disabled(viewModel.zipFile == nil)
    }
}

struct DeviceSectionView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceSectionView(viewModel: DfuViewModel())
    }
}
