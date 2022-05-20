//
//  SettingsView.swift
//  dfu
//
//  Created by Nordic on 29/03/2022.
//

import SwiftUI

private let INFOCENTER_LINK = "https://infocenter.nordicsemi.com/topic/sdk_nrf5_v17.1.0/examples_bootloader.html"

struct SettingsView: View {
    
    @ObservedObject
    var viewModel: DfuViewModel
    
    @State
    private var showingAlert = false
    
    @State
    private var showWelcomeScreen: Bool?
    
    var body: some View {
        ScrollView {
            VStack {
                Group {
                    CheckboxSectionView(
                        title: DfuStrings.settingsPacketReceiptTitle,
                        description: DfuStrings.settingsPacketReceiptValue,
                        isChecked: $viewModel.packetsReceiptNotification
                    )
                    
                    Spacer().frame(height: 16)
                    
                    if viewModel.packetsReceiptNotification {
                        
                        Button(action: { showingAlert = true }) {
                            VStack {
                                Text(DfuStrings.numberOfPackets)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("\(viewModel.numberOfPackets)")
                                    .font(.footnote)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        Spacer().frame(height: 16)
                    }
                    
                    CheckboxSectionView(
                        title: DfuStrings.alternativeAdvertisingNameTitle,
                        description: DfuStrings.alternativeAdvertisingNameValue,
                        isChecked: $viewModel.alternativeAdvertisingNameEnabled
                    )
                    
                    Spacer().frame(height: 16)
                }

                Text(DfuStrings.settingsSecureDfu)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                CheckboxSectionView(
                    title: DfuStrings.settingsDisableResumeTitle,
                    description: DfuStrings.settingsDisableResumeValue,
                    isChecked: $viewModel.disableResume
                )
                
                Spacer().frame(height: 16)
                
                Group {
                    Text(DfuStrings.settingsLegacyDfu)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CheckboxSectionView(
                        title: DfuStrings.settingsForceScanningTitle,
                        description: DfuStrings.settingsForceScanningValue,
                        isChecked: $viewModel.forceScanningInLegacyDfu
                    )

                    Spacer().frame(height: 16)
                    
                    CheckboxSectionView(
                        title: DfuStrings.settingsExternalMcuTitle,
                        description: DfuStrings.settingsExternalMcuValue,
                        isChecked: $viewModel.externalMcuDfu
                    )
                }
                
                Group {
                    Text(DfuStrings.settingsOther)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer().frame(height: 16)
                    
                    Link(destination: URL(string: INFOCENTER_LINK)!) {
                        VStack {
                            Text(DfuStrings.settingsAboutTitle)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(DfuStrings.settingsAboutValue)
                                .font(.footnote)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    Spacer().frame(height: 16)
         
                    NavigationLink(destination: WelcomeScreen(viewModel: viewModel), tag: true, selection: $showWelcomeScreen) { }
                    Button(action: { showWelcomeScreen = true }) {
                        Text(DfuStrings.settingsWelcome)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                }
            }
            .padding()
            .navigationTitle(DfuStrings.settingsTitle)

        }.alert(
            isPresented: $showingAlert,
            TextAlert(
                title: DfuStrings.numberOfPackets,
                message: DfuStrings.settingsProvideNumberOfPackets,
                keyboardType: .numberPad
            ) { result in
                if let result = result {
                    viewModel.numberOfPackets = Int(result) ?? viewModel.numberOfPackets
                }
             }
        )
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: DfuViewModel())
    }
}
