//
//  DfuStrings.swift
//  dfu
//
//  Created by Nordic on 05/04/2022.
//

struct DfuStrings {
    static let testTitle = "Title"
    static let testLoremIpsumLong = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum"
    
    static let dfuTitle = "DFU"
    
    static let welcomeTitle = "Welcome"
    static let welcomeStart = "Start"
    static let welcomeText = "The Device Firmware Update (DFU) app allows updating the firmware of Bluetooth LE devices over-the-air (OTA). It is compatible with nRF51 and nRF52 devices from Nordic Semiconductor running nRF5 SDK based applications with DFU bootloader enabled.\n\nFor more information about the DFU, see the About DFU section in Settings.\n\nTo update a nRF Connect SDK (NCS) based device, use nRF Connect Device Manager app instead."
    static let numberOfPackets = "Number of Packets"
    static let numberRequest = "Please provide number:"
    static let cancel = "Cancel"
    static let ok = "Ok"
    static let empty = ""
    static let select = "Select"
    static let file = "File"
    static let device = "Device"
    static let progress = "Progress"
    static let abort = "Abort"
    static let aborted = "Aborted"
    static let upload = "Upload"
    static let settings = "Settings"
    static let scanner = "Scanner"
    static let nearbyOnly = "Nearby only"
    
    static let firmwareUpload = "Firmware upload"
    static let firmwareUploaded = "Firmware uploaded"
    static let firmwareUploading = "Uploading firmware..."
    static let firmwareUploadPart = "Uploading part %d of %d"
    static let firmwareUploadSpeed = "Speed: %.1f kB/s"
    
    static let resultCompleted = "Completed"
    static let resultError = "Error: %@"
    
    static let fileSelect = "Select a .zip file"
    static let fileName = "File name: %@"
    static let fileSize = "File size: %d"
    
    static let deviceSelect = "Select a device"
    static let deviceName = "Device: %@"
    
    static let bootloaderIdle = "Bootloader enablement"
    static let bootloaderInProgress = "Enabling bootloader..."
    static let bootloaderFinished = "Bootloader enabled"
    
    static let dfuIdle = "DFU initialization"
    static let dfuInProgress = "Initializing DFU..."
    static let dfuFinished = "DFU initialized"
    
    static let settingsPacketReceiptTitle = "Packets receipt notification"
    static let settingsPacketReceiptValue = "Enables or disables the Packet Receipt Notification (PRN) procedure. \n\nPRNs are used to synchronize the transmitter with the receiver and ensure data correctness. They are enabled by default on Android Lollipop and earlier."
    static let settingsSecureDfu = "Secure DFU option"
    static let settingsDisableResumeTitle = "Disable resume"
    static let settingsDisableResumeValue = "This options allows to disable the resume feature in Secure DFU."
    static let settingsLegacyDfu = "Legacy DFU"
    static let settingsForceScanningTitle = "Force scanning"
    static let settingsForceScanningValue = "Forces scanning for DFU bootloader. By default, the DFU bootloader advertises directly with the same MAC address.\n\nChanging this requires modifying the DFU bootloader or the Buttonless Service implementation on the device."
    static let settingsKeepBondTitle = "Keep bond"
    static let settingsKeepBondValue = "Sets whether the bond information should be preserved after flashing new application."
    static let settingsExternalMcuTitle = "External MCU DFU"
    static let settingsExternalMcuValue = "Enabling this option will prevent from jumping to the DFU Bootloader mode in case there is no DFU Version characteristic."
    static let settingsOther = "Other"
    static let settingsAboutTitle = "About DFU"
    static let settingsAboutValue = "DFU documentation on Nordic\'s Infocenter."
    static let settingsWelcome = "Show welcome screen"
    static let settingsTitle = "Settings"
    static let settingsProvideNumberOfPackets = "Please provide integer value:"
    
    static let rssi = "RSSI: %@"
}
