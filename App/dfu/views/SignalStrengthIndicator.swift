//
//  SignalStrengthIndicator.swift
//  dfu
//
//  Created by Nordic on 18/05/2022.
//

import Foundation
import SwiftUI

struct SignalStrengthIndicator: View {
    let signalStrength: SignalStrength
    let totalBars: Int = 3
    
    var body: some View {
        HStack {
            ForEach(0..<totalBars) { bar in
                RoundedRectangle(cornerRadius: 3)
                    .divided(amount: (CGFloat(bar) + 1) / CGFloat(self.totalBars))
                    .fill(getColor().opacity(bar <= signalStrength.rawValue ? 1 : 0.3))
                    .frame(width: 8, height: 24)
            }
        }
    }
    
    private func getColor() -> Color {
        switch signalStrength {
        case .weak:
            return ThemeColor.nordicRed.color
        case .normal:
            return ThemeColor.nordicYellow.color
        case .strong:
            return ThemeColor.nordicGreen.color
        }
    }
}

struct Divided<S: Shape>: Shape {
    var amount: CGFloat // Should be in range 0...1
    var shape: S
    func path(in rect: CGRect) -> Path {
        shape.path(in: rect.divided(atDistance: amount * rect.height, from: .maxYEdge).slice)
    }
}

extension Shape {
    func divided(amount: CGFloat) -> Divided<Self> {
        return Divided(amount: amount, shape: self)
    }
}

enum SignalStrength : Int {
    case weak = 0
    case normal = 1
    case strong = 2
}
