//
//  CheckboxSectionView.swift
//  dfu
//
//  Created by Nordic on 30/03/2022.
//

import SwiftUI

struct CheckboxSectionView: View {
    
    let title: String
    let description: String
    
    @Binding
    var isChecked: Bool
    
    var body: some View {
        HStack {
            VStack {
                Text(title)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                    .frame(height: 8)
                Text(description)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Toggle("", isOn: $isChecked)
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                .labelsHidden()
                .toggleStyle(.switch)
        }
    }
}

struct CheckboxSectionView_Previews: PreviewProvider {
    static var previews: some View {
        CheckboxSectionView(
            title: DfuStrings.testTitle.text,
            description: DfuStrings.testLoremIpsumLong.text,
            isChecked: .constant(true)
        )
    }
}
