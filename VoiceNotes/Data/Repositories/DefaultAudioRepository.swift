//
//  DefaultAudioRepository.swift
//  VoiceNotes
//
//  Created by nhatnt on 28/05/2022.
//

import Foundation

class DefaultAudioRepository: AudioRepository {
    struct Dependencies {
        let audioService: AudioService
    }
    
    private let dependencies: Dependencies
    weak var delegate: AudioServiceDelegate?
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func start() {
        _ = self.dependencies.audioService.prepare(specifiedSampleRate: 16000)
        _ = self.dependencies.audioService.start()
        self.dependencies.audioService.delegate = self.delegate
    }
    
    func stop() {
        _ = self.dependencies.audioService.stop()
    }
}
