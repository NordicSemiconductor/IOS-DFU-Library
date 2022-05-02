//
//  InputDigitDialog.swift
//  dfu
//
//  Created by Nordic on 30/03/2022.
//

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
                Text(DfuStrings.numberOfPackets)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                    .frame(height: 8)
                Text(DfuStrings.numberRequest)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField(DfuStrings.numberOfPackets, text: $input.value)
                    .padding()
                    .keyboardType(.decimalPad)
                
                HStack {
                    Button(action: { isShowing = false }) {
                        Text(DfuStrings.cancel)
                    }
                    Button(action: { isShowing = false }) {
                        Text(DfuStrings.ok)
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
