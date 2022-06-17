//
//  Repository.swift
//  VoiceNotes
//
//  Created by nhatnt on 28/05/2022.
//

import Foundation
import googleapis

protocol SpeechToTextRepository {
    func streamAudioData(_ audioData: NSData, completion: @escaping SpeechRecognitionCompletionHandler)
    func stopStreaming()
    func fetch(completion: @escaping (Result<[VoiceNote], Error>) -> Void)
    func save(with content: String, createdAt: Date, completion: @escaping (Result<VoiceNote, Error>) -> Void)
}

protocol TextToSpeechRepository {
    func textToSpeech(text: String, completionHandler: @escaping (_ audioData: Data) -> Void)
}

protocol AudioRepository {
    var delegate : AudioServiceDelegate? { get set}
    func start()
    func stop()
}
