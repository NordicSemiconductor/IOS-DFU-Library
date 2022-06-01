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

struct ContentView: View {
    
    private let bleManager: BluetoothManager = BluetoothManager()
    
    //can be put as Environment
    @StateObject private var viewModel = DfuViewModel()
    
    @State private var showWelcomeScreen: Bool?
    
    var body: some View {
        ScrollView {
            Section {
                VStack {
                    NavigationLink(destination: WelcomeScreen(viewModel: viewModel), tag: true, selection: $showWelcomeScreen) {
                        EmptyView()
                    }.hidden()
                    
                    FileSectionView(viewModel: viewModel)
                    
                    DeviceSectionView(viewModel: viewModel)
                    
                    ProgressSectionView(viewModel: viewModel)
                }.padding()
            }
            .navigationTitle(DfuStrings.dfuTitle.text)
            .navigationBarItems(trailing:
                NavigationLink(destination: SettingsView(viewModel: viewModel)) {
                    Text(DfuStrings.settings.text)
                }
                .accessibilityIdentifier(DfuIds.settingsButton.rawValue)
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
