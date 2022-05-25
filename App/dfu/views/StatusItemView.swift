//
//  StatusItemView.swift
//  dfu
//
//  Created by Nordic on 05/04/2022.
//

import SwiftUI

enum DfuUiStateStatus {
    case idle
    case success
    case progress
    case error
}

struct StatusItemView: View {
    
    let text: String
    let status: DfuUiStateStatus
    
    var body: some View {
        HStack {
            Image(status.image)
                .renderingMode(.template)
                .foregroundColor(status.color)
                .frame(width: 24, height: 24)
                .padding(.horizontal)
            Text(text)
            Spacer()
        }
    }
}

private extension DfuUiStateStatus {
    
    var image: String {
        switch (self) {
        case .idle:
            return DfuImages.idle.imageName
        case .success:
            return DfuImages.success.imageName
        case .progress:
            return DfuImages.progress.imageName
        case .error:
            return DfuImages.error.imageName
        }
    }

    var color: Color {
        switch (self) {
        case .idle:
            return ThemeColor.nordicDarkGray5.color
        case .success:
            return ThemeColor.nordicGreen.color
        case .progress:
            return ThemeColor.nordicDarkGray5.color
        case .error:
            return ThemeColor.error.color
        }
    }
}
