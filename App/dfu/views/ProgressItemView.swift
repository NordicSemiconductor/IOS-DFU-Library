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
                        let formatted = String(format: DfuStrings.firmwareUploadSpeed.rawValue, p.avgSpeed())
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
            return DfuStrings.firmwareUpload.text
        case .success:
            return DfuStrings.firmwareUploaded.rawValue
        case .progress(let p):
            if (p.totalParts == 1) {
                return DfuStrings.firmwareUploading.rawValue
            } else {
                return String(format: DfuStrings.firmwareUploadPart.rawValue, p.part, p.totalParts)
            }
        }
    }
}

private extension DfuInstallationStatus {
    
    //TODO: change to property
    func getImage() -> String {
        switch (self) {
        case .idle:
            return DfuImages.idle.rawValue
        case .success:
            return DfuImages.success.rawValue
        case .progress:
            return DfuImages.progress.rawValue
        case .error:
            return DfuImages.error.rawValue
        }
    }

    func getColor() -> Color {
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
