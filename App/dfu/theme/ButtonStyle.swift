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

//Ref: https://swiftuirecipes.com/blog/custom-swiftui-button-with-disabled-and-pressed-state

struct DfuButtonStyle: ButtonStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    DfuButtonStyleView(configuration: configuration)
  }
}

private extension DfuButtonStyle {
    
  struct DfuButtonStyleView: View {
    @Environment(\.isEnabled) var isEnabled

    let configuration: DfuButtonStyle.Configuration

    var body: some View {
      configuration.label
            .frame(minWidth: 80)
            .foregroundColor(.white)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 30)
                .fill(isEnabled ? ThemeColor.buttonEnabledBackground.color : ThemeColor.buttonDisabledBackground.color)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
  }
}

struct DfuButton: View {
  let title: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(self.title).foregroundColor(Color.white)
    }
    .buttonStyle(DfuButtonStyle())
  }
}
