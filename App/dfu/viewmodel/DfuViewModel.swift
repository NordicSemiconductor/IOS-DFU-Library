//
//  DfuViewModel.swift
//  dfu
//
//  Created by Nordic on 28/03/2022.
//

import Foundation
import NordicDFU
import os.log
import SwiftUI

class DfuViewModel : ObservableObject, DFUProgressDelegate, DFUServiceDelegate {
    
    @Published
    var zipFile: ZipFile? = nil
    
    @Published
    var device: BluetoothDevice? = nil
    
    @Published
    var uiState: DfuUiState? = nil
    
    @Published
    var progressSection: ProgressSectionViewEntity = ProgressSectionViewEntity()
    
    @AppStorage("packetsReceiptNotification")
    var packetsReceiptNotification: Bool = false
    
    @AppStorage("numberOfPackets")
    var numberOfPackets: Int = 23
    
    @AppStorage("keepBondInformation")
    var keepBondInformation: Bool = false
    
    @AppStorage("externalMcuDfu")
    var externalMcuDfu: Bool = false
    
    @AppStorage("disableResume")
    var disableResume: Bool = false
    
    @AppStorage("forceScanningInLegacyDfu")
    var forceScanningInLegacyDfu: Bool = false
    
    @AppStorage("showWelcomeScreen")
    var showWelcomeScreen: Bool = true
    
    private var controller: DFUServiceController? = nil
    
    func install() {
        print(zipFile ?? "null")
        print(device ?? "null")
        os_log("%@", zipFile.debugDescription)
        guard zipFile!.url.startAccessingSecurityScopedResource() else { return }
        
        let selectedFirmware = DFUFirmware(urlToZipFile: zipFile!.url, type: DFUFirmwareType.application)
        
        let initiator = DFUServiceInitiator().with(firmware: selectedFirmware!)

//        initiator.logger = self
        initiator.delegate = self
        initiator.progressDelegate = self

        controller = initiator.start(target: device!.peripheral)
        progressSection = progressSection.toBootloaderState()
        
        zipFile!.url.stopAccessingSecurityScopedResource()
    }
    
    func abort() {
        if let controller = controller {
            controller.abort()
        }
    }
    
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        let progress = DfuProgress(part: part, totalParts: totalParts, progress: progress, currentSpeedBytesPerSecond: currentSpeedBytesPerSecond, avgSpeedBytesPerSecond: avgSpeedBytesPerSecond)
        progressSection = progressSection.toProgressState(updated: progress)
    }
    
    func dfuStateDidChange(to state: DFUState) {
        print("state: \(state)")
        if (state == DFUState.enablingDfuMode) {
            progressSection = progressSection.toDfuState()
        } else if (state == DFUState.completed) {
            progressSection = progressSection.toSuccessState()
        } else if (state == DFUState.aborted) {
            progressSection = progressSection.toErrorState(message: DfuUiError(error: nil, message: DfuStrings.aborted))
        }
        uiState = stateToUiState(from: state)
    }
    
    private func stateToUiState(from state: DFUState) -> DfuUiState {
        switch (state) {
        case .connecting:
            return DfuUiState.connecting
        case .starting:
            return DfuUiState.starting
        case .enablingDfuMode:
            return DfuUiState.enablingDfuMode
        case .uploading:
            return DfuUiState.uploading(DfuProgress())
        case .validating:
            return DfuUiState.validating
        case .disconnecting:
            return DfuUiState.disconnecting
        case .completed:
            return DfuUiState.completed
        case .aborted:
            return DfuUiState.aborted
        }
    }
    
    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        let error = DfuUiError(error: error, message: message)
        progressSection = progressSection.toErrorState(message: error)
    }
    
    func onWelcomeScreenShown() {
        if (showWelcomeScreen) {
            showWelcomeScreen = false
        }
    }
}
