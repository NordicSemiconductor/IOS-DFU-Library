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
    // Add your own UUID filter:
    // static var customServiceUUID = CBUUID(string: "180A")

    //MARK: - Class properties
    var centralManager              : CBCentralManager!
    var selectedPeripheral          : (peripheral: CBPeripheral, name: String?)?
    var discoveredPeripherals       : [(peripheral: CBPeripheral, name: String?)]
    var scanningStarted             : Bool = false

    //MARK: - View Outlets
    @IBOutlet weak var connectionButton: UIButton!
    @IBOutlet weak var discoveredPeripheralsTableView: UITableView!
    @IBOutlet weak var peripheralNameLabel: UILabel!
    @IBAction func connectionButtonTapped(_ sender: Any) {
        showDfuView()
    }
    @IBAction func refreshButtonTapped(_ sender: Any) {
        discoveredPeripherals.removeAll()
        discoveredPeripheralsTableView.reloadData()
        
        selectedPeripheral = nil
        connectionButton.isEnabled = false
        peripheralNameLabel.text = "No selection"
    }

    //MARK: - UIViewController implementation
    
    required init?(coder aDecoder: NSCoder) {
        discoveredPeripherals   = []
        super.init(coder: aDecoder)
        centralManager          = CBCentralManager(delegate: self, queue: nil) // The delegate must be set in init in order to work on iOS 8
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        connectionButton.isEnabled = false
        peripheralNameLabel.text = "No selection"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        centralManager.delegate = self
        if centralManager.state == .poweredOn {
            startDiscovery()
        }
    }
    
    //MARK: - Class implementation
    
    func startDiscovery() {
        if !scanningStarted {
            scanningStarted = true
            print("Start discovery")
            // By default the scanner shows only devices advertising with one of those Service UUIDs:
            centralManager!.delegate = self
            centralManager!.scanForPeripherals(
                withServices: [
                    ScannerViewController.legacyDfuServiceUUID,
                    ScannerViewController.secureDfuServiceUUID,
                    ScannerViewController.deviceInfoServiceUUID
                    /*, customServiceUUID*/],
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    //MARK: - CBCentralManagerDelegate API
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Central Manager is now powered on")
            startDiscovery()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let name = advertisementData[CBAdvertisementDataLocalNameKey] as! String?
        
        // Ignore dupliactes. 
        // They will not be reported in a single scan, as we scan without CBCentralManagerScanOptionAllowDuplicatesKey flag,
        // but after returning from DFU view another scan will be started.
        guard discoveredPeripherals.contains(where: { element in element.peripheral == peripheral }) == false else {
            return
        }
        
        discoveredPeripherals.append((peripheral, name))
        discoveredPeripheralsTableView.reloadData()
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredPeripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aCell = tableView.dequeueReusableCell(withIdentifier: "peripheralCell", for: indexPath)
        aCell.textLabel!.text = discoveredPeripherals[indexPath.row].name ?? "No name"
        return aCell
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedPeripheral = discoveredPeripherals[indexPath.row]
        peripheralNameLabel.text = selectedPeripheral!.name ?? "No name"
        connectionButton.isEnabled = true
    }
    
    //MARK: - Navigation
    
    func showDfuView() {
        performSegue(withIdentifier: "showDFUView", sender: self)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return identifier == "showDFUView"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        scanningStarted = false
        centralManager.stopScan()
        
        if segue.identifier == "showDFUView" {
            // Sent the peripheral in the dfu view
            let dfuViewController = segue.destination as! DFUViewController
            dfuViewController.setTargetPeripheral(selectedPeripheral!.peripheral, withName: selectedPeripheral!.name)
            dfuViewController.setCentralManager(centralManager)
        }
    }
}

