/*
 * Copyright (c) 2016, Nordic Semiconductor
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit
import CoreBluetooth
import iOSDFULibrary

class DFUViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate {
    /// The UUID of the experimental Buttonless DFU Service from SDK 12.
    /// This service is not advertised so the app needs to connect to check if it's on the device's attribute list.
    static let ExperimentalButtonlessDfuUUID = CBUUID(string: "8E400001-F315-4F60-9FB8-838830DAEA50")

    //MARK: - Class Properties
    fileprivate var dfuPeripheral    : CBPeripheral?
    fileprivate var dfuController    : DFUServiceController?
    fileprivate var centralManager   : CBCentralManager?
    fileprivate var selectedFirmware : DFUFirmware?
    fileprivate var selectedFileURL  : URL?
    fileprivate var secureDFU        : Bool?
    
    //MARK: - View Outlets
    @IBOutlet weak var dfuActivityIndicator  : UIActivityIndicatorView!
    @IBOutlet weak var dfuStatusLabel        : UILabel!
    @IBOutlet weak var peripheralNameLabel   : UILabel!
    @IBOutlet weak var dfuUploadProgressView : UIProgressView!
    @IBOutlet weak var dfuUploadStatus       : UILabel!
    @IBOutlet weak var stopProcessButton     : UIButton!
    
    //MARK: - View Actions
    @IBAction func stopProcessButtonTapped(_ sender: AnyObject) {
        guard dfuController != nil else {
            print("No DFU peripheral was set")
            return
        }
        guard !dfuController!.aborted else {
            stopProcessButton.setTitle("Stop process", for: .normal)
            dfuController!.restart()
            return
        }
        
        print("Action: DFU paused")
        dfuController!.pause()
        let alertView = UIAlertController(title: "Warning", message: "Are you sure you want to stop the process?", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Abort", style: .destructive) {
            (action) in
            print("Action: DFU aborted")
            _ = self.dfuController!.abort()
        })
        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel) {
            (action) in
            print("Action: DFU resumed")
            self.dfuController!.resume()
        })
        present(alertView, animated: true)
    }
    
    //MARK: - Class Implementation
    func secureDFUMode(_ secureDFU: Bool?) {
        self.secureDFU = secureDFU
    }
    
    func setCentralManager(_ centralManager: CBCentralManager) {
        self.centralManager = centralManager
    }
    
    func setTargetPeripheral(_ targetPeripheral: CBPeripheral) {
        self.dfuPeripheral = targetPeripheral
    }
    
    func getBundledFirmwareURLHelper() -> URL? {
        if let secureDFU = secureDFU {
            if secureDFU {
                return Bundle.main.url(forResource: "secure_dfu_test_app_hrm_s132", withExtension: "zip")!
            } else {
                return Bundle.main.url(forResource: "hrm_legacy_dfu_with_sd_s132_2_0_0", withExtension: "zip")!
            }
        } else {
            // We need to connect and discover services. The device does not have to advertise with the service UUID.
            return nil
        }
    }
    
    func startDFUProcess() {
        guard dfuPeripheral != nil else {
            print("No DFU peripheral was set")
            return
        }

        let dfuInitiator = DFUServiceInitiator(centralManager: centralManager!, target: dfuPeripheral!)
        dfuInitiator.delegate = self
        dfuInitiator.progressDelegate = self
        dfuInitiator.logger = self
        
        // This enables the experimental Buttonless DFU feature from SDK 12.
        // Please, read the field documentation before use.
        dfuInitiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = true
        
        dfuController = dfuInitiator.with(firmware: selectedFirmware!).start()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        peripheralNameLabel.text = "Flashing \((dfuPeripheral?.name)!)..."
        dfuActivityIndicator.startAnimating()
        dfuUploadProgressView.progress = 0.0
        dfuUploadStatus.text = ""
        dfuStatusLabel.text  = ""
        stopProcessButton.isEnabled = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        selectedFileURL  = getBundledFirmwareURLHelper()
        if selectedFileURL != nil {
            selectedFirmware = DFUFirmware(urlToZipFile: selectedFileURL!)
            startDFUProcess()
        } else {
            centralManager!.delegate = self
            centralManager!.connect(dfuPeripheral!)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        _ = dfuController?.abort()
        dfuController = nil
    }

    //MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("CM did update state: \(central.state.rawValue)")
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let name = peripheral.name ?? "Unknown"
        print("Connected to peripheral: \(name)")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let name = peripheral.name ?? "Unknown"
        print("Disconnected from peripheral: \(name)")
    }
    
    //MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // Find DFU Service
        let services = peripheral.services!
        for service in services {
            if service.uuid.isEqual(ScannerViewController.legacyDfuServiceUUID) {
                secureDFU = false
                break
            } else if service.uuid.isEqual(ScannerViewController.secureDfuServiceUUID) {
                secureDFU = true
                break
            } else if service.uuid.isEqual(DFUViewController.ExperimentalButtonlessDfuUUID) {
                secureDFU = true
                break
            }
        }
        if secureDFU != nil {
            selectedFileURL  = getBundledFirmwareURLHelper()
            selectedFirmware = DFUFirmware(urlToZipFile: selectedFileURL!)
            startDFUProcess()
        } else {
            print("Disconnecting...")
            centralManager?.cancelPeripheralConnection(peripheral)
            dfuError(DFUError.deviceNotSupported, didOccurWithMessage: "Device not supported")
        }
    }

    //MARK: - DFUServiceDelegate
    
    func dfuStateDidChange(to state: DFUState) {
        switch state {
        case .completed, .disconnecting:
            self.dfuActivityIndicator.stopAnimating()
            self.dfuUploadProgressView.setProgress(0, animated: true)
            self.stopProcessButton.isEnabled = false
        case .aborted:
            self.dfuActivityIndicator.stopAnimating()
            self.dfuUploadProgressView.setProgress(0, animated: true)
            self.stopProcessButton.setTitle("Restart", for: .normal)
            self.stopProcessButton.isEnabled = true
        default:
            self.stopProcessButton.isEnabled = true
        }

        dfuStatusLabel.text = state.description()
        print("Changed state to: \(state.description())")
        
        // Forget the controller when DFU is done
        if state == .completed {
            dfuController = nil
        }
    }

    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        dfuStatusLabel.text = "Error \(error.rawValue): \(message)"
        dfuActivityIndicator.stopAnimating()
        dfuUploadProgressView.setProgress(0, animated: true)
        print("Error \(error.rawValue): \(message)")
        
        // Forget the controller when DFU finished with an error
        dfuController = nil
    }
    
    //MARK: - DFUProgressDelegate
    
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        dfuUploadProgressView.setProgress(Float(progress)/100.0, animated: true)
        dfuUploadStatus.text = String(format: "Part: %d/%d\nSpeed: %.1f KB/s\nAverage Speed: %.1f KB/s",
                                      part, totalParts, currentSpeedBytesPerSecond/1024, avgSpeedBytesPerSecond/1024)
    }

    //MARK: - LoggerDelegate
    
    func logWith(_ level: LogLevel, message: String) {
        print("\(level.name()): \(message)")
    }
}
