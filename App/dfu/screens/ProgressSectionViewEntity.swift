//
//  ProgressSectionViewEntity.swift
//  dfu
//
//  Created by Nordic on 05/04/2022.
//

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
