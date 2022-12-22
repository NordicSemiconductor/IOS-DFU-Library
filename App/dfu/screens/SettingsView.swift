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

private let INFOCENTER_LINK = "https://infocenter.nordicsemi.com/topic/sdk_nrf5_v17.1.0/examples_bootloader.html"

struct SettingsView: View {
    
    @ObservedObject var viewModel: DfuViewModel
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var prn: String = ""
    
    @State private var showingAlert: Bool = false
    
    @State private var showingNumberOfPacketsDialog: Bool = false
    
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
                            title = DfuStrings.settingsPacketReceiptTitle.text
                            description = DfuStrings.settingsPacketReceiptValue.text
                            showingAlert = true
                        }
                }
                
                HStack {
                    Text(DfuStrings.numberOfPackets.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: { showingNumberOfPacketsDialog = true }) {
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
                            title = DfuStrings.alternativeAdvertisingNameTitle.text
                            description = DfuStrings.alternativeAdvertisingNameValue.text
                            showingAlert = true
                        }
                }
            }
            
            Section(DfuStrings.settingsSecureDfu.text) {
                HStack {
                    Toggle(isOn: $viewModel.disableResume) {
                        Text(DfuStrings.settingsDisableResumeTitle.text)
                    }
                    .tint(ThemeColor.nordicBlue.color)
                    
                    Image(systemName: DfuImages.info.imageName)
                        .foregroundColor(ThemeColor.nordicBlue.color)
                        .onTapGesture {
                            title = DfuStrings.settingsDisableResumeTitle.text
                            description = DfuStrings.settingsDisableResumeValue.text
                            showingAlert = true
                        }
                }
            }
            
            Section(DfuStrings.settingsLegacyDfu.text) {
                HStack {
                    Toggle(isOn: $viewModel.forceScanningInLegacyDfu) {
                        Text(DfuStrings.settingsForceScanningTitle.text)
                    }
                    .tint(ThemeColor.nordicBlue.color)
                    
                    Image(systemName: DfuImages.info.imageName)
                        .foregroundColor(ThemeColor.nordicBlue.color)
                        .onTapGesture {
                            title = DfuStrings.settingsForceScanningTitle.text
                            description = DfuStrings.settingsForceScanningValue.text
                            showingAlert = true
                        }
                }
                
                HStack {
                    Toggle(isOn: $viewModel.externalMcuDfu) {
                        Text(DfuStrings.settingsExternalMcuTitle.text)
                    }
                    .tint(ThemeColor.nordicBlue.color)
                    
                    Image(systemName: DfuImages.info.imageName)
                        .foregroundColor(ThemeColor.nordicBlue.color)
                        .onTapGesture {
                            title = DfuStrings.settingsExternalMcuTitle.text
                            description = DfuStrings.settingsExternalMcuValue.text
                            showingAlert = true
                        }
                }
            }
            
            Section(DfuStrings.settingsOther.text) {
                Link(DfuStrings.settingsAboutTitle.text, destination: URL(string: INFOCENTER_LINK)!)
                
                NavigationLink(DfuStrings.settingsWelcome.text) {
                    WelcomeScreen(viewModel: viewModel)
                }
                .accessibilityIdentifier(DfuIds.welcomeButton.rawValue)
            }
        }
        .navigationTitle(DfuStrings.settings.text)
        .onAppear {
            prn = "\(viewModel.numberOfPackets)"
        }
        .alert(title, isPresented: $showingAlert,
            actions: {
                Button(DfuStrings.ok.text, role: .cancel) {}
            },
            message: {
                Text(description)
            }
        )
        .alert(DfuStrings.numberOfPackets.text, isPresented: $showingNumberOfPacketsDialog,
            actions: {
                TextField("E.g. 12", text: $prn.limit(5))
                    .keyboardType(.numberPad)
                Button(DfuStrings.cancel.text, role: .cancel) {}
                Button(DfuStrings.ok.text) {
                    guard let prn = Int(prn) else { return }
                    viewModel.numberOfPackets = prn
                }
            },
            message: {
                Text(DfuStrings.settingsProvideNumberOfPackets.text)
            }
        )
    }
}

extension Binding where Value == String {
    
    func limit(_ limit: Int) -> Self {
        if wrappedValue.count > limit {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.dropLast())
            }
        }
        return self
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView(viewModel: DfuViewModel())
        }.navigationViewStyle(.stack)
    }
}
