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
            ForEach(bluetoothManager.filteredDevices()) { device in
                Button(action: {
                    viewModel.device = device
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(device.name).frame(maxWidth: .infinity, alignment: .leading)
                        SignalStrengthIndicator(signalStrength: device.getSignalStrength())
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .navigationTitle(DfuStrings.scanner)
        .onAppear { bluetoothManager.startScan() }
        .onDisappear { bluetoothManager.stopScan() }
        .toolbar {
            Toggle(DfuStrings.nearbyOnly, isOn: $bluetoothManager.nearbyOnlyFilter)
                .toggleStyle(.switch)
                .onChange(of: bluetoothManager.nearbyOnlyFilter) { value in
                    bluetoothManager.nearbyOnlyFilter = value
                }
        }
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView(viewModel: DfuViewModel())
    }
}
