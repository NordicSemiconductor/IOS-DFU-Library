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
    var fileError: String? = nil
    
    @Published
    private(set) var zipFile: ZipFile? = nil
    
    @Published
    var device: BluetoothDevice? = nil
    
    @Published
    var progressSection: ProgressSectionViewEntity = ProgressSectionViewEntity()
    
    @AppStorage("packetsReceiptNotification")
    var packetsReceiptNotification: Bool = false
    
    @AppStorage("numberOfPackets")
    var numberOfPackets: Int = 23
    
    @AppStorage("alternativeAdvertisingNameEnabled")
    var alternativeAdvertisingNameEnabled: Bool = false
    
    @AppStorage("externalMcuDfu")
    var externalMcuDfu: Bool = false
    
    @AppStorage("disableResume")
    var disableResume: Bool = false
    
    @AppStorage("forceScanningInLegacyDfu")
    var forceScanningInLegacyDfu: Bool = false
    
    @AppStorage("showWelcomeScreen")
    var showWelcomeScreen: Bool = true
    
    private var controller: DFUServiceController? = nil
    
    func isFileButtonDisabled() -> Bool {
        return progressSection.isRunning()
    }
    
    func isDeviceButtonDisabled() -> Bool {
        return isFileButtonDisabled() || zipFile == nil
    }
    
    func isProgressButtonDisabled() -> Bool {
        return zipFile == nil || device == nil
    }
    
    func onFileSelected(selected file: ZipFile) throws {
        let selectedFirmware = DFUFirmware(
            urlToZipFile: file.url,
            type: DFUFirmwareType.softdeviceBootloaderApplication
        )
        
         guard let _ = selectedFirmware else {
            fileError = DfuStrings.fileError
            zipFile = nil
            return
        }
        zipFile = file
    }
    
    func install() {
        print(zipFile ?? "null")
        print(device ?? "null")
        os_log("%@", zipFile.debugDescription)
        guard zipFile!.url.startAccessingSecurityScopedResource() else { return }
        
        let selectedFirmware = DFUFirmware(
            urlToZipFile: zipFile!.url,
            type: DFUFirmwareType.softdeviceBootloaderApplication
        )
        
        guard let selectedFirmware = selectedFirmware else {
            fileError = DfuStrings.fileError
            return
        }
        
        let initiator = DFUServiceInitiator().with(firmware: selectedFirmware)

        initiator.logger = self
        initiator.delegate = self
        initiator.progressDelegate = self
        
        if packetsReceiptNotification {
            initiator.packetReceiptNotificationParameter = UInt16(numberOfPackets)
        } else {
            initiator.packetReceiptNotificationParameter = 0
        }
        
        initiator.forceScanningForNewAddressInLegacyDfu = forceScanningInLegacyDfu
        initiator.dataObjectPreparationDelay = 0.4
        initiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = true
        initiator.forceDfu = externalMcuDfu
        initiator.disableResume = disableResume
        initiator.alternativeAdvertisingNameEnabled = alternativeAdvertisingNameEnabled

        controller = initiator.start(target: device!.peripheral)
        progressSection = progressSection.toBootloaderState()
        
        zipFile!.url.stopAccessingSecurityScopedResource()
    }
    
    func onFileError(message value: String) {
        zipFile = nil
        fileError = value
    }
    
    func clearFileError() {
        fileError = nil
    }
    
    func abort() {
        if let controller = controller {
            _ = controller.abort()
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

extension DfuViewModel: LoggerDelegate {
    
    func logWith(_ level: LogLevel, message: String) {
        if #available(iOS 10.0, *) {
            os_log("%{public}@", log: category, type: level.type, message)
        } else {
            NSLog("%@", message)
        }
    }
    
}

extension LogLevel {
    
    /// Mapping from mesh log levels to system log types.
    var type: OSLogType {
        switch self {
        case .debug:       return .debug
        case .verbose:     return .debug
        case .info:        return .info
        case .application: return .default
        case .warning:     return .error
        case .error:       return .fault
        }
    }
    
}

private extension DfuViewModel {
    
    var category: OSLog {
        return OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "DFU")
    }
    
}
