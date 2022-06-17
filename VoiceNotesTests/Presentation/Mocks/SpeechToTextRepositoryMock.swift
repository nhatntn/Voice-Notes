//
//  SpeechToTextRepositoryMock.swift
//  VoiceNotesTests
//
//  Created by nhatnt on 30/05/2022.
//

import Foundation
import XCTest
import googleapis

class SpeechToTextRepositoryMock: SpeechToTextRepository {
    var expectation: XCTestExpectation?
    var error: Error?
    var response = StreamingRecognizeResponse()
    var voiceNotes = [VoiceNote]()
    var createdVoiceNote = VoiceNote(name: "test", content: "test-cotent", createdAt: Date())
    
    func fetch(completion: @escaping (Result<[VoiceNote], Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(voiceNotes))
        }
        expectation?.fulfill()
    }
    
    
    func save(with content: String, createdAt: Date, completion: @escaping (Result<VoiceNote, Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(createdVoiceNote))
        }
        expectation?.fulfill()
    }
    
    
    func stopStreaming() {
        expectation?.fulfill()
    }
    
    func streamAudioData(_ audioData: NSData, completion: @escaping SpeechRecognitionCompletionHandler) {
        if let error = error {
            completion(nil, error as NSError)
        } else {
            completion(StreamingRecognizeResponse(), nil)
        }
        expectation?.fulfill()
    }
}
