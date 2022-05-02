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
            Image(status.getImage())
                .renderingMode(.template)
                .foregroundColor(status.getColor())
                .frame(width: 24, height: 24)
                .padding(.horizontal)
            Text(getResultString())
            Spacer()
        }
    }
    
    func getResultString() -> String {
        switch (status) {
        case .idle, .success:
            return DfuStrings.resultCompleted
        case .error(let error):
            return String(format: DfuStrings.resultError, error.message)
        }
    }
}

private extension DfuResultStatus {
    
    func getImage() -> String {
        switch (self) {
        case .idle:
            return DfuImages.idle
        case .success:
            return DfuImages.success
        case .error:
            return DfuImages.error
        }
    }

    func getColor() -> Color {
        switch (self) {
        case .idle:
            return ThemeColor.nordicDarkGray5
        case .success:
            return ThemeColor.nordicGreen
        case .error:
            return ThemeColor.error
        }
    }
}
