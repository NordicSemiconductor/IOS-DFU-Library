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

struct WelcomeScreen: View {
    let nrfCDM = "https://apps.apple.com/us/app/nrf-connect-device-manager/id1519423539"
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: DfuViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                Image(DfuImages.dfu.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 300)
                
                Spacer()
                
                Text(DfuStrings.welcomeText.text)
                
                Link(destination: URL(string: nrfCDM)!) {
                    HStack {
                        Text(DfuStrings.welcomeNote.text)
                        Image(systemName: DfuImages.launch.imageName)
                            .padding(.leading)
                    }
                    .padding()
                    .foregroundColor(.primary)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.orange)
                            .opacity(0.3)
                    )
                }
                
                Spacer(minLength: 24)
                
                Button(DfuStrings.welcomeStart.text) {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(DfuButtonStyle())
            }
            .padding()
        }
        .navigationTitle(DfuStrings.welcomeTitle.text)
        .onAppear { viewModel.welcomeScreenDidShow() }
    }
}

struct WelcomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeScreen(viewModel: DfuViewModel())
    }
}
