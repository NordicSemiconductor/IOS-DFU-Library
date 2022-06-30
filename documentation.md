# DFU Library - iOS

The DFU Library for iOS 9+ adds the DFU feature to the iOS project. It is written in Swift 5.2 but is compatible with Objective-C.

### Features:

* Allows to program Application, Soft Device and Bootloader Over-the-Air on the nRF51 Series SoC over Bluetooth Smart.
* Supports HEX or BIN files.
* Supports zip files with Soft Device, Bootloader and Application together.
* Supports the Init packet (which has been required since Bootloader/DFU from SDK 7.0+).
* Performs the DFU operation in the background service.
* Displays the notification with progress.
* Provides delegates with state, progress, errors or log events to the application.
* Handles bonded devices and buttonless update.
* iOS DFU Library is compatible with all Bootloader/DFU versions.
  * Only the application may be updated with the bootloader from SDK 4.3.0. An error will be broadcast in case of sending a Soft Device or a Bootloader.
  * When App, SD and BL files are in a zip file, the service will try to send the SD and BL together, which is supported by Bootloader/DFU from SDK 6.1+. Once completed, the service will reconnect to the new bootloader and send the Application in the second connection as part two.

#### Error handling
In case of any communication error the peripheral device will never be bricked. When an application or a bootloader is updated, the previous application (or bootloader, in case there was no application) is restored. When a Softdevice is updated, the previous bootloader will be restored as the application had to be removed to in order to make space for the new version of the Softdevice. You will still be able to repeat the update and flash the Softdevice and the new application again.

### Known issues

1. Since iOS 13.3 (?) devices with Legacy DFU that do not use bonding, but use direct advertising in DFU Bootloader mode cannot be updated anymore.
    The same applies to Android devices with latest security patches. The solution is to modify the bootlaoder on a device to use non-direct advertising, but
    in order to update devices that are already in production, older, not updated devices are required. Nothing can be done on the library side, as the iOS
    just stopped reporting such advertising packets.

### Requirements

* **An iPhone 4S or iPad 2 or newer with iOS 9+**

  Support for the Bluetooth 4.0 technology is required.
* **nRF5x device for testing.**

  A nRF5x Series device is required to test the working solution. If your final product is not available, use the nRF5x DK, which you can find [here](http://www.nordicsemi.com/eng/Products/nRF51-DK "nRF51 DK") or 

### Usage

To start the DFU process you have to do 2 things:

1. Create a `DFUFirmware` object using a `URL` to a Distribution Packet (ZIP), or using a `URL`s to a BIN/HEX file, DAT file (optionally) 
    and by specifying a file type (Softdevice, Bootloader or Application).

     Objective-C:
    ```objective-c 
    DFUFirmware *selectedFirmware = [[DFUFirmware alloc] initWithUrlToZipFile:url];
    // or
    DFUFirmware *selectedFirmware = [[DFUFirmware alloc] initWithUrlToBinOrHexFile:url urlToDatFile:dtUrl type:type];
    ```
    Swift:
    ```swift
    let selectedFirmware = try DFUFirmware(urlToZipFile: url)
    // or
    let selectedFirmware = try DFUFirmware(urlToBinOrHexFile: url, urlToDatFile: datUrl, type: .application)
    ```

2. The `DFUFirmware` object allows you to get basic information about the firmware, like sizes of each component or number of parts. 
    Number of parts is the number of connections required to send all content of the Distribution Packet. It is equal to 1 unless a ZIP file 
    contain a Softdevice and/or Bootloader and an Application. The Softdevice and/or Bootloader will be sent as part one, then the DFU 
    target device will disconnect, reset and DFU Service will connect again and send the Application as part 2.

3. Use the `DFUServiceInitializer` to initialize the DFU process.

    Objective-C:
    ```objective-c
    DFUServiceInitiator *initiator = [[DFUServiceInitiator alloc] init];
    [initiator withFirmware:selectedFirmware];
    // Optional:
    // initiator.forceDfu = YES/NO; // default NO
    // initiator.packetReceiptNotificationParameter = N; // default is 12
    initiator.logger = self; // - to get log info
    initiator.delegate = self; // - to be informed about current state and errors 
    initiator.progressDelegate = self; // - to show progress bar
    // initiator.peripheralSelector = ... // the default selector is used
   
    DFUServiceController *controller = [initiator startWithTarget: peripheral];
    ...
    ```
    Swift:
    ```swift
    let initiator = DFUServiceInitiator().with(firmware: selectedFirmware)
    // Optional:
    // initiator.forceDfu = true/false // default false
    // initiator.packetReceiptNotificationParameter = N // default is 12
    initiator.logger = self // - to get log info
    initiator.delegate = self // - to be informed about current state and errors 
    initiator.progressDelegate = self // - to show progress bar
    // initiator.peripheralSelector = ... // the default selector is used

    let controller = initiator.start(target: peripheral)
    ...
    ```
4. Using the `DFUServiceController` you may pause, resume or abort the DFU operation.

### Example

Check the nRF Toolbox project ([here](https://github.com/NordicSemiconductor/IOS-nRF-Toolbox "nRF Toolbox")).

### Issues

Please, submit all issues to the iOS Pods DFU Library [here](https://github.com/NordicSemiconductor/IOS-DFU-Library/issues "Issues").
