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
class SecureDFUViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, SecureDFUServiceDelegate, SecureDFUProgressDelegate, LoggerDelegate, UIAlertViewDelegate {


    //MARK: - Class Properties
    private var dfuPeripheral    : CBPeripheral?
    private var dfuController    : SecureDFUServiceController?
    private var centralManager   : CBCentralManager?
    private var selectedFirmware : DFUFirmware?
    private var selectedFileURL  : NSURL?

    //MARK: - View Outlets
    @IBOutlet weak var dfuActivityIndicator     : UIActivityIndicatorView!
    @IBOutlet weak var dfuStatusLabel           : UILabel!
    @IBOutlet weak var peripheralNameLabel      : UILabel!
    @IBOutlet weak var dfuUploadProgressView    : UIProgressView!
    @IBOutlet weak var dfuUploadStatus          : UILabel!
    @IBOutlet weak var stopProcessButton        : UIButton!
    
    //MARK: - View Actions
    @IBAction func stopProcessButtonTapped(sender: AnyObject) {
        if dfuController != nil {
            dfuController?.pause()
            UIAlertView(title: "Warning", message: "Are you sure you want to stop the process?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes").show()
        }else{
        }
    }
    
    //MARK: - Class Implementation
    func getBundledFirmwareURLHelper() -> NSURL {
        return NSBundle.mainBundle().URLForResource("blinky_s132", withExtension: "zip")!
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
        let dfuInitiator    = SecureDFUServiceInitiator(centralManager: centralManager!, target: dfuPeripheral!)
        dfuInitiator.withFirmwareFile(selectedFirmware!)
        dfuInitiator.delegate           = self
        dfuInitiator.progressDelegate   = self
        dfuInitiator.logger             = self
        dfuController                   = dfuInitiator.start()
    }

    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(animated)
        self.peripheralNameLabel.text = "Flashing \((dfuPeripheral?.name)!)"
        self.dfuActivityIndicator.startAnimating()
        self.dfuUploadProgressView.progress = 0.0
        self.dfuUploadStatus.text = ""
        self.dfuStatusLabel.text  = ""
        self.stopProcessButton.enabled = false

    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.startDFUProcess()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if dfuController != nil {
            dfuController?.abort()
        }
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
    func didStateChangedTo(state:SecureDFUState) {

        var stateString : String

        switch state {
        case .Aborted:
            stateString = "Aborted"
            self.dfuActivityIndicator.stopAnimating()
            self.dfuUploadProgressView.setProgress(0, animated: true)
            self.stopProcessButton.enabled = false
            break
        case .Completed:
            stateString = "Completed"
            self.dfuActivityIndicator.stopAnimating()
            self.dfuUploadProgressView.setProgress(0, animated: true)
            self.stopProcessButton.enabled = false
            break
        case .Connecting:
            stateString = "Connecting"
            self.stopProcessButton.enabled = true
            break
        case .Disconnecting:
            stateString = "Disconnecting"
            self.dfuUploadProgressView.setProgress(0, animated: true)
            self.dfuActivityIndicator.stopAnimating()
            self.stopProcessButton.enabled = false
            break
        case .EnablingDfuMode:
            stateString = "Enabling DFU"
            self.stopProcessButton.enabled = true
            break
        case .Starting:
            stateString = "Starting"
            self.stopProcessButton.enabled = true
            break
        case .Uploading:
            stateString = "Uploading"
            self.stopProcessButton.enabled = true
            break
        case .Validating:
            stateString = "Validating"
            self.stopProcessButton.enabled = true
            break
        }
        self.dfuStatusLabel.text = stateString
        logWith(LogLevel.Info, message: "Changed state to: \(stateString)")
    }
    
    func OnErrorOccured(withError anError: SecureDFUError, andMessage aMessage: String) {
        self.dfuStatusLabel.text = "Error: \(aMessage)"
        self.dfuActivityIndicator.stopAnimating()
        self.dfuUploadProgressView.setProgress(0, animated: true)
        logWith(LogLevel.Error, message: aMessage)
    }
    
    //MARK: - DFUProgressDelegate
    func onUploadProgress(part: Int, totalParts: Int, progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
//        print("Porgess: \(progress)% (\(part)/\(totalParts))")
        self.dfuUploadProgressView.setProgress(Float(progress)/100.0, animated: true)
        self.dfuUploadStatus.text = "Speed : \(String(format:"%.1f", avgSpeedBytesPerSecond/1024)) Kbps, pt. \(part)/\(totalParts)"
    }

    //MARK: - LoggerDelegate
    func logWith(level:LogLevel, message:String){
        print("\(level.rawValue) : \(message)")
    }
    
    //MARK: - UIAlertViewDelegate
    func alertViewCancel(alertView: UIAlertView) {
        logWith(LogLevel.Verbose, message: "Abort cancelled")
        if (dfuController?.paused)! == true {
            dfuController?.resume()
        }
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        guard dfuController != nil else {
            logWith(LogLevel.Error, message: "DFUController not set, cannot abort")
            return
        }

        switch buttonIndex {
        case 0:
            logWith(LogLevel.Verbose, message: "Abort cancelled")
            if (dfuController?.paused)! == true {
                dfuController?.resume()
            }
            break
        case 1:
            logWith(LogLevel.Verbose, message: "Abort Confirmed")
            dfuController?.abort()
            break
        default:
            break
        }
    }

}
