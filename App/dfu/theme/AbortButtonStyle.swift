//
//  AbortButtonStyle.swift
//  dfu
//
//  Created by Nordic on 05/04/2022.
//

import SwiftUI

//Copied from: https://swiftuirecipes.com/blog/custom-swiftui-button-with-disabled-and-pressed-state

struct AbortButtonStyle: ButtonStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    AbortButtonStyleView(configuration: configuration)
  }
}

private extension AbortButtonStyle {
    
  struct AbortButtonStyleView: View {
    @Environment(\.isEnabled) var isEnabled

    let configuration: AbortButtonStyle.Configuration

    var body: some View {
      return configuration.label
            .foregroundColor(.white)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 30).fill(ThemeColor.error))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
  }
}

struct AbortButton: View {
  let title: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(self.title).foregroundColor(Color.white)
    }.buttonStyle(AbortButtonStyle())
  }
}

