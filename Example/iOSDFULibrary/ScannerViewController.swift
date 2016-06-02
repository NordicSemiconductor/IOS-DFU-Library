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
    var centralManager        : CBCentralManager
    var dfuServiceUUID        : CBUUID
    var selectedPeripheral    : CBPeripheral?
    var discoveredPeripherals : [CBPeripheral]?


    //MARK: - View Outlets
    @IBOutlet weak var connectionButton: UIButton!
    @IBOutlet weak var discoveredPeripheralsTableView: UITableView!
    @IBOutlet weak var peripheralNameLabel: UILabel!
    @IBAction func connectionButtonTapped(sender: AnyObject) {
        handleConnectionButtonTappedEvent()
    }

    //MARK: - Class implementation
    func handleConnectionButtonTappedEvent() {
        self.performSegueWithIdentifier("showSecureDFUView", sender: self)
    }
    
    func startDiscovery() {
        centralManager.scanForPeripheralsWithServices([dfuServiceUUID], options: nil)
    }

    //MARK: - UIViewController implementation
    required init?(coder aDecoder: NSCoder) {
        //Initialize CentralManager and DFUService UUID
        centralManager = CBCentralManager()
        dfuServiceUUID = CBUUID(string: "00001530-1212-EFDE-1523-785FEABCD123")
        super.init(coder: aDecoder)
        centralManager.delegate = self
        discoveredPeripherals = [CBPeripheral]()
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
            print("discovered \(peripheral.name)")
            if self.discoveredPeripherals?.contains(peripheral) == false {
                self.discoveredPeripherals?.append(peripheral)
                discoveredPeripheralsTableView.reloadData()
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
        
        return aCell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.selectedPeripheral = discoveredPeripherals![indexPath.row]
        self.connectionButton.enabled = true
        self.peripheralNameLabel.text = self.selectedPeripheral?.name
    }
    
    //MARK: - Navigation
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return identifier == "showLegacyDFUView" || identifier == "showSecureDFUView"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        centralManager.stopScan()
        if segue.identifier == "showLegacyDFUView" {
            //Sent the peripheral in the dfu view
            let dfuViewController = segue.destinationViewController as! LegacyDFUViewController
            dfuViewController.setTargetPeripheral(aPeripheral: self.selectedPeripheral!)
            dfuViewController.setCentralManager(centralManager: centralManager)
        } else {
            let dfuViewController = segue.destinationViewController as! SecureDFUViewController
            dfuViewController.setTargetPeripheral(aPeripheral: self.selectedPeripheral!)
            dfuViewController.setCentralManager(centralManager: centralManager)
        }
    }
}

