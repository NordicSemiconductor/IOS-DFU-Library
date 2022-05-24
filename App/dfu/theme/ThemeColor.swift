//
//  ThemeColor.swift
//  dfu
//
//  Created by Nordic on 05/04/2022.
//

import SwiftUI

//TODO: migrate to enum
enum ThemeColor : String {
    case nordicLake = "NordicLake"
    case nordicBlue = "NordicBlue"
    case nordicGreen = "NordicGreen"
    case nordicDarkGray5 = "NordicDarkGrey5"
    case buttonDisabledBackground = "NordicLightGray"
    case nordicRed = "NordicRed"
    case nordicYellow = "NordicYellow"
    
    static let buttonEnabledBackground = ThemeColor.nordicBlue
    static let error = ThemeColor.nordicRed
    
    var color: Color {
        Color(rawValue)
    }
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
