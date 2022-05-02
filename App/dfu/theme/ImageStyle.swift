//
//  ImageStyole.swift
//  dfu
//
//  Created by Nordic on 05/04/2022.
//

import SwiftUI

struct SectionImage: View {
    let image: String
    
    var body: some View {
        return Image(image)
            .renderingMode(.template)
            .foregroundColor(.white)
            .background(Circle().fill(ThemeColor.nordicLake).frame(width: 40,height: 40))
    }
}
