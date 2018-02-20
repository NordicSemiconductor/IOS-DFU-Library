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

class DFUViewController: UIViewController, CBCentralManagerDelegate, DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate {
    //MARK: - Class Properties
    private var dfuPeripheral    : CBPeripheral!
    private var peripheralName   : String?
    private var dfuController    : DFUServiceController!
    private var centralManager   : CBCentralManager!
    private var firmwareProvider : DFUFirmwareProvider!
    private var partsCompleted   : Int = 0
    private var currentFirmwarePartsCompleted : Int = 0
    private var firstPartRatio   : Float = 1.0
    private var timer            : Timer!
    private var startTime        : Date!
    private var stepStartTime    : Date?
    
    //MARK: - View Outlets
    @IBOutlet weak var totalProgressView     : UIProgressView!
    @IBOutlet weak var stepProgressView      : UIProgressView!
    @IBOutlet weak var partProgressView : UIProgressView!
    @IBOutlet weak var dfuStatusLabel        : UILabel!
    @IBOutlet weak var partLabel             : UILabel!
    //@IBOutlet weak var currentSpeedLabel     : UILabel!
    @IBOutlet weak var averageSpeedLabel     : UILabel!
    @IBOutlet weak var stepDescriptionLabel  : UILabel!
    @IBOutlet weak var completedStepsLabel   : UILabel!
    @IBOutlet weak var stopProcessButton     : UIButton!
    @IBOutlet weak var totalTimerLabel       : UILabel!
    @IBOutlet weak var stepTimerLabel        : UILabel!
    
    //MARK: - View Actions
    
    @IBAction func stopProcessButtonTapped(_ sender: AnyObject) {
        guard dfuController != nil else {
            print("No DFU peripheral was set")
            return
        }
        guard !dfuController!.aborted else {
            stopProcessButton.setTitle("Stop process", for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(DFUViewController.updateTimer), userInfo: nil, repeats: true)
            dfuController!.restart()
            return
        }
        
        print("Action: DFU paused")
        dfuController!.pause()
        let alertView = UIAlertController(title: "Warning", message: "Are you sure you want to stop the process?", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Abort", style: .destructive) { action in
            print("Action: DFU aborted")
            _ = self.dfuController!.abort()
        })
        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            print("Action: DFU resumed")
            self.dfuController!.resume()
        })
        present(alertView, animated: true)
    }
    
    //MARK: - Class Implementation
    
    func setCentralManager(_ centralManager: CBCentralManager) {
        self.centralManager = centralManager
    }
    
    func setTargetPeripheral(_ targetPeripheral: CBPeripheral, withName name: String?) {
        self.dfuPeripheral    = targetPeripheral
        self.peripheralName   = name
        self.firmwareProvider = DFUFirmwareProvider.get(byName: name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let firmware = firmwareProvider.firmware {
            dfuStatusLabel.text = ""
            partLabel.text = "1 / \(firmware.parts)"
            
            startTime = Date()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(DFUViewController.updateTimer), userInfo: nil, repeats: true)
            updateTimer()
        } else {
            dfuStatusLabel.text = "No firmware found"
            partLabel.text = "N/A"
        }
        totalProgressView.progress = 0.0
        stepProgressView.progress = 0.0
        partProgressView.progress = 0.0
        stepDescriptionLabel.text = ""
        completedStepsLabel.text = ""
        //currentSpeedLabel.text = ""
        averageSpeedLabel.text = ""
        stopProcessButton.isEnabled = false
        
        startDFUProcess()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Cancel test only when going back to Scanner. If Home button is clicked the test will continue in the background.
        if isMovingFromParentViewController {
            stopTimer()
            _ = dfuController?.abort()
            dfuController = nil
        }
    }
    
    @objc private func updateTimer() {
        let timeDiff = -Int(startTime.timeIntervalSinceNow)
        totalTimerLabel.text = String(format: "%d:%02d", timeDiff / 60, timeDiff % 60)
        
        if let stepStartTime = stepStartTime {
            let stepTimeDiff = -Int(stepStartTime.timeIntervalSinceNow)
            stepTimerLabel.text = String(format: "%d:%02d", stepTimeDiff / 60, stepTimeDiff % 60)
        }
    }
    
    private func stopTimer() {
        timer.invalidate()
    }
    
    //MARK: - DFU Methods
    
    func startDFUProcess() {
        guard let dfuPeripheral = dfuPeripheral else {
            print("No DFU peripheral was set")
            return
        }
        guard let firmware = firmwareProvider.firmware else {
            print("No firmware found. Check your Test Set")
            return
        }
        
        // Calculate the first part ratio. It will be used to estimate the step progress view state.
        if firmware.parts > 1 {
            firstPartRatio = Float(firmware.size.softdevice + firmware.size.bootloader) /
                Float(firmware.size.softdevice + firmware.size.bootloader + firmware.size.application)
        } else {
            firstPartRatio = 1.0
        }
        
        // Update UI
        stepStartTime = Date()
        stepTimerLabel.text = "0:00"
        stepDescriptionLabel.text = firmwareProvider.description
        stepProgressView.progress = 0.0
        partProgressView.progress = 0.0
        
        // Create DFU initiator with some default configuration
        let dfuInitiator = DFUServiceInitiator(centralManager: centralManager, target: dfuPeripheral)
        dfuInitiator.delegate = self
        dfuInitiator.progressDelegate = self
        dfuInitiator.logger = self
        // Starting from iOS 11 and macOS 10.13 there is a new API that removes the need of PRNs.
        // However, some devices may still work better with them enabled! A specially those
        // based on SDK older than 8.0 where the flash saving was slower and modern phones
        // can send data faster then that which causes the DFU bootloader to abort with an error.
        if #available(iOS 11.0, macOS 10.13, *) {
            dfuInitiator.packetReceiptNotificationParameter = 0
        }
        
        // Apply step's modifications to the DFU initiator
        firmwareProvider.applyModifier(to: dfuInitiator)
        
        dfuController = dfuInitiator.with(firmware: firmware).start()
    }
    
    func prepareNextStep() {
        stepDescriptionLabel.text = "Scanning for next target"
        centralManager.delegate = self
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    //MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // TODO:
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Using the step filter, look for next target
        if firmwareProvider.filter!(advertisementData) {
            // We found it!
            
            // Stop scanning
            centralManager.stopScan()
            
            currentFirmwarePartsCompleted = 0
            dfuPeripheral = peripheral
            firmwareProvider.next()
            startDFUProcess()
        }
    }

    //MARK: - DFUServiceDelegate
    
    func dfuStateDidChange(to state: DFUState) {
        switch state {
        case .completed, .disconnecting:
            stopProcessButton.isEnabled = false
        case .aborted:
            stopTimer()
            averageSpeedLabel.text = ""
            stopProcessButton.setTitle("Restart", for: .normal)
            stopProcessButton.isEnabled = true
        case .connecting:
            partProgressView.setProgress(0, animated: false)
            stopProcessButton.isEnabled = true
        default:
            stopProcessButton.isEnabled = true
        }

        dfuStatusLabel.text = state.description()
        print("State changed to: \(state.description())")
        
        // Forget the controller when DFU is done
        if state == .completed {
            dfuController = nil
            
            // Increment the parts counter
            currentFirmwarePartsCompleted += 1
            partsCompleted += 1
            
            partLabel.text = "N/A"
            //currentSpeedLabel.text = ""
            averageSpeedLabel.text = ""
            
            addStepToCompleted(success: true)
            
            if firmwareProvider.hasNext() {
                if firmwareProvider.expectedError == nil {
                    prepareNextStep()
                } else {
                    stepDescriptionLabel.text = "Step completed but error \(firmwareProvider.expectedError!.rawValue) was expected"
                }
            } else {
                stopTimer()
                stepDescriptionLabel.text = "Test finished"
            }
        }
    }

    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        dfuStatusLabel.text = "Error \(error.rawValue): \(message)"
        print("Error \(error.rawValue): \(message)")
        
        // Forget the controller when DFU finished with an error
        dfuController = nil
        
        // If expected error was returned, continue with next test
        if let expectedError = firmwareProvider.expectedError {
            if expectedError == error {
                // Increment the parts counter
                partsCompleted += firmwareProvider.firmware!.parts - currentFirmwarePartsCompleted
                
                // Update the total progress view
                let totalProgress = Float(partsCompleted) / Float(firmwareProvider.totalParts)
                totalProgressView.setProgress(totalProgress, animated: true)
                
                addStepToCompleted(success: false)
                
                if firmwareProvider.hasNext() {
                    prepareNextStep()
                } else {
                    stepDescriptionLabel.text = "Test finished"
                }
            } else {
                stopTimer()
                stepDescriptionLabel.text = "Step failed with error \(error.rawValue) but \(firmwareProvider.expectedError!.rawValue) was expected"
            }
        }
    }
    
    private func addStepToCompleted(success: Bool) {
        let mark = success ? "✓" : "✕"
        completedStepsLabel.text = "\(mark) \(firmwareProvider.description!) (\(stepTimerLabel.text!))\n\(completedStepsLabel.text!)"
        stepTimerLabel.text = ""
        stepStartTime = nil
    }
    
    //MARK: - DFUProgressDelegate
    
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        // Update the total progress view
        let totalProgress = (Float(partsCompleted) + (Float(progress) / 100.0)) / Float(firmwareProvider.totalParts)
        totalProgressView.setProgress(totalProgress, animated: true)
        
        // Update step progress view
        let stepProgress = part < totalParts || totalParts == 1 ?
            firstPartRatio * Float(progress) / 100.0 :
            firstPartRatio + (1.0 - firstPartRatio) * Float(progress) / 100.0
        stepProgressView.setProgress(stepProgress, animated: true)
        
        // Increment the parts counter for 2-part uploads
        if progress == 100 && part == 1 && totalParts == 2 {
            currentFirmwarePartsCompleted += 1
            partsCompleted += 1
        }
        
        // Update views for current update
        partProgressView.setProgress(Float(progress) / 100.0, animated: Float(progress) > partProgressView.progress)
        partLabel.text = "\(part) / \(totalParts)"
        //currentSpeedLabel.text = String(format: "%.1f KB/s", currentSpeedBytesPerSecond / 1024)
        averageSpeedLabel.text = String(format: "%.1f KB/s", avgSpeedBytesPerSecond / 1024)
    }

    //MARK: - LoggerDelegate
    
    func logWith(_ level: LogLevel, message: String) {
        //if level.rawValue >= LogLevel.application.rawValue {
            print("\(level.name()): \(message)")
        //}
    }
}
