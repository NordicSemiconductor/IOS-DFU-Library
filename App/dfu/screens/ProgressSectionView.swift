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
                SectionImage(image: DfuImages.upload)
                Text(DfuStrings.progress)
                    .padding()
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if (viewModel.progressSection.isRunning()) {
                    AbortButton(title: DfuStrings.abort, action: {
                        viewModel.abort()
                    })
                } else {
                    DfuButton(title: DfuStrings.upload, action: {
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
            return DfuStrings.bootloaderIdle
        case .success:
            return DfuStrings.bootloaderFinished
        case .progress:
            return DfuStrings.bootloaderInProgress
        }
    }
    
    func getDfuString() -> String {
        switch (self) {
        case .idle, .error:
            return DfuStrings.dfuIdle
        case .success:
            return DfuStrings.dfuFinished
        case .progress:
            return DfuStrings.dfuInProgress
        }
    }
}

struct ProgressSectionView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressSectionView(viewModel: DfuViewModel())
    }
}
