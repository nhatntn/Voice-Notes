//
//  DefaultTextToSpeechRepository.swift
//  VoiceNotes
//
//  Created by nhatnt on 29/05/2022.
//

import Foundation

class DefaultTextToSpeechRepository: TextToSpeechRepository {
    struct Dependencies {
        let textToSpeechService: TextToSpeechService
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func textToSpeech(text: String, completionHandler: @escaping (Data) -> Void) {
        self.dependencies.textToSpeechService.textToSpeech(text: text, completionHandler: completionHandler)
    }
    
}
