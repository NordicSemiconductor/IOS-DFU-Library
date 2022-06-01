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
import os.log
import CoreBluetooth

struct ScannerView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject
    var viewModel: DfuViewModel
    
    @StateObject
    var bluetoothManager: BluetoothManager = BluetoothManager()
    
    var body: some View {
        List {
            Section(header: Text(DfuStrings.filters.text)) {
                HStack {
                    Toggle(DfuStrings.nearbyOnly.text, isOn: $bluetoothManager.nearbyOnlyFilter)
                        .toggleStyle(.switch)
                        .onChange(of: bluetoothManager.nearbyOnlyFilter) { value in
                            bluetoothManager.nearbyOnlyFilter = value
                        }
                    
                    Spacer().frame(width: 16)
                    
                    Toggle(DfuStrings.withName.text, isOn: $bluetoothManager.withNameOnlyFilter)
                        .toggleStyle(.switch)
                        .onChange(of: bluetoothManager.withNameOnlyFilter) { value in
                            bluetoothManager.withNameOnlyFilter = value
                        }
                }.padding(.horizontal)
            }

            Section(header: Text(DfuStrings.devices.text)) {
                ForEach(bluetoothManager.filteredDevices()) { device in
                    Button(action: {
                        viewModel.device = device
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text(device.name ?? DfuStrings.noName.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            SignalStrengthIndicator(signalStrength: device.getSignalStrength())
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .navigationTitle(DfuStrings.scanner.text)
        .onAppear { bluetoothManager.startScan() } //call every time view is redrawn | we can test it with logger
        .onDisappear { bluetoothManager.stopScan() }
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView(viewModel: DfuViewModel())
    }
}
