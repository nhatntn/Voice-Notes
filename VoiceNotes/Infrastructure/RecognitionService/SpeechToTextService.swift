//
//  SpeechToTextService.swift
//  VoiceNotes
//
//  Created by nhatnt on 27/05/2022.
//

import Foundation
import googleapis

typealias SpeechRecognitionCompletionHandler = (StreamingRecognizeResponse?, NSError?) -> (Void)

class SpeechToTextService {
    private var client : Speech!
    private var writer : GRXBufferedPipe!
    private var call : GRPCProtoCall!
    private var streaming = false
    var config: RecognitionConfigurable
    
    init(config: RecognitionConfigurable) {
        self.config = config
    }
    
    func streamAudioData(_ audioData: NSData, completion: @escaping SpeechRecognitionCompletionHandler) {
        if streaming {
            let streamingRecognizeRequest = StreamingRecognizeRequest()
            streamingRecognizeRequest.audioContent = audioData as Data
            writer.writeValue(streamingRecognizeRequest)
            return
        }
        
        // if we aren't already streaming, set up a gRPC connection
        client = Speech(host: self.config.baseURL)
        writer = GRXBufferedPipe()
        call = client.rpcToStreamingRecognize(withRequestsWriter: writer,
                                              eventHandler:
                                                { (done, response, error) in
                                                    completion(response, error as NSError?)
                                                })
        // authenticate using an API key obtained from the Google Cloud Console
        call.requestHeaders.setObject(NSString(string: config.apiKey),
                                      forKey:NSString(string:"X-Goog-Api-Key"))
        // if the API key has a bundle ID restriction, specify the bundle ID like this
        call.requestHeaders.setObject(NSString(string:Bundle.main.bundleIdentifier!),
                                      forKey:NSString(string:"X-Ios-Bundle-Identifier"))
        
        print("HEADERS: \(String(describing: call.requestHeaders))")
        
        call.start()
        streaming = true
        
        // send an initial request message to configure the service
        let recognitionConfig = RecognitionConfig()
        recognitionConfig.encoding =  .linear16
        recognitionConfig.sampleRateHertz = Int32(16000)
        recognitionConfig.languageCode = "en-US"
        recognitionConfig.maxAlternatives = 30
        recognitionConfig.enableWordTimeOffsets = true
        
        let streamingRecognitionConfig = StreamingRecognitionConfig()
        streamingRecognitionConfig.config = recognitionConfig
        streamingRecognitionConfig.singleUtterance = false
        streamingRecognitionConfig.interimResults = true
        
        let streamingRecognizeRequest = StreamingRecognizeRequest()
        streamingRecognizeRequest.streamingConfig = streamingRecognitionConfig
        
        writer.writeValue(streamingRecognizeRequest)
    }
    
    func stopStreaming() {
        if (!streaming) {
            return
        }
        writer.finishWithError(nil)
        streaming = false
    }
    
    func isStreaming() -> Bool {
        return streaming
    }
    
}
