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

import Foundation

/**
 A type of DFU remote error.
 */
internal enum DFURemoteError : Int {
    /// A remote error retuned from Legacy DFU bootloader.
    case legacy                      = 0
    /// A remote error retuned from Secure DFU bootloader.
    case secure                      = 10
    /// An extended error retuned from Secure DFU bootloader.
    case secureExtended              = 20
    /// A remote error retuned from Buttonless service.
    case buttonless                  = 90
    /// A remote error retuned from the experimental Buttonless service from SDK 12.
    case experimentalButtonless      = 9000
    
    /// Returns a representative ``DFUError``
    ///
    /// The only available codes that this method is called with are
    /// hardcoded in the library (ButtonlessDFU, DFUControlPoint,
    /// SecureDFUControlPoint). But, we have seen crashes so,
    /// we are returning ``DFUError/unsupportedResponse``
    /// if a code is not found.
    func with(code: UInt8) -> DFUError {
        return DFUError(rawValue: Int(code) + rawValue) ?? .unsupportedResponse
    }
}

/**
 A DFU error enumeration.
 */
@objc public enum DFUError : Int {
    // Legacy DFU errors.
    
    /// Legacy DFU bootloader reported success.
    case remoteLegacyDFUSuccess               = 1
    /// Legacy DFU bootloader is in invalid state.
    case remoteLegacyDFUInvalidState          = 2
    /// Requested operation is not supported.
    case remoteLegacyDFUNotSupported          = 3
    /// The firmware size exceeds limit.
    case remoteLegacyDFUDataExceedsLimit      = 4
    /// A CRC (checksum) error.
    case remoteLegacyDFUCrcError              = 5
    /// Operation failed for an unknown reason.
    case remoteLegacyDFUOperationFailed       = 6
    
    // Secure DFU errors (received value + 10 as they overlap legacy errors).
    
    /// Secure DFU bootloader reported success.
    case remoteSecureDFUSuccess               = 11 // 10 + 1
    /// Requested Op Code is not supported.
    case remoteSecureDFUOpCodeNotSupported    = 12 // 10 + 2
    /// Invalid parameter.
    case remoteSecureDFUInvalidParameter      = 13 // 10 + 3
    /// Secure DFU bootloader cannot complete due to insufficient resources.
    case remoteSecureDFUInsufficientResources = 14 // 10 + 4
    /// The object is invalid.
    case remoteSecureDFUInvalidObject         = 15 // 10 + 5
    /// Firmware signature is invalid.
    case remoteSecureDFUSignatureMismatch     = 16 // 10 + 6
    /// Requested type is not supported.
    case remoteSecureDFUUnsupportedType       = 17 // 10 + 7
    /// Requested operation is not permitted.
    case remoteSecureDFUOperationNotPermitted = 18 // 10 + 8
    /// Operation failed for an unknown reason.
    case remoteSecureDFUOperationFailed       = 20 // 10 + 10
    /// The Secure DFU bootloader reported a detailed error.
    ///
    /// - note: This error is not reported to the app. Instead, the library will
    ///         return one of the `remoteExtendedError...` errors.
    case remoteSecureDFUExtendedError         = 21 // 10 + 11
    
    // Detailed extended errors.
    
    /// The format of the command was incorrect.
    ///
    /// This error code is not used in the current implementation, because
    /// ``remoteSecureDFUOpCodeNotSupported`` and
    /// ``remoteSecureDFUInvalidParameter`` cover all possible format errors.
    case remoteExtendedErrorWrongCommandFormat   = 22 // 20 + 0x02
    /// The command was successfully parsed, but it is not supported or unknown.
    case remoteExtendedErrorUnknownCommand       = 23 // 20 + 0x03
    /// The init command is invalid.
    ///
    /// The init packet either has an invalid update type or it is missing required fields for
    /// the update type (for example, the init packet for a SoftDevice update is missing the
    /// SoftDevice size field).
    case remoteExtendedErrorInitCommandInvalid   = 24 // 20 + 0x04
    /// The firmware version is too low.
    ///
    /// For an application or SoftDevice, the version must be greater than or equal to the
    /// current version. For a bootloader, it must be greater than the current version.
    /// This requirement prevents downgrade attacks.
    case remoteExtendedErrorFwVersionFailure     = 25 // 20 + 0x05
    /// The hardware version of the device does not match the required hardware version
    /// for the update.
    ///
    /// This error may be thrown if a user tries to update a wrong device.
    case remoteExtendedErrorHwVersionFailure     = 26 // 20 + 0x06
    /// The array of supported SoftDevices for the update does not contain the FWID
    /// of the current SoftDevice or the first FWID is '0' on a bootloader which requires
    /// the SoftDevice to be present.
    case remoteExtendedErrorSdVersionFailure     = 27 // 20 + 0x07
    /// The init packet does not contain a signature.
    ///
    /// This error code is not used in the current implementation, because init packets
    /// without a signature are regarded as invalid.
    case remoteExtendedErrorSignatureMissing     = 28 // 20 + 0x08
    /// The hash type that is specified by the init packet is not supported by the DFU bootloader.
    case remoteExtendedErrorWrongHashType        = 29 // 20 + 0x09
    /// The hash of the firmware image cannot be calculated.
    case remoteExtendedErrorHashFailed           = 30 // 20 + 0x0A
    /// The type of the signature is unknown or not supported by the DFU bootloader.
    case remoteExtendedErrorWrongSignatureType   = 31 // 20 + 0x0B
    /// The hash of the received firmware image does not match the hash in the init packet.
    case remoteExtendedErrorVerificationFailed   = 32 // 20 + 0x0C
    /// The available space on the device is insufficient to hold the firmware.
    case remoteExtendedErrorInsufficientSpace    = 33 // 20 + 0x0D
    
    // Experimental Buttonless DFU errors (received value + 9000 as they
    // overlap legacy and secure DFU errors).
    
    /// Experimental Buttonless DFU service reported success.
    case remoteExperimentalButtonlessDFUSuccess               = 9001 // 9000 + 1
    /// The Op Code is not supported.
    case remoteExperimentalButtonlessDFUOpCodeNotSupported    = 9002 // 9000 + 2
    /// Jumping to bootloader mode failed.
    case remoteExperimentalButtonlessDFUOperationFailed       = 9004 // 9000 + 4
    
    // Buttonless DFU errors (received value + 90 as they overlap legacy
    // and secure DFU errors).
    
    /// Buttonless DFU service reported success.
    case remoteButtonlessDFUSuccess                     = 91 // 90 + 1
    /// The Op Code is not supported.
    case remoteButtonlessDFUOpCodeNotSupported          = 92 // 90 + 2
    /// Jumping to bootloader mode failed.
    case remoteButtonlessDFUOperationFailed             = 94 // 90 + 4
    /// The requested advertising name is invalid.
    ///
    /// Maximum length for the name is 20 bytes..
    case remoteButtonlessDFUInvalidAdvertisementName    = 95 // 90 + 5
    /// The service is busy.
    case remoteButtonlessDFUBusy                        = 96 // 90 + 6
    /// The Buttonless service requires the device to be bonded.
    case remoteButtonlessDFUNotBonded                   = 97 // 90 + 7
    
    /// Providing the DFUFirmware is required.
    case fileNotSpecified                     = 101
    /// Given firmware file is not supported.
    case fileInvalid                          = 102
    /// Since SDK 7.0.0 the DFU Bootloader requires the extended Init Packet.
    ///
    /// For more details, see [Infocenter](http://infocenter.nordicsemi.com/topic/com.nordic.infocenter.sdk5.v11.0.0/bledfu_example_init.html?cp=4_0_0_4_2_1_1_3).
    case extendedInitPacketRequired           = 103
    /// The Init packet is required and has not been found.
    ///
    /// Before SDK 7.0.0 the init packet could have contained only 2-byte CRC
    /// value, and was optional. Providing an extended one instead would cause
    /// CRC error during validation (the bootloader assumes that the 2 first
    /// bytes of the init packet are the firmware CRC).
    case initPacketRequired                   = 104
    
    /// The DFU service failed to connect to the target peripheral.
    case failedToConnect                      = 201
    /// The DFU target disconnected unexpectedly.
    case deviceDisconnected                   = 202
    /// Bluetooth adapter is disabled.
    case bluetoothDisabled                    = 203
    /// Service discovery has failed.
    case serviceDiscoveryFailed               = 301
    /// The selected device does not support Legacy or Secure DFU
    /// or any of Buttonless services.
    case deviceNotSupported                   = 302
    /// Reading DFU version characteristic has failed.
    case readingVersionFailed                 = 303
    /// Enabling Control Point notifications failed.
    case enablingControlPointFailed           = 304
    /// Writing a characteristic has failed.
    case writingCharacteristicFailed          = 305
    /// There was an error reported for a notification.
    case receivingNotificationFailed          = 306
    /// Received response is not supported.
    case unsupportedResponse                  = 307
    /// Error raised during upload when the number of bytes sent is not equal to
    /// number of bytes confirmed in Packet Receipt Notification.
    case bytesLost                            = 308
    /// Error raised when the CRC reported by the remote device does not match.
    /// Service has done 3 attempts to send the data.
    case crcError                             = 309
    /// The service went into an invalid state. The service will try to close
    /// without crashing. Recovery to a know state is not possible.
    case invalidInternalState                 = 500
    
    /// Returns whether the error has been returned by the remote device or
    /// occurred locally.
    var isRemote: Bool {
        return rawValue < 100 || rawValue > 9000
    }
}

/**
 The state of the DFU Service.
 
 The new state is returned using ``DFUServiceDelegate/dfuStateDidChange(to:)``
 set as ``DFUServiceInitiator/delegate``.
 
 When the DFU operation ends with an error, the error is reported using
 ``DFUServiceDelegate/dfuError(_:didOccurWithMessage:)``.
 In that case the state change is not reported.
 */
@objc public enum DFUState : Int {
    /// Service is connecting to the DFU target.
    case connecting
    /// DFU Service is initializing DFU operation.
    case starting
    /// DFU Service is switching the device to DFU mode.
    case enablingDfuMode
    /// DFU Service is uploading the firmware.
    case uploading
    /// The DFU target is validating the firmware. This state occurs only in Legacy DFU.
    case validating
    /// The iDevice is disconnecting or waiting for disconnection.
    case disconnecting
    /// DFU operation is completed and successful.
    case completed
    /// DFU operation was aborted.
    case aborted
}

extension DFUState : CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .connecting:      return "Connecting"
        case .starting:        return "Starting"
        case .enablingDfuMode: return "Enabling DFU Mode"
        case .uploading:       return "Uploading"
        case .validating:      return "Validating"  // This state occurs only in Legacy DFU.
        case .disconnecting:   return "Disconnecting"
        case .completed:       return "Completed"
        case .aborted:         return "Aborted"
        }
    }
    
}

/**
 The progress delegates may be used to notify user about progress updates.
 
 The only method of the delegate is only called when the service is in the
 Uploading state.
 */
@objc public protocol DFUProgressDelegate {
    
    /**
     Callback called in the ``DFUState/uploading`` state during firmware upload.
     
     Gives detailed information about the progress and speed of transmission.
     This method is always called at least two times (for 0% and 100%) if upload has
     started and did not fail and is not called multiple times for the same number of
     percentage.
     
     This method is called in the thread set as `progressQueue` in
     ``DFUServiceInitiator/init(queue:delegateQueue:progressQueue:loggerQueue:centralManagerOptions:)``.
     
     - parameter part: Number of part that is currently being transmitted. Parts
                       start from 1 and may have value either 1 or 2. Part 2 is
                       used only when there were Soft Device and/or Bootloader AND
                       an Application in the Distribution Packet and the DFU target
                       does not support sending all files in a single connection.
                       First the SD and/or BL will be sent, then the service will
                       disconnect, reconnect again to the (new) bootloader and send
                       the Application.
     - parameter totalParts: Total number of parts that are to be send (this is always
                             equal to 1 or 2).
     - parameter progress: The current progress of uploading the current part in
                           percentage (values 0-100).
                           Each value will be called at most once - in case of a large
                           file a value e.g. 3% will be called only once, despite that
                           it will take more than one packet to reach 4%. In case of
                           a small firmware file some values may be omitted.
                           For example, if firmware file would be only 20 bytes you
                           would get a callback 0% (called always) and then 100% when done.
     - parameter currentSpeedBytesPerSecond: The current speed in bytes per second.
     - parameter avgSpeedBytesPerSecond: The average speed in bytes per second.
     */
    @objc func dfuProgressDidChange(for part: Int, outOf totalParts: Int,
                                    to progress: Int,
                                    currentSpeedBytesPerSecond: Double,
                                    avgSpeedBytesPerSecond: Double)
}

/**
 The service delegate reports about state changes and errors.
 */
@objc public protocol DFUServiceDelegate {
    
    /**
     Callback called when state of the DFU Service has changed.
     
     This method is called in the `delegateQueue` specified in the
     ``DFUServiceInitiator/init(queue:delegateQueue:progressQueue:loggerQueue:centralManagerOptions:)``.
     
     - parameter state: The new state of the service.
     */
    @objc func dfuStateDidChange(to state: DFUState)
    
    /**
     Called after an error occurred. 
     
     The device will be disconnected and DFU operation has been cancelled.
     
     - note: When an error is received the DFU state will not change to ``DFUState/aborted``.
     
     This method is called in the `delegateQueue` specified in the
     ``DFUServiceInitiator/init(queue:delegateQueue:progressQueue:loggerQueue:centralManagerOptions:)``.
     
     - parameter error:   The error code.
     - parameter message: Error description.
     */
    @objc func dfuError(_ error: DFUError, didOccurWithMessage message: String)

}
