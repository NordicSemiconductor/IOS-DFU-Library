//
//  SettingsView.swift
//  dfu
//
//  Created by Nordic on 29/03/2022.
//

import SwiftUI

private let INFOCENTER_LINK = "https://infocenter.nordicsemi.com/topic/sdk_nrf5_v17.1.0/examples_bootloader.html"

struct SettingsView: View {
    
    @ObservedObject var viewModel: DfuViewModel
    
    @State private var showWelcomeScreen: Bool?
    
    @State private var description: String = ""
    
    @State private var showingAlert: Bool = false
    
    var body: some View {

        
        Form {
            Section {
                HStack {
                    Toggle(isOn: $viewModel.packetsReceiptNotification) {
                        Text(DfuStrings.settingsPacketReceiptTitle.text)
                    }.tint(ThemeColor.nordicBlue.color)
                    
                    Image(systemName: DfuImages.info.imageName)
                        .foregroundColor(ThemeColor.nordicBlue.color)
                        .onTapGesture {
                            description = DfuStrings.settingsPacketReceiptValue.text
                            showingAlert = true
                        }
                }
                
                HStack {
                    Text(DfuStrings.numberOfPackets.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: { showingAlert = true }) {
                        Text("\(viewModel.numberOfPackets)")
                    }
                }.disabled(!viewModel.packetsReceiptNotification)
                
                HStack {
                    Toggle(isOn: $viewModel.alternativeAdvertisingNameEnabled) {
                        Text(DfuStrings.alternativeAdvertisingNameTitle.text)
                    }.tint(ThemeColor.nordicBlue.color)
                    
                    Image(systemName: DfuImages.info.imageName)
                        .foregroundColor(ThemeColor.nordicBlue.color)
                        .onTapGesture {
                            description = DfuStrings.alternativeAdvertisingNameValue.text
                            showingAlert = true
                        }
                }
            }
            
            Section(header: Text(DfuStrings.settingsSecureDfu.text)) {
                
                HStack {
                    Toggle(isOn: $viewModel.disableResume) {
                        Text(DfuStrings.settingsDisableResumeTitle.text)
                    }.tint(ThemeColor.nordicBlue.color)
                    
                    Image(systemName: DfuImages.info.imageName)
                        .foregroundColor(ThemeColor.nordicBlue.color)
                        .onTapGesture {
                            description = DfuStrings.settingsDisableResumeValue.text
                            showingAlert = true
                        }
                }
            }
            
            Section(header: Text(DfuStrings.settingsLegacyDfu.text)) {
                
                HStack {
                    Toggle(isOn: $viewModel.forceScanningInLegacyDfu) {
                        Text(DfuStrings.settingsForceScanningTitle.text)
                    }.tint(ThemeColor.nordicBlue.color)
                    
                    Image(systemName: DfuImages.info.imageName)
                        .foregroundColor(ThemeColor.nordicBlue.color)
                        .onTapGesture {
                            description = DfuStrings.settingsForceScanningValue.text
                            showingAlert = true
                        }
                }
                
                HStack {
                    Toggle(isOn: $viewModel.externalMcuDfu) {
                        Text(DfuStrings.settingsExternalMcuTitle.text)
                    }.tint(ThemeColor.nordicBlue.color)
                    
                    Image(systemName: DfuImages.info.imageName)
                        .foregroundColor(ThemeColor.nordicBlue.color)
                        .onTapGesture {
                            description = DfuStrings.settingsExternalMcuValue.text
                            showingAlert = true
                        }
                }
            }
            
            Section(header: Text(DfuStrings.settingsOther.text)) {
                Link(destination: URL(string: INFOCENTER_LINK)!) {
                    HStack {
                        Text(DfuStrings.settingsAboutTitle.text)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: DfuImages.info.imageName)
                            .foregroundColor(ThemeColor.nordicBlue.color)
                            .onTapGesture {
                                description = DfuStrings.settingsAboutValue.text
                                showingAlert = true
                            }
                    }
                }
                
                NavigationLink(destination: WelcomeScreen(viewModel: viewModel), tag: true, selection: $showWelcomeScreen) {
                    Text(DfuStrings.settingsWelcome.text)
                }
            }
        }.navigationTitle(DfuStrings.settings.text)
            .alert(description, isPresented: $showingAlert) {
                Button(DfuStrings.ok.text, role: .cancel) {
                    showingAlert = false
                }
            }
        //        ScrollView {
        //            VStack {
        //                //TODO: Form component (it can crash)
        //                Form {
        //                    CheckboxSectionView(
        //                        title: DfuStrings.settingsPacketReceiptTitle.text,
        //                        description: DfuStrings.settingsPacketReceiptValue.text,
        //                        isChecked: $viewModel.packetsReceiptNotification
        //                    )
        //
        //                    Spacer().frame(height: 16)
        //
        //                    if viewModel.packetsReceiptNotification {
        //
        //                        Button(action: { showingAlert = true }) {
        //                            VStack {
        //                                Text(DfuStrings.numberOfPackets.text)
        //                                    .font(.headline)
        //                                    .frame(maxWidth: .infinity, alignment: .leading)
        //
        //                                Text("\(viewModel.numberOfPackets)")
        //                                    .font(.footnote)
        //                                    .frame(maxWidth: .infinity, alignment: .leading)
        //                            }
        //                        }
        //
        //                        Spacer().frame(height: 16)
        //                    }
        //
        //                    CheckboxSectionView(
        //                        title: DfuStrings.alternativeAdvertisingNameTitle.text,
        //                        description: DfuStrings.alternativeAdvertisingNameValue.text,
        //                        isChecked: $viewModel.alternativeAdvertisingNameEnabled
        //                    )
        //
        //                    Spacer().frame(height: 16)
        //                }
        //
        //                Text(DfuStrings.settingsSecureDfu.text)
        //                    .font(.title)
        //                    .frame(maxWidth: .infinity, alignment: .leading)
        //
        //                CheckboxSectionView(
        //                    title: DfuStrings.settingsDisableResumeTitle.text,
        //                    description: DfuStrings.settingsDisableResumeValue.text,
        //                    isChecked: $viewModel.disableResume
        //                )
        //
        //                Spacer().frame(height: 16)
        //
        //                Group {
        //                    Text(DfuStrings.settingsLegacyDfu.text)
        //                        .font(.title)
        //                        .frame(maxWidth: .infinity, alignment: .leading)
        //
        //                    CheckboxSectionView(
        //                        title: DfuStrings.settingsForceScanningTitle.text,
        //                        description: DfuStrings.settingsForceScanningValue.text,
        //                        isChecked: $viewModel.forceScanningInLegacyDfu
        //                    )
        //
        //                    Spacer().frame(height: 16)
        //
        //                    CheckboxSectionView(
        //                        title: DfuStrings.settingsExternalMcuTitle.text,
        //                        description: DfuStrings.settingsExternalMcuValue.text,
        //                        isChecked: $viewModel.externalMcuDfu
        //                    )
        //                }
        //
        //                Group {
        //                    Text(DfuStrings.settingsOther.text)
        //                        .font(.title)
        //                        .frame(maxWidth: .infinity, alignment: .leading)
        //
        //                    Spacer().frame(height: 16)
        //
        //                    Link(destination: URL(string: INFOCENTER_LINK)!) {
        //                        VStack {
        //                            Text(DfuStrings.settingsAboutTitle.text)
        //                                .font(.headline)
        //                                .frame(maxWidth: .infinity, alignment: .leading)
        //                            Text(DfuStrings.settingsAboutValue.text)
        //                                .font(.footnote)
        //                                .frame(maxWidth: .infinity, alignment: .leading)
        //                        }
        //                    }
        //
        //                    Spacer().frame(height: 16)
        //
        //                    NavigationLink(destination: WelcomeScreen(viewModel: viewModel), tag: true, selection: $showWelcomeScreen) { }
        //                    Button(action: { showWelcomeScreen = true }) {
        //                        Text(DfuStrings.settingsWelcome.text)
        //                            .font(.headline)
        //                            .frame(maxWidth: .infinity, alignment: .leading)
        //                    }
        //
        //                }
        //            }
        //            .padding()
        //            .navigationTitle(DfuStrings.settings.text)
        //
        //        }.alert(
        //            isPresented: $showingAlert,
        //            TextAlert(
        //                title: DfuStrings.numberOfPackets.text,
        //                message: DfuStrings.settingsProvideNumberOfPackets.text,
        //                keyboardType: .numberPad
        //            ) { result in
        //                if let result = result {
        //                    viewModel.numberOfPackets = Int(result) ?? viewModel.numberOfPackets
        //                }
        //             }
        //        )
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: DfuViewModel())
    }
}
