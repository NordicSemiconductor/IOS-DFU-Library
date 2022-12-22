/*
* Copyright (c) 2022, Nordic Semiconductor
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

enum DfuStrings : String {
    case dfuTitle = "DFU"
    
    case welcomeTitle = "Welcome"
    case welcomeStart = "Start"
    case welcomeText = "The Device Firmware Update (DFU) app allows updating the firmware of Bluetooth LE devices over-the-air (OTA). It is compatible with nRF51 and nRF52 devices from Nordic Semiconductor running nRF5 SDK based applications with DFU bootloader enabled.\n\nFor more information about the DFU, click \"About DFU\" in Settings."
    case welcomeNote = "To update devices based on nRF\u{00a0}Connect\u{00a0}SDK\u{00a0}(NCS), use nRF\u{00a0}Connect\u{00a0}Device\u{00a0}Manager app instead."
    case numberOfPackets = "Number of Packets"
    case numberRequest = "Please provide number:"
    case cancel = "Cancel"
    case ok = "OK"
    case empty = ""
    case select = "Select"
    case file = "File"
    case device = "Device"
    case devices = "Devices"
    case filters = "Filters"
    case progress = "Progress"
    case abort = "Abort"
    case aborted = "Aborted"
    case upload = "Upload"
    case settings = "Settings"
    case scanner = "Scanner"
    case nearbyOnly = "Nearby"
    case withName = "Name"
    
    case firmwareUpload = "Firmware upload"
    case firmwareUploaded = "Firmware uploaded"
    case firmwareUploading = "Uploading firmware..."
    case firmwareUploadPart = "Uploading part %d of %d"
    case firmwareUploadSpeed = "%.1f kB/s"
    
    case resultCompleted = "Completed"
    case resultError = "Error: %@"
    
    case fileSelect = "Select a .zip file"
    case fileSize = "Size: %d bytes"
    
    case deviceSelect = "Select a device"
    case name = "Name: %@"
    
    case bootloaderIdle = "Bootloader enablement"
    case bootloaderInProgress = "Enabling bootloader..."
    case bootloaderFinished = "Bootloader enabled"
    
    case dfuIdle = "DFU initialization"
    case dfuInProgress = "Initializing DFU..."
    case dfuFinished = "DFU initialized"
    
    case settingsPacketReceiptTitle = "Packets receipt notification"
    case settingsPacketReceiptValue = "Enables or disables the Packet Receipt Notification (PRN) procedure.\n\nPRNs are used to synchronize the transmitter with the receiver and ensure data correctness."
    case settingsSecureDfu = "Secure DFU option"
    case settingsDisableResumeTitle = "Disable resume"
    case settingsDisableResumeValue = "This options allows to disable the resume feature in Secure DFU."
    case settingsLegacyDfu = "Legacy DFU"
    case settingsForceScanningTitle = "Force scanning"
    case settingsForceScanningValue = "Enables scanning for DFU bootloader in Legacy DFU. By default, a Legacy DFU bootloader advertises directly with the same MAC address.\n\nChanging this requires modifying the DFU bootloader or the Buttonless Service implementation on the device."
    case alternativeAdvertisingNameTitle = "Alternative Advertising Name"
    case alternativeAdvertisingNameValue = "When enabled, the app will send a unique ID to the connected device to be able to reconnect to it in bootloader mode. Otherwise, it will connect to first found device advertising DFU Service UUID."
    case alternativeAdvertisingNameDialogInfo = "Please set advertising name:"
    case settingsExternalMcuTitle = "External MCU DFU"
    case settingsExternalMcuValue = "Enabling this option will prevent from jumping to the DFU Bootloader mode in case there is no DFU Version characteristic."
    case settingsOther = "Other"
    case settingsAboutTitle = "About DFU"
    case settingsWelcome = "About the app"
    case settingsProvideNumberOfPackets = "Please, provide integer value:"
    
    case rssi = "RSSI: %@"
    
    case fileOpenError = "Can't open the file."
    case fileError = "Selected file is invalid."
    case fileDownloadError = "Downloading file failed."
    case noName = "No name"
    
    var text: String {
        rawValue
    }
}
