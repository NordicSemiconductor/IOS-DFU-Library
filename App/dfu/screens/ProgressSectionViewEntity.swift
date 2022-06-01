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

struct ProgressSectionViewEntity {
    let bootloaderStatus: DfuUiStateStatus
    let dfuStatus: DfuUiStateStatus
    let installationStatus: DfuInstallationStatus
    let resultStatus: DfuResultStatus
    
    func isRunning() -> Bool {
        if (bootloaderStatus != .idle) {
            if case DfuResultStatus.idle = resultStatus {
                return true
            }
        }
        return false
    }
    
    init (
        bootloaderStatus: DfuUiStateStatus = DfuUiStateStatus.idle,
        dfuStatus: DfuUiStateStatus = DfuUiStateStatus.idle,
        installationStatus: DfuInstallationStatus = DfuInstallationStatus.idle,
        resultStatus: DfuResultStatus = DfuResultStatus.idle
    ) {
        self.bootloaderStatus = bootloaderStatus
        self.dfuStatus = dfuStatus
        self.installationStatus = installationStatus
        self.resultStatus = resultStatus
    }
    
    func toBootloaderState() -> ProgressSectionViewEntity {
        return ProgressSectionViewEntity(
            bootloaderStatus: .progress,
            dfuStatus: .idle,
            installationStatus: .idle,
            resultStatus: .idle
        )
    }
    
    func toDfuState() -> ProgressSectionViewEntity {
        return ProgressSectionViewEntity(
            bootloaderStatus: .success,
            dfuStatus: .progress,
            installationStatus: .idle,
            resultStatus: .idle
        )
    }
    
    func toProgressState(updated progress: DfuProgress) -> ProgressSectionViewEntity {
        return ProgressSectionViewEntity(
            bootloaderStatus: .success,
            dfuStatus: .success,
            installationStatus: .progress(progress),
            resultStatus: .idle
        )
    }
    
    func toSuccessState() -> ProgressSectionViewEntity {
        return ProgressSectionViewEntity(
            bootloaderStatus: .success,
            dfuStatus: .success,
            installationStatus: .success,
            resultStatus: .success
        )
    }
    
    func toErrorState(message error: DfuUiError) -> ProgressSectionViewEntity {
        return ProgressSectionViewEntity(
            bootloaderStatus: switchToError(status: bootloaderStatus),
            dfuStatus: switchToError(status: dfuStatus),
            installationStatus: switchToError(status: installationStatus),
            resultStatus: .error(error)
        )
    }
    
    private func switchToError(status: DfuInstallationStatus) -> DfuInstallationStatus {
        switch (status) {
        case .success:
            return .success
        case .progress, .error, .idle:
            return .error
        }
    }
    
    private func switchToError(status: DfuUiStateStatus) -> DfuUiStateStatus {
        switch (status) {
        case .success:
            return .success
        case .progress, .error, .idle:
            return .error
        }
    }
}
