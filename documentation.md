# DFU Library - iOS

The DFU Library for iOS 8+ adds the DFU feature to the iOS project. It is written in Swift 3.0.1 but is compatible with Objective-C.

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

### Requirements

* **An iPhone 4S or newer with iOS 8+**

    Support for the Bluetooth 4.0 technology is required.
* **nRF5x device for testing.**

   A nRF5x Series device is required to test the working solution. If your final product is not available, use the nRF51 DK, which you can find [here](http://www.nordicsemi.com/eng/Products/nRF51-DK "nRF51 DK") or [here](http://www.nordicsemi.com/eng/Products/Bluetooth-Smart-Bluetooth-low-energy/nRF52-DK "nRF52 DK").

### Integration

To include the library in your project do one of those options:

1. Cocoapods (recommended):

   Open up a terminal window, cd to your project's root and create a `Podfile` with the follwoing content:

   ```
   use_frameworks!
   target 'YourAppTargetName' do
       pod 'iOSDFULibrary'
   end
   ```
   Then install dependencies
   ```
   pod install
   ```

   **Notice:** Our Cocoapods releases will always be the exact same version as this repository. you may [follow our pod repository here](http://github.com/NordicSemiconductor/IOS-Pods-DFU-Library).

2. Include the library as a precompiled framework:

   Copy the DFULibrary.framework file to you project.
   Add this framework to Embedded Binaries in the Target->Settings->General.

3. Include the library as source code:

   Create a Workspace (if you already don't have one).
   Add your project to the workspace.
   Add the DFULibrary.xcodeproj file below your project, on the same level:
```
   MyProject
    - MyProject
    - MyProjectTests
    - Products
   DFULibrary
    - DFULibrary
    - DFULibraryTests
    - Frameworks
    - Products
        - DFULibrary.framework      <- this file
        - DFULibraryTests.xctest
```
   Add (drag&drop) the DFULibrary.framework product file to your Target's Embedded Binaries.
   A framework build may be necessary. The framework must exist (color black, not red).

If you decide to use option **2** or **3**,  make sure you have the `Embedded Content contains Swift code` set to `YES` in your target's **Build Options->Build Settings**

### Usage

To start the DFU process you have to do 2 things:

1. Create a DFUFirmware object using a NSURL to a Distribution Packet (ZIP), or using a NSURLs to a BIN/HEX file, DAT file (optionally) and by specifying a file type (Softdevice, Bootloader or Application).

     Objective-C:
    ```objective-c 
    DFUFirmware *selectedFirmware = [[DFUFirmware alloc] initWithUrlToZipFile:url];
    // or
    DFUFirmware *selectedFirmware = [[DFUFirmware alloc] initWithUrlToBinOrHexFile:url urlToDatFile:dtUrl type:type];
    ```
    Swift:
    ```swift
    let selectedFirmware = DFUFirmware(urlToZipFile:url)
    // or
    let selectedFirmware = DFUFirmware(urlToBinOrHexFile: url, urlToDatFile: datUrl, type: DFUFirmwareType.Application)
    ```

2. The DFUFirmware object allows you to get basic information about the firmware, like sizes of each component or number of parts. Number of parts is the number of connections required to send all content of the Distribution Packet. It is equal to 1 unless a ZIP file contain a Softdevice and/or Bootloader and an Application. The Softdevice and/or Bootloader will be sent as part one, then the DFU target device will disconnect, reset and DFU Service will connect again and send the Application as part 2.

3. Use the DFUServiceInitializer to initialize the DFU process.

    Objective-C:
    ```objective-c
    DFUServiceInitiator *initiator = [[DFUServiceInitiator alloc] initWithCentralManager: centralManager target:selectedPeripheral];
    [initiator withFirmware:selectedFirmware];
    // Optional:
    // initiator.forceDfu = YES/NO; // default NO
    // initiator.packetReceiptNotificationParameter = N; // default is 12
    initiator.logger = self; // - to get log info
    initiator.delegate = self; // - to be informed about current state and errors 
    initiator.progressDelegate = self; // - to show progress bar
    // initiator.peripheralSelector = ... // the default selector is used
   
    DFUServiceController *controller = [initiator start];
    ...
    ```
    Swift:
    ```swift
    let initiator = DFUServiceInitiator(centralManager: centralManager, target: peripheral).with(firmware: selectedFirmware)
    // Optional:
    // initiator.forceDfu = true/false; // default false
    // initiator.packetReceiptNotificationParameter = N; // default is 12
    initiator.logger = self; // - to get log info
    initiator.delegate = self; // - to be informed about current state and errors 
    initiator.progressDelegate = self; // - to show progress bar
    // initiator.peripheralSelector = ... // the default selector is used

    let controller = initiator.start()
    ...
    ```
4. Using the DFUServiceController you may pause, resume or abort the DFU operation.

5. In version 3 the API has slightly changed to better match the Swift 3 naming guidlines: 

- The initiator's delegate and progressDelegate methods got renamed
- The **SecureDFUError**, **SecureDFUProgressDelegate** and **SecureDFUServiceDelegate** have been removed (it was not accesible). Callbacks for Secure DFU are now reported by **DFUProgressDelegate** and **DFUServiceDelegate**. **DFUError** contains all secure DFU errors.
- ```withFirmwareFile(_)``` method in **DFUServiceInitiator** has been renamed to ```with(firmware:)```

Other changes in version 3:

- Complete refactoring of the code
- Support for connected devices (even if DFU Service has not been discovered when DFU started)
- DFU now works on iOS 8 (bug fixed)
- Other bugs fixed

### Example

Check the nRF Toolbox project ([here](https://github.com/NordicSemiconductor/IOS-nRF-Toolbox "nRF Toolbox")) for usage example (Objective-C).

### Issues

Please, submit all issues to the iOS Pods DFU Library [here](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues "Issues").
