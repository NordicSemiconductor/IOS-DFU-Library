//
//  ImageStyle.swift
//  dfu
//
//  Created by Nordic on 05/04/2022.
//

import SwiftUI

struct SectionImage: View {
    let image: String
    @Environment(\.isEnabled) var isEnabled
    
    var body: some View {
        Image(image)
            .renderingMode(.template)
            .foregroundColor(.white)
            .background(Circle()
                .fill(isEnabled ? ThemeColor.nordicLake.color : ThemeColor.buttonDisabledBackground.color)
                .frame(width: 40,height: 40))
    }
}
