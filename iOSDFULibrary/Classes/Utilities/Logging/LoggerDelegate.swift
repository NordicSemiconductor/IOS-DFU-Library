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
 Log levels used by the ``LoggerDelegate``.
 
 Logger application may filter log entries based on their level.
 
 Levels allow to categorize message by importance.
 */
@objc public enum LogLevel : Int {
    /// Lowest priority. Usually names of called methods or callbacks received.
    case debug       = 0
    /// Low priority messages what the service is doing.
    case verbose     = 1
    /// Messages about completed tasks.
    case info        = 5
    /// Messages about application level events, in this case DFU message
    /// in human-readable form.
    case application = 10
    /// Important messages.
    case warning     = 15
    /// Highest priority messages with errors.
    case error       = 20
    
    public func name() -> String {
        switch self {
        case .debug:       return "D"
        case .verbose:     return "V"
        case .info:        return "I"
        case .application: return "A"
        case .warning:     return "W"
        case .error:       return "E"
        }
    }
}

/**
 The Logger delegate.
 */
@objc public protocol LoggerDelegate: AnyObject {
    
    /**
     This method is called whenever a new log entry is to be saved.
     
     The logger implementation should save this or present it to the user.
     
     It is NOT safe to update any UI from this method as multiple threads may log.
     
     - parameter level:   The log level.
     - parameter message: The message.
     */
    @objc func logWith(_ level: LogLevel, message: String)
}
