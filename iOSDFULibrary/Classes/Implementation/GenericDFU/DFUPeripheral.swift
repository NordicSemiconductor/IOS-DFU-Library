/*
* Copyright (c) 2019, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

import CoreBluetooth

internal protocol BaseDFUPeripheralAPI: AnyObject, DFUController {
    
    /**
     This method starts DFU process for given peripheral. If the peripheral is
     not connected it will call the `connect()` method, if it is connected, but
     services were not discovered before, it will try to discover services instead.
     If services were already discovered the DFU process will be started.
     */
    func start()
    
    /**
     This method reconnects to the same peripheral after it has disconnected.
     */
    func reconnect()
    
    /**
     Disconnects the target device.
     */
    func disconnect()
    
    /**
     This method breaks the cyclic reference and both DFUExecutor and
     DFUPeripheral may be released.
     */
    func destroy()
    
    /**
     This method should reset the device, preferably switching it to application
     mode.
     */
    func resetDevice()
}

internal class BaseDFUPeripheral<TD : BasePeripheralDelegate> : NSObject, BaseDFUPeripheralAPI, CBPeripheralDelegate, CBCentralManagerDelegate {
    /// Bluetooth Central Manager used to scan for the peripheral.
    internal let centralManager: CBCentralManager
    internal let targetIdentifier: UUID
    internal let queue: DispatchQueue
    /// The DFU Target peripheral.
    internal var peripheral: CBPeripheral?
    /// The peripheral delegate.
    internal var delegate: TD?
    /// The optional logger delegate.
    internal let logger: LoggerHelper
    /// A list of services required to be found on the peripheral.
    /// May return nil - then all services will be discovered.
    internal var requiredServices: [CBUUID]? {
        // We have to find all services, not only those releated to DFU.
        // This is required in case the target device was created using
        // SDK 6.0 or 6.1, where there was no DFU Version characteristic.
        // In that case, this DFU library determines whether to jump to
        // bootloader, or proceed with DFU based on number of services found.
        // We have to find all of them. It is not necessary for newer
        // firmwares (SDK 7+) or for Secure DFU where the code below could work.
        return nil
        
        /*
        // If the experimental feature was enabled
        if experimentalButtonlessServiceInSecureDfuEnabled {
            return [uuidHelper.legacyDFUService, uuidHelper.secureDFUService, uuidHelper.buttonlessExperimentalService]
        }
        // By default only standard Secure and Legacy DFU services will be
        // discovered.
        return [uuidHelper.legacyDFUService, uuidHelper.secureDFUService]
        */
    }
    /// A flag indicating whether the eperimental Buttonless DFU Service in
    /// Secure DFU is supported.
    internal let experimentalButtonlessServiceInSecureDfuEnabled: Bool
    /// Default error callback.
    internal var defaultErrorCallback: ErrorCallback {
        return { [weak self] error, message in
            self?.delegate?.error(error, didOccurWithMessage: message)
        }
    }

    /// UUIDs for Service/Characteristics.
    internal var uuidHelper: DFUUuidHelper

    /// A flag set when upload has been aborted.
    fileprivate var aborted: Bool = false
    /// Connection timer cancels connection attempt if the device doesn't
    /// connect before the time runs out.
    fileprivate var connectionTimer: DispatchSourceTimer?
    /// Connection timeout.
    /// - since: 4.8.0
    fileprivate let connectionTimeout: TimeInterval
    /// Whether new address is expected in Legacy DFU Bootloader.
    /// - seeAlso: `DFUServiceInitiatorBle.forceScanningForNewAddressInLegacyDfu`
    /// - since: 4.9.0
    fileprivate let forceScanningForNewAddressInLegacyDfu: Bool
    
    init(_ initiator: DFUServiceInitiatorBle, _ logger: LoggerHelper) {
        self.centralManager = initiator.centralManager
        self.targetIdentifier = initiator.targetIdentifier
        self.queue = initiator.queue
        self.logger = logger
        self.experimentalButtonlessServiceInSecureDfuEnabled = initiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu
        self.uuidHelper = initiator.uuidHelper
        self.connectionTimeout = initiator.connectionTimeout
        self.forceScanningForNewAddressInLegacyDfu = initiator.forceScanningForNewAddressInLegacyDfu

        super.init()
    }
    
    // MARK: - Base DFU Peripheral API
    
    func start() {
        aborted = false
        centralManager.delegate = self
        
        if centralManager.state != .poweredOn {
            // Central manager not ready. Wait for poweredOn state.
            return
        }
        // Set the initial peripheral. It may be changed later (flashing App fw
        // after first flashing SD/BL).
        guard let peripheral = centralManager
            .retrievePeripherals(withIdentifiers: [targetIdentifier]).first else {
            delegate?.error(.bluetoothDisabled, didOccurWithMessage:
                "Could not obtain peripheral instance")
            return
        }
        self.peripheral = peripheral
        
        switch peripheral.state {
        case .connected:
            let name = peripheral.name ?? "Unknown device"
            logger.i("Connected to \(name)")
            
            if let dfuService = findDfuService(in: peripheral.services) {
                // A DFU service was found, congratulations!
                logger.i("Services discovered")
                peripheralDidDiscoverDfuService(dfuService)
            } else {
                // DFU service has not been found, but it doesn't matter it's not
                // there. Perhaps the user's application didn't discover it.
                // Let's discover DFU services.
                discoverServices()
            }
        default:
            connect()
        }
    }
    
    func reconnect() {
        guard let peripheral = peripheral, peripheral.state != .connected else { return }
        connect()
    }
    
    func disconnect() {
        guard let peripheral = peripheral else { return }
        if peripheral.state == .connected {
            logger.v("Disconnecting...")
        } else {
            logger.v("Cancelling connection...")
        }
        logger.d("centralManager.cancelPeripheralConnection(peripheral)")
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func destroy() {
        centralManager.delegate = nil
        peripheral?.delegate = nil
        // Peripheral can't be cleared here to make restart() possible.
        // See https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/269
        // peripheral = nil
        delegate = nil
    }
    
    // MARK: - DFU Controller API
    
    func pause() -> Bool {
        // BaseDFUPeripheral does not support pausing or resuming.
        return false
    }
    
    func resume() -> Bool {
        // BaseDFUPeripheral does not support pausing or resuming.
        return false
    }
    
    func abort() -> Bool {
        aborted = true
        if peripheral?.state == .connecting {
            disconnect()
        }
        return true
    }
    
    // MARK: - Central Manager methods
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var stateAsString: String
        
        switch (central.state) {
        case .poweredOn:
            stateAsString = "Powered ON"
        case .poweredOff:
            stateAsString = "Powered OFF"
        case .resetting:
            stateAsString = "Resetting"
        case .unauthorized:
            stateAsString = "Unauthorized"
        case .unsupported:
            stateAsString = "Unsupported"
        default:
            stateAsString = "Unknown"
        }
        logger.d("[Callback] Central Manager did update state to: \(stateAsString)")
        switch central.state {
        case .poweredOn:
            // We are now ready to rumble!
            start()
        default:
            // The device has been already disconnected if it was connected.
            delegate?.error(.bluetoothDisabled, didOccurWithMessage: "Bluetooth adapter powered off")
            destroy()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard peripheral.isEqual(self.peripheral) else {
            return
        }
        
        cleanUp()
        
        logger.d("[Callback] Central Manager did connect peripheral")
        let name = peripheral.name ?? "Unknown device"
        logger.i("Connected to \(name)")
        
        guard !aborted else {
            resetDevice()
            return
        }
        
        discoverServices()
    }
    
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral, error: Error?) {
        guard peripheral.isEqual(self.peripheral) else {
            return
        }
        
        cleanUp()
        
        if let error = error {
            logger.d("[Callback] Central Manager did fail to connect peripheral")
            logger.e(error)
        } else {
            logger.d("[Callback] Central Manager did fail to connect peripheral without error")
        }
        logger.e("Device failed to connect")
        delegate?.peripheralDidFailToConnect()
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard peripheral.isEqual(self.peripheral) else {
            return
        }
        
        let wasConnected = connectionTimer == nil
        cleanUp() // This clears the connectionTimer.
        
        if !wasConnected {
            logger.e("[Callback] Central Manager failed to connect to peripheral (timeout)")
            delegate?.peripheralDidFailToConnect()
        } else if let error = error {
            // We may expect an error with
            // code = 7: "The specified device has disconnected from us." (graceful disconnect),
            // or
            // code = 6: "The connection has timed out unexpectedly." (in case it disconnected
            //           before sending the ACK).
            if let cbError = error as? CBError,
               cbError.code == CBError.connectionTimeout ||
               cbError.code == CBError.peripheralDisconnected {
                logger.d("[Callback] Central Manager did disconnect peripheral")
                logger.i("Disconnected by the remote device")
                
                peripheralDidDisconnect()
            } else {
                logger.e("[Callback] Central Manager did disconnect peripheral with error: \(error.localizedDescription)")
                logger.i("Disconnected")
                
                logger.e(error)
                delegate?.peripheralDidDisconnect(withError: error)
            }
        } else {
            logger.d("[Callback] Central Manager did disconnect peripheral")
            logger.i("Disconnected")
            
            peripheralDidDisconnect()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // This empty method has to be here, otherwise the BaseCommonDFUPeripheral does
        // not get this callback
        
        // Don't use central manager while DFU is in progress!
        print("DFU in progress, don't use this CentralManager instance!")
        central.stopScan()
    }
    
    // MARK: - Peripheral Delegate methods
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            logger.e("Services discovery failed")
            logger.e(error)
            delegate?.error(.serviceDiscoveryFailed, didOccurWithMessage: "Services discovery failed")
            return
        }
        
        logger.i("Services discovered")
        
        guard !aborted else {
            resetDevice()
            return
        }
        
        // Search for DFU service
        guard let dfuService = findDfuService(in: peripheral.services) else {
            logger.e("DFU Service not found")
            
            // Log what was found in case of an error
            if let services = peripheral.services, services.isEmpty == false {
                logger.d("The following services were discovered:")
                services.forEach { service in
                    logger.d(" - \(service.uuid.uuidString)")
                }
            } else {
                logger.d("No services found")
            }
            logger.d("Did you connect to the correct target? It might be that the previous services were cached: toggle Bluetooth from iOS settings to clear cache. Also, ensure the device contains the Service Changed characteristic")
            
            // The device does not support DFU, nor buttonless jump
            delegate?.error(.deviceNotSupported, didOccurWithMessage: "DFU Service not found")
            return
        }
        // A DFU service was found, congratulations!
        peripheralDidDiscoverDfuService(dfuService)
    }
    
    // MARK: - Methods to be overriden in the final implementation
    
    /**
     Method called when a DFU service has been found.
     
     - parameter service: The service that has been found.
     */
    func peripheralDidDiscoverDfuService(_ service: CBService) {
        fatalError("This method must be overriden")
    }
    
    /**
     Method called when the device got disconnected.
     */
    func peripheralDidDisconnect() {
        guard !aborted else {
            // The device has resetted. Notify user.
            logger.w("Upload aborted")
            delegate?.peripheralDidDisconnectAfterAborting()
            return
        }
        
        // Notify the delegate about the disconnection.
        // Most probably an error occurred and will be reported to the user.
        delegate?.peripheralDidDisconnect()
    }
    
    /**
     This method should reset the device, preferably switching it to application mode.
     */
    func resetDevice() {
        if let peripheral = peripheral, peripheral.state != .disconnected {
            disconnect()
        } else {
            peripheralDidDisconnect()
        }
    }
    
    // MARK: - Private methods
    
    /**
     Looks for a DFU Service in given list of services.
     
     - returns: A `DFUService` type if a DFU service has been found, or `nil` if
                services are `nil` or the list does not contain any supported DFU Service.
     */
    private func findDfuService(in services: [CBService]?) -> CBService? {
        return services?.first { service in
            // The experimental Buttonless DFU Service for Secure DFU has been found.
            // Skip the experimental Buttonless DFU Service if this feature wasn't enabled.
            (experimentalButtonlessServiceInSecureDfuEnabled &&
                service.matches(uuid: uuidHelper.buttonlessExperimentalService)) ||
            // Secure DFU Service has been found.
            service.matches(uuid: uuidHelper.secureDFUService) ||
            // Legacy DFU Service has been found.
            service.matches(uuid: uuidHelper.legacyDFUService)
        }
    }
    
    /**
     Starts the service discovery.
     */
    private func discoverServices() {
        if let peripheral = peripheral {
            // Discover DFU service on the device to determine the DFU implementation.
            logger.v("Discovering services...")
            if let services = requiredServices {
                logger.d("peripheral.discoverServices(\(services))")
            } else {
                logger.d("peripheral.discoverServices(nil)")
            }
            peripheral.delegate = self
            peripheral.discoverServices(requiredServices)
        } else {
            logger.e("Unable to discover services: peripheral is nil. Is Bluetooth enabled?")
            delegate?.error(.serviceDiscoveryFailed, didOccurWithMessage: "Peripheral is nil")
            resetDevice()
        }
    }
    
    /**
     Connects to the peripheral and performs service discovery.
     */
    fileprivate func connect() {
        connect(withTimeout: connectionTimeout)
    }
    
    /**
     Connects to the peripheral and performs service discovery.
     
     If the connection fails before the time runs out, the optional timeout
     handler will be called.
     
     - parameters:
       - timeout: The connection timeout.
       - timeoutHandler: An optional callback, which will be executed on timeout.
     */
    fileprivate func connect(withTimeout timeout: TimeInterval, timeoutHandler: (() -> ())? = nil) {
        guard let peripheral = peripheral else {
            return
        }
        let name = peripheral.name ?? "Unknown device"
        logger.v("Connecting to \(name)...")
        // Set a connection timer.
        connectionTimer = DispatchSource.makeTimerSource()
        connectionTimer?.setEventHandler { [weak self] in
            if let self = self, let peripheral = self.peripheral {
                self.connectionTimer?.cancel()
                self.logger.w("Connection timeout!")
                self.logger.d("centralManager.cancelPeripheralConnection(peripheral)")
                self.centralManager.cancelPeripheralConnection(peripheral)
                timeoutHandler?()
            }
        }
        connectionTimer?.schedule(deadline: .now() + timeout)
        connectionTimer?.resume()
        logger.d("centralManager.connect(peripheral, options: nil)")
        centralManager.connect(peripheral, options: nil)
    }
    
    fileprivate func cleanUp() {
        connectionTimer?.cancel()
        connectionTimer = nil
    }
}

internal protocol DFUPeripheralAPI : BaseDFUPeripheralAPI {
    
    /**
     Checks whether the target device is in application mode and must be switched
     to the DFU mode.
     
     - parameter forceDfu: Should the service assume the device is in DFU Bootloader
                           mode when DFU Version characteristic does not exist and at
                           least one other service has been found on the device.
     
     - returns: `True` if device needs to perform buttonless jump to DFU Bootloader mode.
     */
    func isInApplicationMode(_ forceDfu: Bool) -> Bool
    
    /**
     Scans for a next device to connect to. When device is found and selected, it
     connects to it.
     
     After updating the Softdevice the device may start advertising with an address
     incremented by 1. A BLE scan needs to be done to find this new peripheral
     (it's the same device, but as it advertises with a new address, from iOS point
     of view it completly different device).
     */
    func switchToNewPeripheralAndConnect()
    
    /**
     Returns whether the Init Packet is required by the target DFU device.
     
     Init packet is required since DFU Bootloader version 0.5 (SDK 7.0.0).
     
     - returns: `True` if init packet is required, `false` if not.
     */
    func isInitPacketRequired() -> Bool
    
    /// A flag set when a command to jump to DFU Bootloader has been sent.
    var jumpingToBootloader: Bool { get set }
    /// A flag set when a command to activate the new firmware and reset the device
    /// has been sent.
    var activating: Bool { get set }
    /// A flag set when the library should try again connecting to the device
    /// (it may be then in a correct state).
    var shouldReconnect: Bool { get set }
    /// A unique name that the bootloader will use in advertisement packets
    /// (used since SDK 14).
    var bootloaderName: String? { get set }
}

internal protocol DFUPeripheral : DFUPeripheralAPI {
    associatedtype DFUServiceType : DFUService
    
    /// Selector used to find the advertising peripheral in DFU Bootloader mode.
    var peripheralSelector: DFUPeripheralSelectorDelegate { get }
    
    /// The DFU Service instance. Not nil when found on the peripheral.
    var dfuService: DFUServiceType? { get set }
}

internal class BaseCommonDFUPeripheral<TD : DFUPeripheralDelegate, TS : DFUService> : BaseDFUPeripheral<TD>, DFUPeripheral {
    /// The peripheral selector instance specified in the initiator.
    internal let peripheralSelector: DFUPeripheralSelectorDelegate
    
    internal typealias DFUServiceType = TS
    internal var dfuService: DFUServiceType?
    
    /// This flag must be set to true if switching to bootloader mode is expected
    /// after executing the next operation.
    /// The operation is expecter to reset the device. After the disconnect event
    /// is received the service will try to connect back to the device, or scan
    /// for a new device matching specified selector, depending on
    /// `newAddressExpected` flag value.
    internal var jumpingToBootloader : Bool = false
    /// This flag must be set to true when the firmware upload is complete and
    /// device will restart and run the new fw after executing the next operation.
    internal var activating          : Bool = false
    /// This flag has the same behavior as `jumpingToBootloader`, but it's used
    /// when Invalid state error was received and a reset command will be executed.
    /// The service will reconnect to the same device.
    internal var shouldReconnect     : Bool = false
    /// This flag must be set to true if the device will advertise with a new
    /// device address after it resets. The service will scan and use specified
    /// peripheral selector in order to connect to the new peripheral.
    internal var newAddressExpected  : Bool = false
    /// Expected Bootloader advertised Local Name.
    internal var bootloaderName      : String?
    
    override init(_ initiator: DFUServiceInitiatorBle, _ logger: LoggerHelper) {
        self.peripheralSelector = initiator.peripheralSelector
        super.init(initiator, logger)
    }
    
    // MARK: - Base DFU Peripheral API
    
    override func peripheralDidDiscoverDfuService(_ service: CBService) {
        dfuService = DFUServiceType(service, logger, uuidHelper, queue)
        dfuService!.targetPeripheral = self
        dfuService!.discoverCharacteristics(
            onSuccess: { self.delegate?.peripheralDidBecomeReady() },
            onError: defaultErrorCallback
        )
    }
    
    override func peripheralDidDisconnect() {
        guard !aborted else {
            // The device has resetted. Notify user.
            logger.w("Upload aborted")
            delegate?.peripheralDidDisconnectAfterAborting()
            return
        }
        
        if shouldReconnect {
            shouldReconnect = false
            // We need to reconnect to the device.
            connect(withTimeout: 5.0)
        } else if jumpingToBootloader {
            jumpingToBootloader = false
            if newAddressExpected {
                newAddressExpected = false
                
                // If in Legacy DFU, and `forceScanningForNewAddressInLegacyDfu`
                // is set to true, try first connecting to the same peripheral.
                // Perheps it has not been updated to use incremented address yet.
                if forceScanningForNewAddressInLegacyDfu {
                    // Despite the fact, that a new address is expected,
                    // try to reconnect to the same device.
                    connectOrSwitchToNewPeripheral(after: 2.0)
                } else {
                    switchToNewPeripheralAndConnect()
                }
            } else {
                // Connect again, hoping for DFU mode this time.
                connect(withTimeout: 5.0)
            }
        } else if activating {
            activating = false
            // This part of firmware has been successfully sent.
            
            // Check if there is another part to be sent.
            if delegate?.peripheralDidDisconnectAfterFirmwarePartSent() == true {
                // As we are already in bootloader mode, the peripheral set
                // may be reused for sending a second part.
                connectOrSwitchToNewPeripheral(after: 15.0)
            } else {
                // Upload is completed.
                // Peripheral has been destroyed and state is now .completed.
                // There is nothing to be done here.
            }
        } else {
            super.peripheralDidDisconnect()
        }
    }
    
    override func destroy() {
        super.destroy()
        cleanUp()
    }
    
    // MARK: - DFU Peripheral API
    
    func isInApplicationMode(_ forceDfu: Bool) -> Bool {
        // This method should be overridden if the final implementation supports
        // buttonless jump.
        return false
    }
    
    func isInitPacketRequired() -> Bool {
        // This method should be overridden if the final implementation requires
        // Init Packet in the DFUFirmwareBle.
        return false
    }
    
    func connectOrSwitchToNewPeripheral(after timeout: TimeInterval) {
        // In Legacy DFU the DFU bootloader by default advertises with the
        // same MAC address as the application. However, recent changes in iOS
        // (see: https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/368#issuecomment-619066196)
        // made it necessary for the bootloader to change its address.
        // This requires updating the bootloader or the app on the device, as
        // explaind in the above-mentioned issue.
        // Then, this flag needs to be set to true in the `DFUServiceInitiatorBle`.
        // With that flag equal to true, the library will try to connect to the
        // same device (with a short timeout), and if that fails, will try to
        // scan for a new address using `DFUPeripheralSelector`.
        connect(withTimeout: timeout) { [weak self] in
            // Scan for a new device and connect to it.
            self?.switchToNewPeripheralAndConnect()
        }
    }
    
    func switchToNewPeripheralAndConnect() {
        // Release the previous peripheral.
        peripheral?.delegate = nil
        peripheral = nil
        cleanUp()
        
        guard !aborted else {
            resetDevice()
            return
        }
        
        // Set a scanner timer.
        connectionTimer = DispatchSource.makeTimerSource()
        connectionTimer?.setEventHandler { [weak self] in
            if let self = self {
                self.connectionTimer?.cancel()
                self.logger.w("Scanning timed out returning no matching peripherals!")
                self.logger.d("centralManager.stopScan()")
                self.centralManager.stopScan()
                self.delegate?.error(.failedToConnect, didOccurWithMessage: "No DFU device found.")
            }
        }
        connectionTimer?.schedule(deadline: .now() + connectionTimeout)
        connectionTimer?.resume()
        
        logger.v("Scanning for the DFU Bootloader...")
        let requiredServices = peripheralSelector.filterBy(hint: DFUServiceType.serviceUuid(from: uuidHelper))
        logger.d("centralManager.scanForPeripherals(withServices, \(requiredServices?.description ?? "nil")")
        centralManager.scanForPeripherals(withServices: requiredServices)
    }
    
    // MARK: - Peripheral Delegate methods
    
    override func centralManager(_ central: CBCentralManager,
                                 didDiscover peripheral: CBPeripheral,
                                 advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Is this a device we are looking for?
        if peripheralSelector.select(peripheral, advertisementData: advertisementData as [String : AnyObject],
                                     RSSI: RSSI, hint: bootloaderName) {
            // Hurray!
            connectionTimer?.cancel()
            connectionTimer = nil
            central.stopScan()
            
            if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
                logger.i("DFU Bootloader found with name \(name)")
            } else {
                logger.i("DFU Bootloader found")
            }
            
            self.peripheral = peripheral
            connect()
        }
    }
    
    // MARK: - DFU Controller API
    
    override func pause() -> Bool {
        guard let dfuService = dfuService, !aborted else { return false }
        return dfuService.pause()
    }
    
    override func resume() -> Bool {
        guard let dfuService = dfuService, !aborted else { return false }
        return dfuService.resume() == false // resume() returns the 'paused' value.
    }
    
    override func abort() -> Bool {
        aborted = true
        
        guard let dfuService = dfuService else {
            // DFU service has not yet been found.
            
            // Peripheral is `nil` when the
            // `switchToNewPeripheralAndConnect(_ selector:DFUPeripheralSelector)`
            // method was called and the second peripheral has not been found yet.
            // Delegate is nil when peripheral was destroyed.
            if let delegate = delegate, peripheral == nil {
                logger.w("Upload aborted. Part 1 flashed sucessfully")
                centralManager.stopScan()
                delegate.peripheralDidDisconnectAfterAborting()
            }
            return true
        }
        
        logger.w("Aborting upload...")
        return dfuService.abort()
    }
    
    // MARK: - Private methods
    
    fileprivate override func cleanUp() {
        super.cleanUp()
        dfuService?.destroy()
        dfuService = nil
    }
}
