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

class DFUViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate, UIAlertViewDelegate {


    //MARK: - Class Properties
    private var dfuPeripheral    : CBPeripheral?
    private var dfuController    : DFUServiceController?
    private var centralManager   : CBCentralManager?
    private var selectedFirmware : DFUFirmware?
    private var selectedFileURL  : NSURL?
    private var secureDFU        : Bool?
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
        }
    }
    
    //MARK: - Class Implementation
    func secureDFUMode(secureDFU : Bool) {
        self.secureDFU = secureDFU
    }
    
    func getBundledFirmwareURLHelper() -> NSURL {
        if self.secureDFU! {
            return NSBundle.mainBundle().URLForResource("sdfu_test_app_hrm_s132", withExtension: "zip")!
        }else{
            return NSBundle.mainBundle().URLForResource("hrm_legacy_dfu_with_sd_s132_2_0_0", withExtension: "zip")!
        }
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

        selectedFileURL  = self.getBundledFirmwareURLHelper()
        selectedFirmware = DFUFirmware(urlToZipFile: selectedFileURL!)

        let dfuInitiator = DFUServiceInitiator(centralManager: centralManager!, target: dfuPeripheral!)
        dfuInitiator.withFirmwareFile(selectedFirmware!)
        dfuInitiator.delegate = self
        dfuInitiator.progressDelegate = self
        dfuInitiator.logger = self
        dfuController = dfuInitiator.start()
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
    func didStateChangedTo(state:DFUState) {
        switch state {
            case .Aborted:
                self.dfuActivityIndicator.stopAnimating()
                self.dfuUploadProgressView.setProgress(0, animated: true)
                self.stopProcessButton.enabled = false
                break
            case .SignatureMismatch:
                self.dfuActivityIndicator.stopAnimating()
                self.dfuUploadProgressView.setProgress(0, animated: true)
                self.stopProcessButton.enabled = false
            case .Completed:
                self.dfuActivityIndicator.stopAnimating()
                self.dfuUploadProgressView.setProgress(0, animated: true)
                self.stopProcessButton.enabled = false
                break
            case .Connecting:
                self.stopProcessButton.enabled = true
                break
            case .Disconnecting:
                self.dfuUploadProgressView.setProgress(0, animated: true)
                self.dfuActivityIndicator.stopAnimating()
                self.stopProcessButton.enabled = false
                break
            case .EnablingDfuMode:
                self.stopProcessButton.enabled = true
                break
            case .Starting:
                self.stopProcessButton.enabled = true
                break
            case .Uploading:
                self.stopProcessButton.enabled = true
                break
            case .Validating:
                self.stopProcessButton.enabled = true
                break
            case .OperationNotPermitted:
                self.stopProcessButton.enabled = true
                break
            case .Failed:
                self.stopProcessButton.enabled = true
                break
        }

        self.dfuStatusLabel.text = state.description()
        logWith(LogLevel.Info, message: "Changed state to: \(state.description())")
    }

    func didErrorOccur(error: DFUError, withMessage message: String) {
        self.dfuStatusLabel.text = "Error: \(message)"
        self.dfuActivityIndicator.stopAnimating()
        self.dfuUploadProgressView.setProgress(0, animated: true)
        logWith(LogLevel.Error, message: message)
    }

    
    //MARK: - DFUProgressDelegate
    func onUploadProgress(part: Int, totalParts: Int, progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
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
