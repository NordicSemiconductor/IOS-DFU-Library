//
//  ButtonStyle.swift
//  dfu
//
//  Created by Nordic on 05/04/2022.
//
import SwiftUI

//Copied from: https://swiftuirecipes.com/blog/custom-swiftui-button-with-disabled-and-pressed-state

struct DfuButtonStyle: ButtonStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    DfuButtonStyleView(configuration: configuration)
  }
}

private extension DfuButtonStyle {
    
  struct DfuButtonStyleView: View {
    @Environment(\.isEnabled) var isEnabled

    let configuration: DfuButtonStyle.Configuration

    var body: some View {
      return configuration.label
            .frame(minWidth: 80)
            .foregroundColor(.white)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 30)
                .fill(isEnabled ? ThemeColor.buttonEnabledBackground : ThemeColor.buttonDisabledBackground)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
  }
}

struct DfuButton: View {
  let title: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(self.title).foregroundColor(Color.white)
    }
    .buttonStyle(DfuButtonStyle())
  }
}
