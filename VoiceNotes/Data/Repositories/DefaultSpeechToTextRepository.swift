//
//  DefaultSpeechToTextRepository.swift
//  VoiceNotes
//
//  Created by nhatnt on 28/05/2022.
//

import Foundation

class DefaultSpeechToTextRepository: SpeechToTextRepository {
    struct Dependencies {
        let speechToTextService: SpeechToTextService
        let voiceNotesStorage: VoiceNotesStorage
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func streamAudioData(_ audioData: NSData, completion: @escaping SpeechRecognitionCompletionHandler) {
        self.dependencies.speechToTextService.streamAudioData(audioData, completion: completion)
    }
    
    func stopStreaming() {
        self.dependencies.speechToTextService.stopStreaming()
    }
    
    func fetch(completion: @escaping (Result<[VoiceNote], Error>) -> Void) {
        return self.dependencies.voiceNotesStorage.fetchAll(completion: completion)
    }
    
    func save(with content: String, createdAt: Date, completion: @escaping (Result<VoiceNote, Error>) -> Void) {
        let dataFormatter = DateFormatter()
        dataFormatter.dateFormat = "MMM d, YY - HH:mm:ss"
        let name = dataFormatter.string(from: createdAt)
        let voiceNote = VoiceNote(name: name, content: content, createdAt: createdAt)
        return self.dependencies.voiceNotesStorage.save(with: voiceNote, completion: completion)
    }
    
}
