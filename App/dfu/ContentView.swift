//
//  ContentView.swift
//  dfu
//
//  Created by Nordic on 23/03/2022.
//

import SwiftUI
import os.log

struct ContentView: View {
    
    let bleManager: BluetoothManager = BluetoothManager()
    
    @StateObject
    var viewModel = DfuViewModel()
    
    @State
    private var showWelcomeScreen: Bool?
    
    var body: some View {
        ScrollView {
            Section {
                VStack {
                    NavigationLink(destination: WelcomeScreen(viewModel: viewModel), tag: true, selection: $showWelcomeScreen) { }
                    
                    FileSectionView(viewModel: viewModel)
                    
                    DeviceSectionView(viewModel: viewModel)
                    
                    ProgressSectionView(viewModel: viewModel)
                }.padding()
            }
            .navigationTitle(DfuStrings.dfuTitle)
            .navigationBarItems(trailing:
                NavigationLink(destination: SettingsView(viewModel: viewModel)) {
                    Text(DfuStrings.settings)
                }
            )
            Spacer()
        }.onAppear {
            if viewModel.showWelcomeScreen {
                showWelcomeScreen = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
