//
//  WelcomeScreen.swift
//  dfu
//
//  Created by Nordic on 05/04/2022.
//

import SwiftUI

struct WelcomeScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject
    var viewModel: DfuViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                Image(DfuImages.dfu.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Spacer().frame(height: 24)
                
                Text(DfuStrings.welcomeText.text)
                
                Spacer().frame(height: 24)
                
                DfuButton(title: DfuStrings.welcomeStart.text, action: {
                    self.presentationMode.wrappedValue.dismiss()
                })
            }.padding()
        }
        .navigationTitle(DfuStrings.welcomeTitle.text)
        .onAppear { viewModel.onWelcomeScreenShown() }
    }
}

struct WelcomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeScreen(viewModel: DfuViewModel())
    }
}
