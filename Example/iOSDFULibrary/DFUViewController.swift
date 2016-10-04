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
    fileprivate var dfuPeripheral    : CBPeripheral?
    fileprivate var dfuController    : DFUServiceController?
    fileprivate var centralManager   : CBCentralManager?
    fileprivate var selectedFirmware : DFUFirmware?
    fileprivate var selectedFileURL  : URL?
    fileprivate var secureDFU        : Bool?
    //MARK: - View Outlets
    @IBOutlet weak var dfuActivityIndicator     : UIActivityIndicatorView!
    @IBOutlet weak var dfuStatusLabel           : UILabel!
    @IBOutlet weak var peripheralNameLabel      : UILabel!
    @IBOutlet weak var dfuUploadProgressView    : UIProgressView!
    @IBOutlet weak var dfuUploadStatus          : UILabel!
    @IBOutlet weak var stopProcessButton        : UIButton!
    
    //MARK: - View Actions
    @IBAction func stopProcessButtonTapped(_ sender: AnyObject) {
        if dfuController != nil {
            dfuController?.pause()
            UIAlertView(title: "Warning", message: "Are you sure you want to stop the process?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes").show()
        }
    }
    
    //MARK: - Class Implementation
    func secureDFUMode(_ secureDFU : Bool) {
        self.secureDFU = secureDFU
    }
    
    func getBundledFirmwareURLHelper() -> URL {
        if self.secureDFU! {
            return Bundle.main.url(forResource: "sdfu_test_app_hrm_s132", withExtension: "zip")!
        }else{
            return Bundle.main.url(forResource: "hrm_legacy_dfu_with_sd_s132_2_0_0", withExtension: "zip")!
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
        _ = dfuInitiator.withFirmwareFile(selectedFirmware!)
        dfuInitiator.delegate = self
        dfuInitiator.progressDelegate = self
        dfuInitiator.logger = self
        dfuController = dfuInitiator.start()
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        self.peripheralNameLabel.text = "Flashing \((dfuPeripheral?.name)!)"
        self.dfuActivityIndicator.startAnimating()
        self.dfuUploadProgressView.progress = 0.0
        self.dfuUploadStatus.text = ""
        self.dfuStatusLabel.text  = ""
        self.stopProcessButton.isEnabled = false

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startDFUProcess()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if dfuController != nil {
            _ = dfuController?.abort()
        }
    }

    //MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        logWith(LogLevel.verbose, message: "UpdatetState: \(centralManager?.state.rawValue)")
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral.name)")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from peripheral: \(peripheral.name)")
    }

    //MARK: - DFUServiceDelegate
    func didStateChangedTo(_ state:DFUState) {
        switch state {
            case .aborted:
                self.dfuActivityIndicator.stopAnimating()
                self.dfuUploadProgressView.setProgress(0, animated: true)
                self.stopProcessButton.isEnabled = false
                break
            case .signatureMismatch:
                self.dfuActivityIndicator.stopAnimating()
                self.dfuUploadProgressView.setProgress(0, animated: true)
                self.stopProcessButton.isEnabled = false
            case .completed:
                self.dfuActivityIndicator.stopAnimating()
                self.dfuUploadProgressView.setProgress(0, animated: true)
                self.stopProcessButton.isEnabled = false
                break
            case .connecting:
                self.stopProcessButton.isEnabled = true
                break
            case .disconnecting:
                self.dfuUploadProgressView.setProgress(0, animated: true)
                self.dfuActivityIndicator.stopAnimating()
                self.stopProcessButton.isEnabled = false
                break
            case .enablingDfuMode:
                self.stopProcessButton.isEnabled = true
                break
            case .starting:
                self.stopProcessButton.isEnabled = true
                break
            case .uploading:
                self.stopProcessButton.isEnabled = true
                break
            case .validating:
                self.stopProcessButton.isEnabled = true
                break
            case .operationNotPermitted:
                self.stopProcessButton.isEnabled = true
                break
            case .failed:
                self.stopProcessButton.isEnabled = true
                break
        }

        self.dfuStatusLabel.text = state.description()
        logWith(LogLevel.info, message: "Changed state to: \(state.description())")
    }

    func didErrorOccur(_ error: DFUError, withMessage message: String) {
        self.dfuStatusLabel.text = "Error: \(message)"
        self.dfuActivityIndicator.stopAnimating()
        self.dfuUploadProgressView.setProgress(0, animated: true)
        logWith(LogLevel.error, message: message)
    }

    
    //MARK: - DFUProgressDelegate
    func onUploadProgress(_ part: Int, totalParts: Int, progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        self.dfuUploadProgressView.setProgress(Float(progress)/100.0, animated: true)
        self.dfuUploadStatus.text = "Speed : \(String(format:"%.1f", avgSpeedBytesPerSecond/1024)) Kbps, pt. \(part)/\(totalParts)"
    }

    //MARK: - LoggerDelegate
    func logWith(_ level:LogLevel, message:String){
        print("\(level.name()) : \(message)")
    }
    
    //MARK: - UIAlertViewDelegate
    func alertViewCancel(_ alertView: UIAlertView) {
        logWith(LogLevel.verbose, message: "Abort cancelled")
        if (dfuController?.paused)! == true {
            dfuController?.resume()
        }
    }
    
    func alertView(_ alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        guard dfuController != nil else {
            logWith(LogLevel.error, message: "DFUController not set, cannot abort")
            return
        }

        switch buttonIndex {
        case 0:
            logWith(LogLevel.verbose, message: "Abort cancelled")
            if (dfuController?.paused)! == true {
                dfuController?.resume()
            }
            break
        case 1:
            logWith(LogLevel.verbose, message: "Abort Confirmed")
            dfuController?.abort()
            break
        default:
            break
        }
    }

}
