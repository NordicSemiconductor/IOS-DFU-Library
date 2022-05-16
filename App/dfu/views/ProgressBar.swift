//
//  ProgressBar.swift
//  dfu
//
//  Created by Nordic on 16/05/2022.
//

import Foundation
import SwiftUI

struct ProgressBar: View {
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 5.0)
                .opacity(0.3)
                .foregroundColor(ThemeColor.nordicBlue)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(0.3, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 5.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.red)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(Animation.linear(duration: 2.0).repeatForever())
        }.frame(width: 24, height: 24)
    }
}
