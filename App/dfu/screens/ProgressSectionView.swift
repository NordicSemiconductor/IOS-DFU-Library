/*
* Copyright (c) 2022, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

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
