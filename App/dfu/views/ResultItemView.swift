//
//  ResultItemView.swift
//  dfu
//
//  Created by Nordic on 05/04/2022.
//

import SwiftUI

enum DfuResultStatus {
    case idle
    case success
    case error(DfuUiError)
}

struct ResultItemView: View {
    
    let status: DfuResultStatus
    
    var body: some View {
        HStack {
            Image(status.image)
                .renderingMode(.template)
                .foregroundColor(status.color)
                .frame(width: 24, height: 24)
                .padding(.horizontal)
            Text(getResultString())
            Spacer()
        }
    }
    
    func getResultString() -> String {
        switch (status) {
        case .idle, .success:
            return DfuStrings.resultCompleted.text
        case .error(let error):
            return String(format: DfuStrings.resultError.text, error.message)
        }
    }
}

private extension DfuResultStatus {
    
    var image: String {
        switch (self) {
        case .idle:
            return DfuImages.idle.imageName
        case .success:
            return DfuImages.success.imageName
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
        case .error:
            return ThemeColor.error.color
        }
    }
}
