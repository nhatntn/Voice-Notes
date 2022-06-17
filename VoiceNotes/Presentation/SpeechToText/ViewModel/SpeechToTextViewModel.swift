//
//  SpeechToTextViewModel.swift
//  VoiceNotes
//
//  Created by nhatnt on 28/05/2022.
//

import Foundation
import googleapis

protocol SpeechToTextViewModelInput {
    func startVoiceNoting()
    func stopVoiceNoting()
    func isVoiceNoting(with data: Data)
    func didSaveVoiceNote(content: String)
    func didClearVoiceNote()
}

protocol SpeechToTextViewModelOutput {
    var data: Observable<String> { get }
    var error: Observable<String> { get }
}

protocol SpeechToTextViewModel: SpeechToTextViewModelInput, SpeechToTextViewModelOutput {}

class DefaultSpeechToTextViewModel: SpeechToTextViewModel {
    private let spechToTextRepository: SpeechToTextRepository
    private var audioData: NSMutableData?
    private let createdDate = Date()
    
    init(speechRepository: SpeechToTextRepository) {
        self.spechToTextRepository = speechRepository
    }
    
    // MARK: - OUTPUT
    let data: Observable<String> = Observable("")
    let error: Observable<String> = Observable("")
    let loading: Observable<Bool> = Observable(false)
    
    // MARK: - INPUT. View event methods
    func startVoiceNoting() {
        self.audioData = self.audioData ?? NSMutableData()
    }
    
    func stopVoiceNoting() {
        self.spechToTextRepository.stopStreaming()
    }
    
    func didSaveVoiceNote(content: String) {
        self.data.value = content
        
        if content.isEmpty {
            self.error.value = "Your voice note is empty"
            return
        }
        
        self.spechToTextRepository.save(with: content, createdAt: createdDate) { (result) in
            switch result {
            case .success:
                self.saveSuccessfully()
            case .failure(let error):
                self.handle(error: error)
            }
            self.loading.value = false
        }
    }
    
    func didClearVoiceNote() {
        self.data.value = ""
    }
    
    func isVoiceNoting(with data: Data) {
        guard let audioData = audioData else {
            return
        }
        
        audioData.append(data)
        
        // We recommend sending samples in 100ms chunks
        // /* bytes/chunk */ = 0.1 (seconds/chunk) * (samples/second) * (bytes/sample)
        let chunkSize : Int = Int(0.1 * Double(16000) * 2 );
        
        if (audioData.length > chunkSize) {
            spechToTextRepository.streamAudioData(audioData, completion: { [weak self] (response, error) in
                guard let self = self else {
                    return
                }
                
                if error != nil {
                    self.stopVoiceNoting()
                } else if let response = response {
                    let oldValue = self.data.value
                    self.data.value = oldValue + self.choseTheBestText(with: response)
                }
            })
            self.audioData = NSMutableData()
        }
    }
    
    fileprivate func choseTheBestText(with response: StreamingRecognizeResponse) -> String {
        var bestTranscript = ""
        var maxConfidence: Float = 0.0
        for result in response.resultsArray! {
            if let result = result as? StreamingRecognitionResult {
                for alternative in result.alternativesArray {
                    if let alternative = alternative as? SpeechRecognitionAlternative,
                       alternative.confidence > maxConfidence {
                        print("------\(alternative.confidence)----\(alternative.transcript ?? "")")
                        maxConfidence = alternative.confidence
                        bestTranscript = alternative.transcript
                    }
                }
            }
        }
        return bestTranscript
    }
    
    private func saveSuccessfully() {
        self.error.value = "Save voice note successfully"
    }
    
    private func handle(error: Error) {
        self.error.value = error.localizedDescription
    }
    
}

