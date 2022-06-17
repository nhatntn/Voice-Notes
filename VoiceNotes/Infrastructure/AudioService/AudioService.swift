//
//  AudioService.swift
//  VoiceNotes
//
//  Created by nhatnt on 28/05/2022.
//

import Foundation
import AVFoundation
import AudioUnit

protocol AudioServiceDelegate: class {
    func processSampleData(_ data:Data) -> Void
}

class AudioService {
    static var sharedInstance = AudioService()
    private let bus1 : AudioUnitElement = 1
    private var oneFlag : UInt32 = 1
    private init() {}
    
    var delegate : AudioServiceDelegate?
    var audioUnit: AudioComponentInstance?
    
    private func creatAudioUnit() -> AudioComponentInstance? {
        var unit: AudioComponentInstance? = nil
        
        // Describe the RemoteIO unit
        var audioComponentDescription = AudioComponentDescription()
        audioComponentDescription.componentType = kAudioUnitType_Output;
        audioComponentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
        audioComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
        audioComponentDescription.componentFlags = 0;
        audioComponentDescription.componentFlagsMask = 0;
        
        // Get the RemoteIO unit
        guard let remoteIOComponent = AudioComponentFindNext(nil, &audioComponentDescription) else {
            return nil
        }
        
        let status = AudioComponentInstanceNew(remoteIOComponent, &unit)
        if status != noErr {
            return nil
        }
        
        return unit
    }
    
    func prepare(specifiedSampleRate: Int) -> OSStatus {
        var status = noErr
        
        if self.audioUnit != nil {
            return 1
        }
        
        self.audioUnit = creatAudioUnit()
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSession.Category.record)
            try session.setPreferredIOBufferDuration(10)
        } catch {
            return -1
        }
        
        var sampleRate = session.sampleRate
        print("hardware sample rate = \(sampleRate), using specified rate = \(specifiedSampleRate)")
        sampleRate = Double(specifiedSampleRate)
        
        guard let audioUnit = self.audioUnit else {
            return -1
        }
        
        // Configure the I/O unit for input
        status = AudioUnitSetProperty(audioUnit,
                                      kAudioOutputUnitProperty_EnableIO,
                                      kAudioUnitScope_Input,
                                      bus1,
                                      &oneFlag,
                                      UInt32(MemoryLayout<UInt32>.size));
        if (status != noErr) {
            return status
        }
        
        var asbd = AudioStreamBasicDescription()
        asbd.mSampleRate = sampleRate
        asbd.mFormatID = kAudioFormatLinearPCM
        asbd.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked
        asbd.mBytesPerPacket = 2
        asbd.mFramesPerPacket = 1
        asbd.mBytesPerFrame = 2
        asbd.mChannelsPerFrame = 1
        asbd.mBitsPerChannel = 16
        status = AudioUnitSetProperty(audioUnit,
                                      kAudioUnitProperty_StreamFormat,
                                      kAudioUnitScope_Output,
                                      bus1,
                                      &asbd,
                                      UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
        if (status != noErr) {
            return status
        }
        
        // Set the recording callback
        var callbackStruct = AURenderCallbackStruct()
        callbackStruct.inputProc = recordingCallback
        callbackStruct.inputProcRefCon = nil
        status = AudioUnitSetProperty(audioUnit,
                                      kAudioOutputUnitProperty_SetInputCallback,
                                      kAudioUnitScope_Global,
                                      bus1,
                                      &callbackStruct,
                                      UInt32(MemoryLayout<AURenderCallbackStruct>.size));
        if (status != noErr) {
            return status
        }
        
        // Initialize the RemoteIO unit
        return AudioUnitInitialize(audioUnit)
    }
    
    func start() -> OSStatus {
        guard let audioUnit = self.audioUnit else {
            return -1
        }
        return AudioOutputUnitStart(audioUnit)
    }
    
    func stop() -> OSStatus {
        guard let audioUnit = self.audioUnit else {
            return -1
        }
        return AudioOutputUnitStop(audioUnit)
    }
}

func recordingCallback(
    inRefCon:UnsafeMutableRawPointer,
    ioActionFlags:UnsafeMutablePointer<AudioUnitRenderActionFlags>,
    inTimeStamp:UnsafePointer<AudioTimeStamp>,
    inBusNumber:UInt32,
    inNumberFrames:UInt32,
    ioData:UnsafeMutablePointer<AudioBufferList>?) -> OSStatus {
    
    var status = noErr
    var bufferList = AudioBufferList(
        mNumberBuffers: 1,
        mBuffers: AudioBuffer(
            mNumberChannels: UInt32(2),
            mDataByteSize: inNumberFrames * 2,
            mData: nil))
    
    guard let audioUnit = AudioService.sharedInstance.audioUnit else {
        return -1
    }
    
    // get the recorded samples
    status = AudioUnitRender(audioUnit,
                             ioActionFlags,
                             inTimeStamp,
                             inBusNumber,
                             inNumberFrames,
                             &bufferList)
    if (status != noErr) {
        return status;
    }
    
    let data = Data(bytes:  bufferList.mBuffers.mData!,
                    count: Int(bufferList.mBuffers.mDataByteSize))
    DispatchQueue.main.async {
        _ = AudioService.sharedInstance.delegate?.processSampleData(data)
    }
    
    return noErr
}
