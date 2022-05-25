//
//  ScannerView.swift
//  dfu
//
//  Created by Nordic on 25/03/2022.
//

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
                            Text(device.name ?? DfuStrings.withName.text)
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
