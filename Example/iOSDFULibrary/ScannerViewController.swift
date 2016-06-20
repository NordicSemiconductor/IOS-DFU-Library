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
    @IBAction func connectionButtonTapped(sender: AnyObject) {
        handleConnectionButtonTappedEvent()
    }

    //MARK: - Class implementation
    func handleConnectionButtonTappedEvent() {
        self.performSegueWithIdentifier("showDFUView", sender: self)
    }
    
    func startDiscovery() {
        centralManager.scanForPeripheralsWithServices([legacyDfuServiceUUID, secureDfuServiceUUID], options: nil)
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.connectionButton.enabled = false
        self.peripheralNameLabel.text = "No peripheral selected"
    }
    
    //MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == CBCentralManagerState.PoweredOn {
            print("CentralManager is now powered on\nStart discovery")
            self.startDiscovery()
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
            if advertisementData[CBAdvertisementDataServiceUUIDsKey] != nil {
                //Secure DFU UUID
                let secureUUIDString = CBUUID(string: "FE59").UUIDString
                let advertisedUUIDstring = (advertisementData[CBAdvertisementDataServiceUUIDsKey]!).firstObject as! CBUUID
                if advertisedUUIDstring.UUIDString  == secureUUIDString {
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
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (discoveredPeripherals?.count)!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let aCell = tableView.dequeueReusableCellWithIdentifier("peripheralCell", forIndexPath: indexPath)
        
        aCell.textLabel?.text = discoveredPeripherals![indexPath.row].name
        if securePeripheralMarkers![indexPath.row] == true {
            aCell.detailTextLabel?.text = "Secure DFU"
        }else{
            aCell.detailTextLabel?.text = "Legacy DFU"
        }
        return aCell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.selectedPeripheral = discoveredPeripherals![indexPath.row]
        self.selectedPeripheralIsSecure = securePeripheralMarkers![indexPath.row]

        self.connectionButton.enabled = true
        self.peripheralNameLabel.text = self.selectedPeripheral?.name
    }
    
    //MARK: - Navigation
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return identifier == "showDFUView"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        centralManager.stopScan()
        if segue.identifier == "showDFUView" {
            //Sent the peripheral in the dfu view
            let dfuViewController = segue.destinationViewController as! DFUViewController
            dfuViewController.secureDFUMode(self.selectedPeripheralIsSecure!)
            dfuViewController.setTargetPeripheral(aPeripheral: self.selectedPeripheral!)
            dfuViewController.setCentralManager(centralManager: centralManager)
        }
    }
}

