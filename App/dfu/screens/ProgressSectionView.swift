//
//  PregressSectionView.swift
//  dfu
//
//  Created by Nordic on 23/03/2022.
//

import SwiftUI

struct ProgressSectionView: View {
    
    @ObservedObject
    var viewModel: DfuViewModel
    
    var body: some View {
        VStack {
            HStack {
                SectionImage(image: DfuImages.upload.rawValue)
                Text(DfuStrings.progress.text)
                    .padding()
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if (viewModel.progressSection.isRunning()) {
                    AbortButton(title: DfuStrings.abort.rawValue, action: {
                        viewModel.abort()
                    })
                } else {
                    DfuButton(title: DfuStrings.upload.rawValue, action: {
                        viewModel.install()
                    })
                }
            }.padding()
            
            let bootloaderStatus = viewModel.progressSection.bootloaderStatus
            StatusItemView(text: bootloaderStatus.getBootloaderString(), status: bootloaderStatus)
            
            let dfuStatus = viewModel.progressSection.dfuStatus
            StatusItemView(text: dfuStatus.getDfuString(), status: dfuStatus)
            
            let installationStatus = viewModel.progressSection.installationStatus
            ProgressItemView(status: installationStatus)
            
            let result = viewModel.progressSection.resultStatus
            ResultItemView(status: result)
            
        }.disabled(viewModel.isProgressButtonDisabled())
    }
}

private extension DfuUiStateStatus {
    
    func getBootloaderString() -> String {
        switch (self) {
        case .idle, .error:
            return DfuStrings.bootloaderIdle.rawValue
        case .success:
            return DfuStrings.bootloaderFinished.rawValue
        case .progress:
            return DfuStrings.bootloaderInProgress.rawValue
        }
    }
    
    func getDfuString() -> String {
        switch (self) {
        case .idle, .error:
            return DfuStrings.dfuIdle.rawValue
        case .success:
            return DfuStrings.dfuFinished.rawValue
        case .progress:
            return DfuStrings.dfuInProgress.rawValue
        }
    }
}

struct ProgressSectionView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressSectionView(viewModel: DfuViewModel())
    }
}
