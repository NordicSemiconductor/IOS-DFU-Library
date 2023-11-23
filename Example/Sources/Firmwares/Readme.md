## How to test DFU:

1. In each of the device folders there is one HEX file and number of ZIP files. Each HEX file contains complete firmware
    with SoftDevice, Application with buttonless service, DFU Bootloader and bootloader settings.
2. Connect your nRF5 DK to the computer and flash the HEX file onto it (for example using Drag&Drop, or nrfjprog).
3. Launch DFU Example application on your iDevice.
4. You should see a device advertising with a name "DFU<board-id><mode><version>", where:
```
  Board ID:
  1 = nRF51
  2 = nRF52832
  3 = nRF52840

  Mode:
  A = Application
  B = Bootloader

  Version:
  SDK version, without a dot. For example 141 = SDK 14.1, 08 = SDK 8, 061 = SDK 6.1
```
5. Tap a selected device and then Connect button.
6. Full test, depending on selected target, should take several minutes. In that time the app will try
   to downgrade the device to lowest possible SDK testing almost all possible scenarios.

### Notes:

1. For nRF51 this test downgrades SD+BL+App from SDK 12.2 to 6.0. For other targets it upgrades from oldest supported (see note below)
   to the current one.
2. Downgrade from SDK 12.x+ to 11 requires switching from Secure DFU to Legacy DFU, so it can't be done with a single ZIP file
   as the iOS DFU Library selects the DFU method only once during the first connection. Therefore it will first upload only SD+BL,
   and start a new upload to the new device to upload Application only.
3. Upgrading from SDK 11 to 12.x was skipped as it wasn't working. The new BL have been erasing a page from SD space after being flashed
    and the failed to start advertising.
4. Not all SDK are coveded here, only those where DFU has been modified.
5. List of ZIP files may change in the furure as more SDKs are released.
6. All Apps and Bootloaders have Service Changed service enabled to prevent iOS from caching. This test does not test DFU on bonded devices.

## Custom DFU test

1. Copy your ZIP file to Resources/Custom folder. By default you'll find there HEX and ZIP that can be used on nRF51 DK, but feel free to remove them.
    Only one ZIP file can be in the Custom folder, unless you also modify the CustomTestSet class.
2. Select DFU Target in the app and click Connect button to start upload.
3. If you can't see your device on the Scanner page, make sure the UUIDs used to filter are correct. You may add your own UUID if required.

## nrfutil

To create ZIP packages use nrfutil tool (https://github.com/NordicSemiconductor/pc-nrfutil). For Legacy DFU use branch with version 0.5.x.
Each next BL must have higher BL version, therefore it is no possible to update a ZIP that includes a BL more than once and they need to be
sent in increasing order. To check what's in a ZIP file (decode the init packets in dat files) use 'nrfutil pkg display [file_name.zip]'.
