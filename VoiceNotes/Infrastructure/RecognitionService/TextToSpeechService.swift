//
//  TextToSpeechService.swift
//  VoiceNotes
//
//  Created by nhatnt on 29/05/2022.
//

import Foundation
import googleapis
import AVFoundation

class TextToSpeechService {
    private var client : TextToSpeech!
    private var writer : GRXBufferedPipe!
    private var call : GRPCProtoCall!
    
    var config: RecognitionConfigurable
    
    init(config: RecognitionConfigurable) {
        self.config = config
    }
    
    func textToSpeech(text:String, completionHandler: @escaping (_ audioData: Data) -> Void) {
        client = TextToSpeech(host: config.baseURL)
        writer = GRXBufferedPipe()
        
        let synthesisInput = SynthesisInput()
        synthesisInput.text = text
        
        let voiceSelectionParams = VoiceSelectionParams()
        voiceSelectionParams.languageCode = "en-US"
        voiceSelectionParams.ssmlGender = SsmlVoiceGender.neutral
        
        let audioConfig = AudioConfig()
        audioConfig.audioEncoding = AudioEncoding.mp3
        
        let speechRequest = SynthesizeSpeechRequest()
        speechRequest.audioConfig = audioConfig
        speechRequest.input = synthesisInput
        speechRequest.voice = voiceSelectionParams
        
        call = client.rpcToSynthesizeSpeech(with: speechRequest, handler: { (synthesizeSpeechResponse, error) in
            if error != nil {
                print(error?.localizedDescription ?? "No error description available")
                return
            }
            guard let response = synthesizeSpeechResponse else {
                print("No response received")
                return
            }
            guard let audioData =  response.audioContent else {
                print("no audio data received")
                return
            }
            completionHandler(audioData)
        })
        call.requestHeaders.setObject(NSString(string: config.apiKey),
                                      forKey:NSString(string:"X-Goog-Api-Key"))
        
        // if the API key has a bundle ID restriction, specify the bundle ID like this
        
        call.requestHeaders.setObject(NSString(string:Bundle.main.bundleIdentifier!), forKey:NSString(string:"X-Ios-Bundle-Identifier"))
        print("HEADERS:\(String(describing: call.requestHeaders))")
        call.start()
    }
}
