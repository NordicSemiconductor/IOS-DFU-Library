/*
* Copyright (c) 2016, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
* documentation and/or other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
* software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
* HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
* LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
* ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
* USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

internal class SecureDFUExecutor : SecureDFUPeripheralDelegate {
    /// The DFU Service Initiator instance that was used to start the service.
    private let initiator:SecureDFUServiceInitiator
    
    /// The service delegate will be informed about status changes and errors.
    private var delegate:SecureDFUServiceDelegate? {
        // The delegate may change during DFU operation (setting a new one in the initiator). Let's allways use the current one.
        return initiator.delegate
    }
    
    /// The progress delegate will be informed about current upload progress.
    private var progressDelegate:SecureDFUProgressDelegate? {
        // The delegate may change during DFU operation (setting a new one in the initiator). Let's allways use the current one.
        return initiator.progressDelegate
    }
    
    /// The DFU Target peripheral. The peripheral keeps the cyclic reference to the DFUExecutor preventing both from being disposed before DFU ends.
    private var peripheral:SecureDFUPeripheral

    /// The firmware to be sent over-the-air
    private var firmware        : DFUFirmware
    private var firmwareRanges   : [NSRange]?
    private var currentRangeIdx : Int?
    private var error           : (error:SecureDFUError, message:String)?

    private var maxLen          : UInt32?
    private var offset          : UInt32?
    private var crc             : UInt32?

    private var initPacketSent  : Bool = false
    private var firmwareSent    : Bool = false
    private var sendingFirmware : Bool = false
    private var isResuming      : Bool = false

    // MARK: - Initialization
    init(_ initiator:SecureDFUServiceInitiator) {
        self.initiator = initiator
        self.firmware = initiator.file!
        self.peripheral = SecureDFUPeripheral(initiator)
    }

    // MARK: - DFU Controller methods
    func start() {
        self.error = nil
        dispatch_async(dispatch_get_main_queue(), {
            self.delegate?.didStateChangedTo(SecureDFUState.Connecting)
        })
        peripheral.delegate = self
        peripheral.connect()
    }

    func pause() -> Bool {
        return peripheral.pause()
    }

    func resume() -> Bool {
        return peripheral.resume()
    }

    func abort() {
        peripheral.abort()
    }

    // MARK: - Secure DFU Peripheral Delegate methods
    func onDeviceReady() {
        //All services/characteristics have been discovered, Start by reading object info
        //to get the maximum write size.
        dispatch_async(dispatch_get_main_queue(), {
            self.delegate?.didStateChangedTo(SecureDFUState.Starting)
        })
        peripheral.enableControlPoint()
    }

    func resetFirmwareRanges() {
        self.currentRangeIdx = 0
        self.firmwareRanges = nil
    }

    func calculateFirmwareRanges() -> [NSRange]{
        var chunkCount = ceil(Double(self.firmware.data.length) / Double(self.maxLen!))
        var totalLength = self.firmware.data.length
        var currentMaxLen = Int(maxLen!)
        var ranges = [NSRange]()
        
        var partIdx = 0
        while(totalLength > 0) {
            var chunkRange : NSRange?
            if totalLength > currentMaxLen {
                totalLength -= currentMaxLen
                chunkRange = NSRange(location:partIdx*currentMaxLen, length:currentMaxLen)
            } else {
                chunkRange = NSRange(location:partIdx*currentMaxLen, length:totalLength)
                totalLength = 0
            }
            ranges.append(chunkRange!)
            partIdx++
        }
        
        return ranges
    }

    func onControlPointEnabled() {
        peripheral.ReadObjectInfoCommand()
    }
    
    func verifyDataCRC(fordata data : NSData, andPacketOffset anOffset : UInt32, andperipheralCRC aCRC : UInt32) -> Bool {
        //get data form 0 up to the offset the peripheral has reproted
        let offsetData : NSData = (data.subdataWithRange(NSRange(location: 0, length: Int(anOffset))))
        var calculatedCRC = CRC32(data: offsetData).crc
        
        //This returns true if the current data packet's CRC matches the current firmware's packet CRC
        return calculatedCRC == aCRC
    }
    
    func resumeSendInitpacket(atOffset anOffset : UInt32) {
        
        let initPacketLength = UInt32((self.firmware.initPacket?.length)!)
        
        //Log how much of the packet has been already sent
        let sentPercentage = Int(anOffset / initPacketLength * 100)
        print(String(format:"%.0f%% of init packet sent, resuming!", sentPercentage))
        
        //get remaining data to send
        let data = self.firmware.initPacket?.subdataWithRange(NSRange(location: Int(anOffset), length: Int(initPacketLength - anOffset)))
        
        //Send data
        self.peripheral.sendInitpacket(data!)
    }
    
    func objectInfoReadCommandCompleted(var maxLen : UInt32, offset : UInt32, crc :UInt32 ) {
        self.maxLen = maxLen
        self.offset = offset
        self.crc = crc
        if self.offset > 0 && self.crc > 0 {
            isResuming = true
            var match = self.verifyDataCRC(fordata: self.firmware.initPacket!, andPacketOffset: offset, andperipheralCRC: crc)
            if match == true {
                //Resume Init
                print("Init packet CRC matches")
                if self.offset < UInt32((self.firmware.initPacket?.length)!) {
                    print("Init packet was incomplete, resuming..")
                    self.resumeSendInitpacket(atOffset: offset)
                }else{
                    self.initPacketSent = true
                    self.firmwareSent   = false
                    print("Init packet was complete, verify data object")
                    peripheral.ReadObjectInfoData()
                }
            }else{
                //Start new flash
                print("firmare init packet doesn't match, will overwrite and start again")
            }
        }else{
            peripheral.createObjectCommand(UInt32((self.firmware.initPacket?.length)!))
        }
    }
    
    func objectInfoReadDataCompleted(maxLen : UInt32, offset : UInt32, crc :UInt32 ) {

        self.maxLen = maxLen
        self.offset = offset
        self.crc    = crc

        //This is the intial state, if ranges aren't set, assume this is the first
        //or the only stage in the DFU process
        if self.currentRangeIdx == nil {
            //Split firmware into smaller chunks of maxlen, if firmware is bigger than maxlen
            self.firmwareRanges   = self.calculateFirmwareRanges()
            self.currentRangeIdx = 0
        }

        if isResuming == true {
            let match = self.verifyDataCRC(fordata: self.firmware.data, andPacketOffset: self.offset!, andperipheralCRC: self.crc!)
            
            if match == true {
                var completedPercent = Int(Double(self.offset!) / Double(self.firmware.data.length) * 100)
                print(String(format:"Data object info CRC matches, resuming from %d%%..",completedPercent))
                peripheral.setPRNValue(2)
            } else {
                print("Data object does not match\nStart from scratch?")
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.delegate?.didStateChangedTo(SecureDFUState.Uploading)
            })
            
            //Start sending firmware in chunks
            sendingFirmware = true
            self.createObjectDataForCurrentChunk()
       }
    }

    func createObjectDataForCurrentChunk() {
        var currentRange = self.firmwareRanges![self.currentRangeIdx!]
        
        print("current firmware chunk length = \(currentRange.length)")
        peripheral.createObjectData(withLength: UInt32(currentRange.length))
    }
    
    func firmwareSendComplete() {
        dispatch_async(dispatch_get_main_queue(), {
            self.delegate?.didStateChangedTo(SecureDFUState.Validating)
        })
        self.firmwareSent = true
        peripheral.sendCalculateChecksumCommand()
    }

    func firmwareChunkSendcomplete() {
        print("Chunk sent !, calc CRC,verify, execute!")
        peripheral.sendCalculateChecksumCommand()
    }

    func objectCreateDataCompleted(data: NSData?) {
        print("Object created, sending data for chunk \(self.currentRangeIdx!)")
        sendCurrentChunk()
    }

    func sendCurrentChunk(){
        var chunkData = self.firmware.data.subdataWithRange(firmwareRanges![currentRangeIdx!])
        peripheral.sendFirmwareChunk(self.firmware, andChunkRange: firmwareRanges![currentRangeIdx!], andPacketCount: 2, andProgressDelegate: self.progressDelegate!)
    }

    func objectCreateCommandCompleted(data: NSData?) {
        peripheral.setPRNValue(0) //disable for first time while we write Init file
    }
    
    func setPRNValueCompleted() {
        if initPacketSent == false {
            dispatch_async(dispatch_get_main_queue(), {
                self.delegate?.didStateChangedTo(SecureDFUState.EnablingDfuMode)
            })
            peripheral.sendInitpacket(self.firmware.initPacket!)
        }else if firmwareSent == false{
            if isResuming == false {
                peripheral.ReadObjectInfoData()
            } else {
                //TODO: resume code here
            }
        }
    }
    
    func initPacketSendCompleted() {
        self.initPacketSent = true
        peripheral.sendCalculateChecksumCommand()
    }

    func calculateChecksumCompleted(offset: UInt32, CRC: UInt32) {
        self.crc    = CRC
        self.offset = offset
        
        //Firmware is still being sent!
        if sendingFirmware == true {
            //verify CRC
            var chunkData = self.firmware.data.subdataWithRange(NSRange(location: 0, length:Int(self.offset!)))
            var crc = CRC32.init(data: chunkData).crc
            if self.crc == crc {
                print("Chunk CRC matches, exetuce!")
                peripheral.sendExecuteCommand()
                return
            }else{
                print("Chunk CRC mismatch!")
            }
        }

        if initPacketSent == true && firmwareSent == false {
            if offset == UInt32((firmware.initPacket?.length)!) {
                var calculatedCRC = CRC32(data: self.firmware.initPacket!).crc
                if calculatedCRC == self.crc {
                    print("CRC match, send execute command")
                    peripheral.sendExecuteCommand()
                }else{
                    print("CRC for init packet does not match, local = \(calculatedCRC), reported = \(self.crc!)\nStart from scratch?")
                }
            } else {
                print("Offset doesn't match packet size!\nstart from scratch?")
            }
        }
//        else  if firmwareSent == true {
//            if isResuming == true {
//                print("Offset: \(offset), actualLength: \(firmware.data.length)")
//                peripheral.sendExecuteCommand()
//            }else{
//                if offset == UInt32(firmware.data.length) {
//                    print("Validated firmware, executing")
//                    peripheral.sendExecuteCommand()
//                }else{
//                    print("Firmware size mismatch.")
//                }
//            }
//        }
    }

    func executeCommandCompleted() {
        if sendingFirmware && !firmwareSent {
            if(currentRangeIdx! < (firmwareRanges?.count)! - 1) {
                currentRangeIdx!++
                createObjectDataForCurrentChunk()
                return
            }else{
                sendingFirmware = false
                firmwareSent    = true
                //Execute last Object!
                peripheral.sendExecuteCommand()
                return
            }
        }
        
        if initPacketSent == true && firmwareSent == false {
            print("Setting PRN to 12")
            peripheral.setPRNValue(2) //Enable PRN at 12 packets
        } else {
            self.firmwareSent    = false
            self.sendingFirmware = false
            self.initPacketSent  = false

            //Reset ranges
            if self.firmware.hasNextPart() {
                //Prepare next part for sending
                self.resetFirmwareRanges()
                self.firmware.switchToNextPart()
                //Get new ranges for new part
                self.firmwareRanges = self.calculateFirmwareRanges()
                peripheral.disconnect()
                peripheral.switchToNewPeripheralAndConnect(initiator.peripheralSelector)
            } else {
                delegate?.didStateChangedTo(.Completed)
                peripheral.disconnect()
            }
        }
    }

    func didDeviceFailToConnect() {
        print("Failed to connect")
    }
    
    func peripheralDisconnected() {
        print("Disconnected!")
    }
    
    func peripheralDisconnected(withError anError : NSError) {
        print("Disconnected with error!")
    }
    
    func onErrorOccured(withError anError:SecureDFUError, andMessage aMessage:String) {
        print("Error occured: \(anError), \(aMessage)")
    }
}
