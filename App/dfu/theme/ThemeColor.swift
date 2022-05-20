//
//  ThemeColor.swift
//  dfu
//
//  Created by Nordic on 05/04/2022.
//

import SwiftUI

struct ThemeColor {
    static let error = Color("NordicRed")
    static let nordicLake = Color("NordicLake")
    static let nordicBlue = Color("NordicBlue")
    static let nordicGreen = Color("NordicGreen")
    static let nordicDarkGray5 = Color("NordicDarkGrey5")
    static let buttonDisabledBackground = Color.gray
    static let buttonEnabledBackground = nordicBlue
    static let nordicRed = Color("NordicRed")
    static let nordicYellow = Color("NordicYellow")
}

extension View {
    
    func circleBackground() -> some View {
        if (Environment(\.isEnabled).wrappedValue) {
            return background(Circle().fill(Color.blue).frame(width: 40,height: 40))
        } else {
            return background(Circle().fill(Color.gray).frame(width: 40,height: 40))
        }
    }
}


