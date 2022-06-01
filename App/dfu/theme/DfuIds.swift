//
//  DfuIds.swift
//  dfu
//
//  Created by Nordic on 27/05/2022.
//

import Foundation

enum DfuIds : String {
    
    case settingsButton = "SettingsButton"
    case welcomeButton = "WelcomeButton"
    
    var id: String {
        rawValue
    }
}
