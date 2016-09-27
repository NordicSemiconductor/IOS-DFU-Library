//
//  ViewController.swift
//  iOSDFULibrary
//
//  Created by Mostafa Berg on 04/18/2016.
//  Copyright (c) 2016 Mostafa Berg. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScannerViewController: UIViewController, CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    //MARK: - Class properties
    var centralManager              : CBCentralManager
    var legacyDfuServiceUUID        : CBUUID
    var secureDfuServiceUUID        : CBUUID
    var selectedPeripheral          : CBPeripheral?
    var selectedPeripheralIsSecure  : Bool?
    var discoveredPeripherals       : [CBPeripheral]?
    var securePeripheralMarkers     : [Bool]?

    //MARK: - View Outlets
    @IBOutlet weak var connectionButton: UIButton!
    @IBOutlet weak var discoveredPeripheralsTableView: UITableView!
    @IBOutlet weak var peripheralNameLabel: UILabel!
    @IBAction func connectionButtonTapped(_ sender: AnyObject) {
        handleConnectionButtonTappedEvent()
    }

    //MARK: - Class implementation
    func handleConnectionButtonTappedEvent() {
        self.performSegue(withIdentifier: "showDFUView", sender: self)
    }
    
    func startDiscovery() {
        centralManager.scanForPeripherals(withServices: [legacyDfuServiceUUID, secureDfuServiceUUID], options: nil)
    }

    //MARK: - UIViewController implementation
    required init?(coder aDecoder: NSCoder) {
        //Initialize CentralManager and DFUService UUID
        centralManager = CBCentralManager()
        legacyDfuServiceUUID    = CBUUID(string: "00001530-1212-EFDE-1523-785FEABCD123")
        secureDfuServiceUUID    = CBUUID(string: "FE59")
        super.init(coder: aDecoder)
        centralManager.delegate = self
        discoveredPeripherals = [CBPeripheral]()
        securePeripheralMarkers = [Bool]()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.connectionButton.isEnabled = false
        self.peripheralNameLabel.text = "No peripheral selected"
    }
    
    //MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("CentralManager is now powered on\nStart discovery")
            self.startDiscovery()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
            if advertisementData[CBAdvertisementDataServiceUUIDsKey] != nil {
                //Secure DFU UUID
                let secureUUIDString = CBUUID(string: "FE59").uuidString
                let advertisedUUIDstring = ((advertisementData[CBAdvertisementDataServiceUUIDsKey]!) as AnyObject).firstObject as! CBUUID
                if advertisedUUIDstring.uuidString  == secureUUIDString {
                    print("Found Secure Peripheral: \(peripheral.name!)")
                    if self.discoveredPeripherals?.contains(peripheral) == false {
                        self.discoveredPeripherals?.append(peripheral)
                        self.securePeripheralMarkers?.append(true)
                        discoveredPeripheralsTableView.reloadData()
                    }
                }else{
                    print("Found Legacy Peripheral: \(peripheral.name!)")
                    if self.discoveredPeripherals?.contains(peripheral) == false {
                        self.discoveredPeripherals?.append(peripheral)
                        self.securePeripheralMarkers?.append(false)
                        discoveredPeripheralsTableView.reloadData()
                    }
                }
            }
    }
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (discoveredPeripherals?.count)!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aCell = tableView.dequeueReusableCell(withIdentifier: "peripheralCell", for: indexPath)
        
        aCell.textLabel?.text = discoveredPeripherals![(indexPath as NSIndexPath).row].name
        if securePeripheralMarkers![(indexPath as NSIndexPath).row] == true {
            aCell.detailTextLabel?.text = "Secure DFU"
        }else{
            aCell.detailTextLabel?.text = "Legacy DFU"
        }
        return aCell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedPeripheral = discoveredPeripherals![(indexPath as NSIndexPath).row]
        self.selectedPeripheralIsSecure = securePeripheralMarkers![(indexPath as NSIndexPath).row]

        self.connectionButton.isEnabled = true
        self.peripheralNameLabel.text = self.selectedPeripheral?.name
    }
    
    //MARK: - Navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return identifier == "showDFUView"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        centralManager.stopScan()
        if segue.identifier == "showDFUView" {
            //Sent the peripheral in the dfu view
            let dfuViewController = segue.destination as! DFUViewController
            dfuViewController.secureDFUMode(self.selectedPeripheralIsSecure!)
            dfuViewController.setTargetPeripheral(aPeripheral: self.selectedPeripheral!)
            dfuViewController.setCentralManager(centralManager: centralManager)
        }
    }
}

