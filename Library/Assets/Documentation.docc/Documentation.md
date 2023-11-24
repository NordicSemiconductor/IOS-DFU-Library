# ``NordicDFU``

A Swift library for updating firmware of nRF51 and nRF52 devices using Bluetooth LE.

## Overview

The DFU Library allows to update nRF51 and nRF52 devices running firmware based on 
[nRF5 SDK](https://infocenter.nordicsemi.com/topic/struct_sdk/struct/sdk_nrf5_latest.html?cp=9_1)
starting from version 4.3 until the latest one.

The nRF5x Series chips are flash-based SoCs, and as such they represent the most flexible solution available. 
A key feature of the nRF5x Series and their associated software architecture and S-Series SoftDevices is the 
possibility for Over-The-Air Device Firmware Upgrade (OTA-DFU). OTA-DFU allows firmware upgrades to be issued 
and downloaded to products in the field via the cloud and so enables OEMs to fix bugs and introduce new features 
to products that are already out on the market. This brings added security and flexibility to product development 
when using the nRF5x Series SoCs.

> Important: This library is not compatible with [Zephyr](https://docs.zephyrproject.org/latest/index.html)
             or [nRF Connect SDK (NCS)](https://docs.nordicsemi.com/bundle/ncs-latest/page/nrf/index.html). 
             To update devices built on those SDKs use 
             [nRF Connect Device Manager](https://github.com/NordicSemiconductor/IOS-nRF-Connect-Device-Manager/) 
             library instead.

## Supported Features

* Allows to update the Application, SoftDevice and/or the Bootloader Over-the-Air on the 
  nRF51 and nRF52 Series SoC over Bluetooth LE.
* Supports ZIP, HEX or BIN files.
* ZIP files may contain a SoftDevice, Bootloader and Application in a single file.
* Supports the Init packet (which has been required since Bootloader/DFU from SDK 7.0+).
* Provides delegates with state, progress, errors or log events to the application.
* Handles bonded devices and buttonless update.
* Recovering after upload error.

- note: The protocol has build in recovery mechanism in case of a communication error. 
        When an application or a bootloader is updated, the previous version is restored. 
        As the SoftDevice requires more space for double-bank update and in most cases the Application
        has to be erased, but the device can be recovered using the DFU bootloader.

## Usage

To start the DFU process you have to do 2 things:

1. Create a ``DFUFirmware`` object using a URL to a Distribution Packet (ZIP), or using a URLs to 
   a BIN/HEX file, DAT file (optionally) and by specifying a file type (Softdevice, Bootloader or 
   Application).

   ```swift
   let selectedFirmware = try DFUFirmware(urlToZipFile: url)
   // or
   let selectedFirmware = try DFUFirmware(urlToBinOrHexFile: url, urlToDatFile: datUrl, type: .application)
   ```

   The `DFUFirmware` object allows you to get basic information about the firmware, like sizes 
   of each component or number of parts. Number of parts is the number of connections required
   to send all content of the Distribution Packet. It is equal to 1 unless a ZIP file contain 
   a Softdevice and/or Bootloader and an Application, in which case it's equal to 2. 
   The Softdevice and/or Bootloader will be sent as part one, then the DFU target device will 
   disconnect, reset and DFU Service will connect again and send the Application as part 2.

2. Use the ``DFUServiceInitiator`` to initialize the DFU process.

   ```swift
   let initiator = DFUServiceInitiator()
   // Optional:
   // initiator.forceDfu = true/false // default false
   // initiator.packetReceiptNotificationParameter = N // default is 12
   initiator.logger = self // - to get log info
   initiator.delegate = self // - to be informed about current state and errors 
   initiator.progressDelegate = self // - to get progress updates
   // initiator.peripheralSelector = ... // the default selector is used
   
   let controller = initiator.with(firmware: selectedFirmware).start(target: peripheral)
   ```
   Using the ``DFUServiceController`` you may pause, resume or abort the DFU operation.

## Topics

### Initialization

- ``DFUServiceInitiator``
- ``DFUServiceDelegate``
- ``DFUState``
- ``DFUError``
- ``DFUServiceController``
- ``DFUPeripheralSelectorDelegate``
- ``DFUPeripheralSelector``

### Firmware

- ``DFUFirmware``
- ``DFUFirmwareSize``
- ``DFUFirmwareType``
- ``DFUFirmwareError``
- ``DFUStreamZipError``
- ``DFUStreamHexError``

### Reporting progress

- ``DFUProgressDelegate``

### Logging

- ``LoggerDelegate``
- ``LogLevel``

### Advanced

- ``LegacyDFUServiceInitiator``
- ``SecureDFUServiceInitiator``
- ``DFUUuidHelper``
- ``DFUUuid``
- ``DFUUuidType``
- ``IntelHex2BinConverter``
