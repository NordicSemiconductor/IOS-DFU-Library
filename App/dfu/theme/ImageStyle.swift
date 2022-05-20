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
        var backgroundColor: Color
        if (isEnabled) {
            backgroundColor = ThemeColor.nordicLake
        } else {
            backgroundColor = ThemeColor.buttonDisabledBackground
        }
        return Image(image)
            .renderingMode(.template)
            .foregroundColor(.white)
            .background(Circle().fill(backgroundColor).frame(width: 40,height: 40))
    }
}
