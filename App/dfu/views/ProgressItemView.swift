//
//  ProgressItemView.swift
//  dfu
//
//  Created by Nordic on 31/03/2022.
//

import SwiftUI

enum DfuInstallationStatus {
    case idle
    case success
    case progress(DfuProgress)
    case error
}

struct ProgressItemView: View {

    let status: DfuInstallationStatus
    
    var body: some View {
        VStack {
            HStack {
                Image(status.getImage())
                    .renderingMode(.template)
                    .foregroundColor(status.getColor())
                    .frame(width: 24, height: 24)
                    .padding(.horizontal)
                Text(getInstallationString())
                Spacer()
            }
            if case .progress(let p) = status {
                HStack {
                    Spacer().frame(width: 50)
                    VStack {
                        ProgressView(value: p.percantageProgress())
                        let formatted = String(format: DfuStrings.firmwareUploadSpeed, p.avgSpeed())
                        Text(formatted)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }.padding(.horizontal)
                }
            }
        }
    }
    
    func getInstallationString() -> String {
        switch (status) {
        case .idle, .error:
            return DfuStrings.firmwareUpload
        case .success:
            return DfuStrings.firmwareUploaded
        case .progress(let p):
            if (p.totalParts == 1) {
                return DfuStrings.firmwareUploading
            } else {
                return String(format: DfuStrings.firmwareUploadPart, p.part, p.totalParts)
            }
        }
    }
}

private extension DfuInstallationStatus {
    
    func getImage() -> String {
        switch (self) {
        case .idle:
            return DfuImages.idle
        case .success:
            return DfuImages.success
        case .progress:
            return DfuImages.progress
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
        case .progress:
            return ThemeColor.nordicDarkGray5
        case .error:
            return ThemeColor.error
        }
    }
}
