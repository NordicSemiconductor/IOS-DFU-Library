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

struct NumberOfPacketsDialog: View {
    
    @Binding
    var isShowing: Bool
    
    @Binding
    var value: Int
    
    @State
    var input = NumbersOnlyField()
    
    var body: some View {
        HStack {
            VStack {
                Text(DfuStrings.numberOfPackets.text)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                    .frame(height: 8)
                Text(DfuStrings.numberRequest.text)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField(DfuStrings.numberOfPackets.text, text: $input.value)
                    .padding()
                    .keyboardType(.decimalPad)
                
                HStack {
                    Button(action: { isShowing = false }) {
                        Text(DfuStrings.cancel.text)
                    }
                    Button(action: { isShowing = false }) {
                        Text(DfuStrings.ok.text)
                    }
                }
            }
        }
    }
}

class NumbersOnlyField: ObservableObject {
    @Published var value = "" {
        didSet {
            let filtered = value.filter { $0.isNumber }
            
            if value != filtered {
                value = filtered
            }
        }
    }
}

struct NumberOfPacketsDialog_Previews: PreviewProvider {
    static var previews: some View {
        NumberOfPacketsDialog(
            isShowing: .constant(true),
            value: .constant(2)
        )
    }
}
