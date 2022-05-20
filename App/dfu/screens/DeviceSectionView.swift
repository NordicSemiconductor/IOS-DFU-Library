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
    
    @State private var goToScannerView: Bool?
    
    var body: some View {
        VStack {
            HStack {
                SectionImage(image: DfuImages.bluetooth)
                Text(DfuStrings.device)
                    .padding()
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                NavigationLink(destination: ScannerView(viewModel: viewModel), tag: true, selection: $goToScannerView) { }
                DfuButton(title: DfuStrings.select, action: {
                    goToScannerView = true
                })
            }.padding()
            
            HStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.gray)
                    .frame(width: 5, height: .infinity)
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                
                if let device = viewModel.device {
                    Text(String(format: DfuStrings.deviceName, device.name))
                        .padding(.vertical, 8)
                } else {
                    Text(DfuStrings.deviceSelect)
                        .padding(.vertical, 8)
                }
                Spacer()
            }
        }.disabled(viewModel.isDeviceButtonDisabled())
    }
}

struct DeviceSectionView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceSectionView(viewModel: DfuViewModel())
    }
}
