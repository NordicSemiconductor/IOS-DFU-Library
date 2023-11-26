# Test App

Here you'll find the source code of an app designed for automated tests of Legacy and Secure DFU.

![Scanner](Resources/Screenshot%20-%20scanner.png) 
![Test](Resources/Screenshot%20-%20test.png)

## Setup

Automated tests require a nRF5x DK. Supported DKs are:
* nRF51 DK - to test Legacy DFU from SDK 6 - 12.2.
* nRF52832 DK - to test Secure DFU from SDK 12.2 - 16
* nRF52840 DK - to test Secure DFU from SDK 13 - 17.1

1. Program the DK with a HEX file which you will find in *Sources/Firmwares/<DK>*. 
2. The DK should start advertising.
3. Start the Test App (*DFU Tester*) and select a device with name *DFU...*.

Find detailed instudcions [here](Sources/Firmwares).