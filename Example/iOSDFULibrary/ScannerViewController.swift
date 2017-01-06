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

class ScannerViewController: UIViewController, CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    static var legacyDfuServiceUUID  = CBUUID(string: "00001530-1212-EFDE-1523-785FEABCD123")
    static var secureDfuServiceUUID  = CBUUID(string: "FE59")
    static var deviceInfoServiceUUID = CBUUID(string: "180A")

    //MARK: - Class properties
    var centralManager              : CBCentralManager?
    var selectedPeripheral          : CBPeripheral?
    var selectedPeripheralIsSecure  : Bool?
    var discoveredPeripherals       : [CBPeripheral]
    var securePeripheralMarkers     : [Bool?]
    
    var scanningStarted             : Bool = false

    //MARK: - View Outlets
    @IBOutlet weak var connectionButton: UIButton!
    @IBOutlet weak var discoveredPeripheralsTableView: UITableView!
    @IBOutlet weak var peripheralNameLabel: UILabel!
    @IBAction func connectionButtonTapped(_ sender: AnyObject) {
        handleConnectionButtonTappedEvent()
    }

    //MARK: - Class implementation
    func handleConnectionButtonTappedEvent() {
        performSegue(withIdentifier: "showDFUView", sender: self)
    }
    
    func startDiscovery() {
        if !scanningStarted {
            scanningStarted = true
            print("Start discovery")
            // the legacy and secure DFU UUIDs are advertised by devices in DFU mode,
            // the device info service is in the adv packet of DFU_HRM sample and the Experimental Buttonless DFU from SDK 12
            centralManager!.delegate = self
            centralManager!.scanForPeripherals(withServices: [
                ScannerViewController.legacyDfuServiceUUID,
                ScannerViewController.secureDfuServiceUUID,
                ScannerViewController.deviceInfoServiceUUID])
        }
    }

    //MARK: - UIViewController implementation
    required init?(coder aDecoder: NSCoder) {
        discoveredPeripherals   = [CBPeripheral]()
        securePeripheralMarkers = [Bool?]()
        super.init(coder: aDecoder)
        centralManager          = CBCentralManager(delegate: self, queue: nil) // The delegate must be set in init in order to work on iOS 8
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        connectionButton.isEnabled = false
        peripheralNameLabel.text = "No peripheral selected"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if centralManager!.state == .poweredOn {
            startDiscovery()
        }
    }
    
    //MARK: - CBCentralManagerDelegate API
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("CentralManager is now powered on")
            startDiscovery()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Ignore dupliactes. 
        // They will not be reported in a single scan, as we scan without CBCentralManagerScanOptionAllowDuplicatesKey flag,
        // but after returning from DFU view another scan will be started.
        guard discoveredPeripherals.contains(peripheral) == false else { return }
        
        if advertisementData[CBAdvertisementDataServiceUUIDsKey] != nil {
            let name = peripheral.name ?? "Unknown"
            
            let secureUUIDString = ScannerViewController.secureDfuServiceUUID.uuidString
            let legacyUUIDString = ScannerViewController.legacyDfuServiceUUID.uuidString
            let advertisedUUIDstring = ((advertisementData[CBAdvertisementDataServiceUUIDsKey]!) as AnyObject).firstObject as! CBUUID
            
            if advertisedUUIDstring.uuidString == secureUUIDString {
                print("Found Secure Peripheral: \(name)")
                discoveredPeripherals.append(peripheral)
                securePeripheralMarkers.append(true)
                discoveredPeripheralsTableView.reloadData()
            } else if advertisedUUIDstring.uuidString == legacyUUIDString {
                print("Found Legacy Peripheral: \(name)")
                discoveredPeripherals.append(peripheral)
                securePeripheralMarkers.append(false)
                discoveredPeripheralsTableView.reloadData()
            } else {
                print("Found Peripheral: \(name)")
                discoveredPeripherals.append(peripheral)
                securePeripheralMarkers.append(nil)
                discoveredPeripheralsTableView.reloadData()
            }
        }
    }
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredPeripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aCell = tableView.dequeueReusableCell(withIdentifier: "peripheralCell", for: indexPath)
        
        aCell.textLabel?.text = discoveredPeripherals[indexPath.row].name
        switch securePeripheralMarkers[indexPath.row] {
        case .some(true):
            aCell.detailTextLabel?.text = "Secure DFU"
        case .some(false):
            aCell.detailTextLabel?.text = "Legacy DFU"
        default:
            aCell.detailTextLabel?.text = "?"
        }
        return aCell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedPeripheral = discoveredPeripherals[indexPath.row]
        selectedPeripheralIsSecure = securePeripheralMarkers[indexPath.row]

        connectionButton.isEnabled = true
        peripheralNameLabel.text = selectedPeripheral!.name
    }
    
    //MARK: - Navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return identifier == "showDFUView"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        scanningStarted = false
        centralManager!.stopScan()
        if segue.identifier == "showDFUView" {
            //Sent the peripheral in the dfu view
            let dfuViewController = segue.destination as! DFUViewController
            dfuViewController.secureDFUMode(selectedPeripheralIsSecure)
            dfuViewController.setTargetPeripheral(selectedPeripheral!)
            dfuViewController.setCentralManager(centralManager!)
        }
    }
}

