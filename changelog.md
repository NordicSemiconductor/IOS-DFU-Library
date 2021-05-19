### Changelog
- **4.10.3**
   - Project compilation available for Arm Simulators (#423).
   
- **4.10.2**
   - Bugfix: Fixed compilation issue in Xcode 12.4 ([#417](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/417)).
   
- **4.10.1**
   - Bugfix: A log message was incorrectly shown pointing to a solution to non-existing problem ([#419](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/419)). 
   
- **4.10.0**
   - Improvement: Guarantee word-aligned writes to the packet characteristic ([#366](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/366)).
   - Improvement: Extended DFU Connection Timeout from 3 to 15 seconds ([#411](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/411)).
   - Warning fix: Fixed 'deprecated class keyword for protocol objects' ([#410](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/410)).
   - Migration to Xcode 12.5 and Swift 5.4.
   - Support for Apple watchOS and tvOS on CocoaPods ([#412](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/412)).
   - Bigfix: Unwrapping optionals fixed ([#413](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/413)).
   - Bugfix: Truncating too long advertising names ([#415](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/415)).
   - Improvement: Add links to Xamarin binding libraries (#389 and #401).
   - Improvement: Add syntax highlighting to readme ([#402](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/402)).
   
- **4.9.0**
   - ZIPFoundation version set to 0.9.11.
   - Migration to Swift 5.3.
   - Improvement: Reconnection timeout improvements ([#386](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/386)).
   - Improvement: Asynchronous firmware provider in the sample app ([#387](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/387)).
   
- **4.8.0**
   - Feature: Option to force scanning for Legacy DFU bootloader after jumping using Buttonless Service ([#374](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/374)).
   - Feature: Option to set connection timeout ([#369](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/369)).
   - Feature: Option to set data object preparation delay ([#377](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/377)).
   
- **4.7.2**
   - Improvement: Report error when bluetooth is turned off ([#371](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/371)).
   - Bugfix: Fixed Carthage configuration (shared schemes) ([#370](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/370)).

- **4.7.1**
   - Bug fixed: A log message was added to help solve #365 issue.
   - Bug fixed: DFU will not proceed when setting alternative advertising name caused disconnection ([#367](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/367)).
   - Bug fixed: Tests for nRF52840 fixed. 

- **4.7.0**
   - Improvement: Migration to Swift 5.2.
   
- **4.6.1**
   - Bugfix: DFU stability improved for DFU from SDK 15 and newer.
   - Improvement: DFU tests for SDK 15.3 and 16 added.
   - Bugfix: MInor issue fixed in the sample app.
   
- **4.6.0**
    - Feature: Automatic retrying DFU on disconnection during update. 
    - Bugfix: Some delegates were called on a wrong queue ([#339](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/339)).
    - Bugfix: DFU from SDK 6.0 fixed. PRN is forced set to 1. 
    - Improvement: The sample app has been modified to work on iOS 13.
    
- **4.5.1**
    - Bugfix: Fixed an issue where DFU could not be started on iOS 13 ([#322](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/322)). 
    
- **4.5.0**
    - Improvement: Hex2Bin converter rewritten to Swift 5.
    - Library released in Swift Package Manager (SPM).

- **4.4.2**
    - Bugfix: Missing buttonless service statuses added ([#297](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/297)).
    - Improvement: Added support for older Swift versions ([#295](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/295)).
    - Improvement: ZIPFoundation dependency bound to 0.9.9.

- **4.4.1**
    - Bugfix: Fixed calculating number of bytes received from PRN ([#288](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/288)).
    - Improvement: ZIPFoundation dependency upgraded to 0.9.9 ([#281](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/281)).

- **4.4.0**
    - Improvement: Swift 5.0 migration.
    - Improvement: New App Store icon added to supress the warning.
    - Bugfix: Fixed name conflict when adding the library manually ([#293](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/293)).
    - Bugfix: Fixed displaying total progress in the sample app.

- **4.3.0**
    - Improvement: Zip dependency switched to ZipFramework ([#251](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/251)).
    - Improvement: Dispatching delegates in designated queues ([#249](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/249)).
    - Improvement: Added option to disable resuming Secure DFU operation ([#264](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/264)).
    - Improvement: Attempt to send an App when SD+BL update failed with remote error ([#266](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/266)).
    - Improvement: Extended errors exposed ([#262](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/262)).
    - Bugfix: Fixed a crash during restarting DFU ([#269](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/269)).
    - Bugfix: Fixed resuming Secure DFU on SDK 15 ([#270](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/270)).
    - Bugfix: Typos in 2 error constants fixed ([#263](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/263)).

- **4.2.2**
    - Bugfix: Fixed issue #245 where operationFailed error messages where not reported in some cases.

- **4.2.1**
    - Bugfix: Fixed issue causing a crash when the target peripheral was set to `nil` and `discoverServices()` got called.
    - Bugfix: Raised MacOS Deployment target to 10.14 due to missing `identifier` property on `CBPeripheral` to avoid hacky workarounds.

- **4.2.0**
    - Improvement: Swift 4.2 migration.
    - Improvement: Added .swift-version file.
    - Improvement: UUID Helper that allows using custom service identifiers for DFU.
    - Improvement: Jazzy Docs can now be easily generated.
    - Improvement: Added more logging to services on not supported devices.
    - Improvement: DFU no longer takes control over delegates.
    - Improvement: Refactoring and comments have been improved.
    - Improvement: Added more DFU automated tests, covering SDK 15 and 15.2 + some older SDKs due to a MBR workaround.
    - Improvement: Improved error handling.
    - Bugfix: The previous ZIP files from SDK 14+ had bootloaders with disabled Service Changed characteristic.
    - Bugfix: Fixed memory cycle caused by a strong delegate reference.
    - Bugfix: Fixed update failures because of device disconnects.

- **4.1.3**
    - Bugfix: Fix by @simonseyer that resolves a random disconnects issue caused by the reuse of the same CBCentralManager used by the library, which received callbacks of device disconnects that might not be the target perpiheral
    - Bugfix: Fix by @alanfischer that resolves an Xcode warning related to documentation.

- **4.1.2**
    - Bugfix: Fixed an issue introduced in 4.1.1 that caused legacy DFU to fail on some devices
    - Bugfix: Fixed missing information in the documentation that explains how to enable the experimental buttonless DFU feature
    - Improvement: Added test suites in the example app, this is available via the `pod try` command. It allows to automate testing of the DFU library using bootloaders from different SDKs on nRF51, nRF52832 and nRF840. It also provides a way to automate testing of custom firmware chain upgrade (v1.0 -> v2.0 -> v3.0, etc..).

- **4.1.1**
    - Bugfix: Fixed an issue with DFU processes that had multiple DFU parts that caused the executor to connect to wrong peripherals after flashing the first part.
	      The peripheral is now held in memory until it comes back online, so the library will no longer scan for DFU peripherals while waiting for it to restart.
    - Bugfix: Fixed an issue related to the new address expected flag.
    - Improvement: Carthage support for MacOS.
    - Improvement: Firmware size information is now available for Obj-C projects.
    - Improvement: Added required imports for projects built without Cocoapods.

- **4.1.0**
    - Improvement: Using iOS 11's new `canSendWriteWithoutResponse` API to remove the need of using packet receipt notifications, setting a PRN value of 0 on iOS 11 will enable this feature.
    - PRN will still be used as the default option.

- **4.0.3**
    - Improvement: Added option to disable peripheral rename feature in bootloader mode, This also fixes issue #159.

- **4.0.2**
    - Bugfix: Fix for issue#149 which was caused by a false return in the selector method.

- **4.0.1**
    - Bugfix/Improvement: Added @objc tags for Xcode projects that are built with no Objc inference.

- **4.0**:
    - Feature: Migration to Swift 4.

- **3.2.1**:
    - Feature: Convenience to start the DFU process with zip Data instead of Zip file URL.

- **3.2.0**:
    - Feature: Support for higher MTUs added on capable iOS devices.
    - Feature: Setting bootloader name (SDK 14 feature).
    - Deprecation: `select(_ peripheral:, advertisementData:, RSSI:)` is now deprecated in favor of: `select(_ peripheral:, advertisementData:, RSSI:, hint:)`.
    - Bugfix: Report proper size of SoftDevice and Bootloader when not given in manifest file (for secure DFU).
    - Enhancement: Minor code refactor and minor updates to comments/documentation.
    - Enhancement: All orientations supported in the example application.
    - Enhancement: macOS API check for MTU.

- **3.1.0**:
    - Workaround: minor fix to circumvent an issue with SDK 6.1 when the link is lost during firmware upload resulting in an operation failed error (Code 6).
    - Enhancement: Minor code refactor for Data struct manipulation.

- **3.0.6**:
    - Bugfix: Fixed issue that was introduced in 3.0.5 causing Zip framework not to be built, this patch shares the Zip scheme, allowing both frameworks to be built by carthage.

- **3.0.5**:
    - Bugfix: Removed Cartfile since it caused conflicts for users building using Carthage, Zip is already bundled via Cocoapods and no further installation is necessary.

- **3.0.4**:
    - Feature: `restart()` method restored in `DFUServiceController`.
    - Bugfix: Fixed error reporting when Buttonless jump fails.
    - Bugfix: Crash on aborting when peripheral is changing ([#72](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/72)).
    - Enhancement: A lot of minor code improvements.

- **3.0.3**:
    - Documentation warning fixed ([#68](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/68)).
    - License changed to BSD 3-Clause in Podspec.

- **3.0.2**:
    - Bugfix: Ignoring updates from non-DFU characteristics ([#66](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/66)).
    - Enhancement: Log messages improved for connected devices.

- **3.0.1**:
    - Bugfix: Crash if DFU Characteristic isn't found ([#64](https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library/issues/64)).
    - Bugfix: Discovering all services to determine mode for Legacy bootloaders without DFU Version char.
    - Enhancement: License changed to BSD 3-Clause.

- **3.0.0**:
    - Enhancement: A lot of code has been rewritten. API has slightly changed and now matches better Swift 3 requirements.
    - Feature: Better support for starting DFU on already connected devices.

- **2.1.6**:
    - Bugfix: Peripherals that are already connected now will start the DFU Process right away instead of halting.

- **2.1.5**:
    - Enhancement: Added `@ObjC` to `DFUPeripheralSelectorDelegate` to help with Obj-C Based project integration.
    - Enhancement: Minor typo fix in peripheral State.
    - Enhancement: Minor enhancement to the `LoggerHelper` class.

- **2.1.4**:
    - Enhancement: Added Cartfile for denpendency libraries.

- **2.1.3**:
    - Bugfix: Fixed an issue with PRN value not being fully used throughout the DFU process and at some points reverted to the default value.
    - Bugfix: Fixed issue with specific packet sizes that caused the last packet not to be executed due to PRN being received earlier than expected.
    - Enhancement: Updated Readme to show SDK12's support.

- **2.1.2**:
    - Feature: Added a failsafe solution for cases of an irrecoverable resume in the DFU process that simply starts the process from scratch ignoring it's state.
    - Bugfix: Fixed issue causing the DFU process to constantly fail after peripheral is reset during the process.
    - Bugfix: Fixed issue #14 that caused a crash when the logger delegate wasn't being set.

- **2.1.1**:
    - Feature: Carthage is now fully supported.

- **2.1**:
    - Deprecation: Deprecated enums are now obsolete: `State` is now `DFUState`, `StatusCode` is now `DFUResultCode`, `OpCode` is now `DFUOPCode`.
    - Bugfix: Fixed issue in test target having a missing framework path.
    - Bugfix: Fixed return values of Pause, Resume and Abort DFU methods that were returning wrong values.

- **2.0.1**:
    - Bugfix: Fixed accidentally removed files in v2.0.

- **2.0**:
    - Feature: Migrated to Swift 3.0 Xcode 8.
    - Bugfix: Issue where PRN `Packet Receipt Notification` values being overriden were ignored is now resolved.

- **1.0.12**:
    - Enhancement: Refactored code to remove warnings about deprecation in Siwft3 and some other related warnings.

- **1.0.11**:
    - Feature: Added ability to pause and resume DFU uploads.
    - Feature: Added new status enum `Failed` to report general connection failures.
    - Bugfix: Fixed issue with connection interruption not being handled properly.
    - Bugfix: Fixed issue with Abort opertation not being completed.
    - Bugfix: Fixed issue with some states where `Aborted` was being used, replaced with `Failed`.

- **1.0.10b**:
    - Bugfix: Fixes overflow crash when the peripheral has received 100% of the firmware but couldn’t execute.

- **1.0.9b**:
    - Feature: This version preps the Secure DFU feature for production, it is now a part of the development process.

- **1.0.8**:
    - Enhancemen: iOSDFULib is now up to date with the standalone library stability wise, this means it's now been bumped up to version 1.0.8.
    - Feature: Implemented Extended error feature.
    - Feature: Reverted bugfix in **0.1.16** that disabled extended error feature.

 - **0.1.18**: 
    - Feature: Implemented new response code `operation_not_permitted`.
 
 - **0.1.17**: 
    - Bugfix: iOS10 bug fix that caused the dfu process not to initialize.
 
 - **0.1.16**: 
    - Bugfix: Added earlier Secure DFU Signature mismatch handling without Extended error feature for backwards compatibility.
 
 - **0.1.15**: 
    - Enhancemen: Added more verbose logging for debug purposes.
 
 - **0.1.14**:
     - Feature: On DFU interruption, the next attempt always showed an peripheral in invalid state error, this is now bypassed by sending a reset 
       command and reconnecting automaticaly, the handler will attempt to do that 3 times before throwing the appropriate error.
 
 - **0.1.13**:
    - Bugfix: `@objc` attributes where missing from `LogLevel` enum and `LoggerDelegate` protocol, making thenm unavailable to Obj-C code.

 - **0.1.12**: 
    - Bugfix: some secure DFU error codes where conflicting with Legacy DFU error codes, causing random misbehavior.
 
 - **0.1.11**:
    - Bugfix: Fixed a bug causing DFU process to randomly halt and send impty packets to the peripheral, due to a race condition.
    - Feature: Removed one of the dependencies (EVReflection) in an appempt to make the library self contained.

- **0.1.10**:
    - Enhancement: Added Signature mismatch handling and better logging. 
    - Bugfix: iOS10 bug that caused dfu process not to start.

- **0.1.9**:
    - Feature: Added a reset feature to allow flashing after an interruption due to connection issues or user aborting the process, 
      this used to throw an invalid state error, handler will now retry 3 times before failing.
    - Feature: Added a fully working example app for users why `pod try` the library, this will attempt to flash the bundled firmware file `hrs_dfu_s132_2_0_0_7a_sdk_11_0_0_2a.zip`.
    - Feature: iOS target lowered to 8.0, Added OSX 10.10 Target.

- **0.1.8**:
    - Enhancement: Removed unnecessary requirement to include a .dat file while uploading a hex, which caused some issues.

- **0.1.7**:
    - Bugfix: Fixed all missing links.

- **0.1.6**:
    - Bugfix: Fixed broken link in documentation.  

- **0.1.5**:
    - Enhancement: Improved readme.

- **0.1.4**:
    - Enhancement: Removed unnecessary public headears from PodSpec.

- **0.1.3**:
    - Enhancement: Removed extraneous IntelHextBin module as it's no longer necessary.

- **0.1.2**:
    - Bugfix: Added Pod name that caused a missing reference issue and other minor bugfixes.

- **0.1.1**:
    - Bugfix: Release/Debug configurations had a missing reference.

- **0.1.0**:
    - Initial Pod implementation.
