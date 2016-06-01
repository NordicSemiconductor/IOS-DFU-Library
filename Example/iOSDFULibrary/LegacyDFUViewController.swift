//
//  DFUViewController.swift
//  iOSDFULibrary
//
//  Created by Mosdafa on 01/06/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import CoreBluetooth
import iOSDFULibrary
class LegacyDFUViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate {


    //MARK: - Class Properties
    private var dfuPeripheral  : CBPeripheral?
    private var dfuController  : DFUServiceController?
    private var centralManager : CBCentralManager?
    private var selectedFirmware : DFUFirmware?
    private var selectedFileURL  : NSURL?

    //MARK: - View Outlets
    
    @IBOutlet weak var dfuActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dfuStatusLabel: UILabel!
    @IBOutlet weak var peripheralNameLabel: UILabel!
    @IBOutlet weak var dfuUploadProgressView: UIProgressView!
    @IBOutlet weak var dfuUploadStatus: UILabel!
    //MARK: - Class Implementation
    func getBundledFirmwareURLHelper() -> NSURL {
        return NSBundle.mainBundle().URLForResource("hrs_dfu_s132_2_0_0_7a_sdk_11_0_0_2a", withExtension: "zip")!
    }
    
    func setCentralManager(centralManager aCentralManager : CBCentralManager){
        self.centralManager = aCentralManager
    }

    func setTargetPeripheral(aPeripheral targetPeripheral : CBPeripheral) {
        self.dfuPeripheral = targetPeripheral
    }
    
    func startDFUProcess() {

        guard dfuPeripheral != nil else {
            print("No DFU peripheral was set")
            return
        }

        selectedFileURL     = self.getBundledFirmwareURLHelper()
        selectedFirmware    = DFUFirmware(urlToZipFile: selectedFileURL!, type: DFUFirmwareType.Application)
        let dfuInitiator    = DFUServiceInitiator(centralManager: centralManager!, target: dfuPeripheral!)
        dfuInitiator.withFirmwareFile(selectedFirmware!)
        dfuInitiator.delegate           = self
        dfuInitiator.progressDelegate   = self
        dfuInitiator.forceDfu           = false
        dfuInitiator.logger             = self
        dfuController = dfuInitiator.start()
    }

    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(animated)
        self.peripheralNameLabel.text = "Flashing \((dfuPeripheral?.name)!)"
        self.dfuActivityIndicator.startAnimating()
        self.dfuUploadProgressView.progress = 0.0
        self.dfuUploadStatus.text = ""
        self.dfuStatusLabel.text  = ""

    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.startDFUProcess()
    }

    //MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(central: CBCentralManager) {
        logWith(LogLevel.Verbose, message: "UpdatetState: \(centralManager?.state.rawValue)")
    }

    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral.name)")
    }

    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Disconnected from peripheral: \(peripheral.name)")
    }
    
    //MARK: - DFUServiceDelegate
    func didStateChangedTo(state:State) {

        var stateString : String

        switch state {
        case .Aborted:
            stateString = "Aborted"
            self.dfuActivityIndicator.stopAnimating()
            self.dfuUploadProgressView.setProgress(0, animated: true)
            break
        case .Completed:
            stateString = "Completed"
            self.dfuActivityIndicator.stopAnimating()
            self.dfuUploadProgressView.setProgress(0, animated: true)
            break
        case .Connecting:
            stateString = "Connecting"
            break
        case .Disconnecting:
            stateString = "Disconnecting"
            self.dfuUploadProgressView.setProgress(0, animated: true)
            self.dfuActivityIndicator.stopAnimating()
            break
        case .EnablingDfuMode:
            stateString = "Enabling DFU"
            break
        case .Starting:
            stateString = "Starting"
            break
        case .Uploading:
            stateString = "Uploading"
            break
        case .Validating:
            stateString = "Validating"
            break
        }
        self.dfuStatusLabel.text = stateString
        logWith(LogLevel.Info, message: "Chaged state to: \(stateString)")
    }
    
    func didErrorOccur(error:DFUError, withMessage message:String) {
        self.dfuStatusLabel.text = "Error: \(message)"
        self.dfuActivityIndicator.stopAnimating()
        self.dfuUploadProgressView.setProgress(0, animated: true)
        logWith(LogLevel.Error, message: message)
    }
    
    //MARK: - DFUProgressDelegate
    func onUploadProgress(part: Int, totalParts: Int, progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        print("Porgess: \(progress)% (\(part)/\(totalParts))")
        self.dfuUploadProgressView.setProgress(Float(progress)/100.0, animated: true)
        self.dfuUploadStatus.text = "Speed : \(String(format:"%.1f", avgSpeedBytesPerSecond/1024)) Kbps, pt. \(part)/\(totalParts)"
    }

    //MARK: - LoggerDelegate
    func logWith(level:LogLevel, message:String){
        print("\(level.rawValue) : \(message)")
    }

}
